PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS appointment_services;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS cars;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS employee_services;
DROP TABLE IF EXISTS schedules;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS employees;

-- ============================================================
-- 1. Мастера СТО (мягкое удаление через dismissal_date)
-- ============================================================
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL,
    phone TEXT UNIQUE,
    email TEXT UNIQUE,
    hire_date DATE NOT NULL DEFAULT (date('now')),
    dismissal_date DATE,                          -- NULL = работает
    commission_rate REAL NOT NULL DEFAULT 0.40    -- процент от выручки (0..1)
        CHECK(commission_rate >= 0 AND commission_rate <= 1),
    is_active INTEGER GENERATED ALWAYS AS (CASE WHEN dismissal_date IS NULL THEN 1 ELSE 0 END) STORED
);

-- ============================================================
-- 2. Справочник услуг
-- ============================================================
CREATE TABLE services (
    id INTEGER PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    duration_min INTEGER NOT NULL CHECK(duration_min > 0),  -- длительность в минутах
    price REAL NOT NULL CHECK(price >= 0)
);

-- ============================================================
-- 3. Связь M:N: какие услуги оказывает каждый мастер
-- ============================================================
CREATE TABLE employee_services (
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE RESTRICT,
    service_id INTEGER NOT NULL REFERENCES services(id) ON DELETE CASCADE,
    PRIMARY KEY (employee_id, service_id)
);

-- ============================================================
-- 4. Индивидуальный график мастера (по дням недели)
-- ============================================================
CREATE TABLE schedules (
    id INTEGER PRIMARY KEY,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE RESTRICT,
    day_of_week INTEGER NOT NULL CHECK(day_of_week BETWEEN 0 AND 6),
    start_time TIME,
    end_time TIME,
    is_working_day INTEGER NOT NULL DEFAULT 1 CHECK(is_working_day IN (0, 1)),
    UNIQUE(employee_id, day_of_week),
    CHECK(is_working_day = 0 OR end_time > start_time)
);

-- ============================================================
-- 5. Клиенты
-- ============================================================
CREATE TABLE clients (
    id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL,
    phone TEXT UNIQUE,
    email TEXT,
    created_at DATETIME NOT NULL DEFAULT (datetime('now'))
);

-- ============================================================
-- 6. Автомобили клиентов
-- ============================================================
CREATE TABLE cars (
    id INTEGER PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    license_plate TEXT NOT NULL,
    year INTEGER CHECK(year >= 1900 AND year <= 2100),
    UNIQUE(license_plate)
);

-- ============================================================
-- 7. Записи на обслуживание
-- ============================================================
CREATE TABLE appointments (
    id INTEGER PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
    employee_id INTEGER NOT NULL REFERENCES employees(id) ON DELETE RESTRICT,
    car_id INTEGER NOT NULL REFERENCES cars(id) ON DELETE RESTRICT,
    appointment_datetime DATETIME NOT NULL,
    status TEXT NOT NULL DEFAULT 'scheduled'
        CHECK(status IN ('scheduled', 'completed', 'cancelled')),
    notes TEXT,
    created_at DATETIME NOT NULL DEFAULT (datetime('now')),
    UNIQUE(employee_id, appointment_datetime)   -- мастер не может быть в двух местах одновременно
);

-- ============================================================
-- 8. Услуги в рамках записи (M:N)
-- ============================================================
CREATE TABLE appointment_services (
    appointment_id INTEGER NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
    service_id INTEGER NOT NULL REFERENCES services(id) ON DELETE RESTRICT,
    actual_price REAL NOT NULL CHECK(actual_price >= 0),  -- цена на момент выполнения
    is_completed INTEGER NOT NULL DEFAULT 0 CHECK(is_completed IN (0, 1)),
    completed_at DATETIME,
    PRIMARY KEY (appointment_id, service_id)
);

-- ============================================================
-- Индексы для ускорения запросов
-- ============================================================
CREATE INDEX idx_employees_active ON employees(is_active);
CREATE INDEX idx_appointments_date ON appointments(appointment_datetime);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_employee ON appointments(employee_id);
CREATE INDEX idx_appointments_client ON appointments(client_id);
CREATE INDEX idx_cars_client ON cars(client_id);
CREATE INDEX idx_schedules_employee ON schedules(employee_id);

-- ============================================================
-- ТЕСТОВЫЕ ДАННЫЕ
-- ============================================================

-- Мастера (3 работающих + 1 уволенный)
INSERT INTO employees (id, full_name, phone, email, hire_date, dismissal_date, commission_rate) VALUES
(1, 'Иванов Иван Иванович', '+79001111111', 'ivanov@sto.ru', '2022-03-15', NULL, 0.45),
(2, 'Петров Петр Петрович', '+79002222222', 'petrov@sto.ru', '2023-01-10', NULL, 0.40),
(3, 'Сидоров Сидор Сидорович', '+79003333333', 'sidorov@sto.ru', '2024-06-01', NULL, 0.50),
(4, 'Кузнецов Алексей Михайлович', '+79004444444', 'kuznetsov@sto.ru', '2021-05-20', '2025-08-31', 0.42);

-- Услуги
INSERT INTO services (id, name, description, duration_min, price) VALUES
(1, 'Замена масла', 'Замена моторного масла и фильтра', 45, 1500.00),
(2, 'Диагностика двигателя', 'Компьютерная диагностика', 60, 2000.00),
(3, 'Шиномонтаж (4 колеса)', 'Снятие/установка, балансировка', 90, 3000.00),
(4, 'Замена тормозных колодок', 'Передние или задние', 120, 4500.00),
(5, 'Плановое ТО-1', 'Полное техобслуживание', 180, 7000.00),
(6, 'Замена свечей зажигания', '4 цилиндра', 60, 2500.00);

-- Какие услуги оказывает каждый мастер
INSERT INTO employee_services (employee_id, service_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 5),       -- Иванов: масло, диагностика, шиномонтаж, ТО
(2, 1), (2, 2), (2, 4), (2, 6),       -- Петров: масло, диагностика, тормоза, свечи
(3, 1), (3, 3), (3, 4), (3, 5), (3, 6),  -- Сидоров: почти всё
(4, 1), (4, 2), (4, 3);               -- Кузнецов (уволен): базовые услуги

-- График работы Иванова (Пн-Пт 9:00-18:00, Сб 10:00-15:00, Вс выходной)
INSERT INTO schedules (employee_id, day_of_week, start_time, end_time, is_working_day) VALUES
(1, 0, '09:00', '18:00', 1),
(1, 1, '09:00', '18:00', 1),
(1, 2, '09:00', '18:00', 1),
(1, 3, '09:00', '18:00', 1),
(1, 4, '09:00', '18:00', 1),
(1, 5, '10:00', '15:00', 1),
(1, 6, '00:00', '00:00', 0);

-- График Петрова (Пн-Чт 12:00-20:00, Пт-Сб выходные)
INSERT INTO schedules (employee_id, day_of_week, start_time, end_time, is_working_day) VALUES
(2, 0, '12:00', '20:00', 1),
(2, 1, '12:00', '20:00', 1),
(2, 2, '12:00', '20:00', 1),
(2, 3, '12:00', '20:00', 1),
(2, 4, '00:00', '00:00', 0),
(2, 5, '00:00', '00:00', 0),
(2, 6, '00:00', '00:00', 0);

-- График Сидорова (Пн-Вс 10:00-19:00, без выходных)
INSERT INTO schedules (employee_id, day_of_week, start_time, end_time, is_working_day) VALUES
(3, 0, '10:00', '19:00', 1),
(3, 1, '10:00', '19:00', 1),
(3, 2, '10:00', '19:00', 1),
(3, 3, '10:00', '19:00', 1),
(3, 4, '10:00', '19:00', 1),
(3, 5, '10:00', '19:00', 1),
(3, 6, '10:00', '19:00', 1);

-- Клиенты
INSERT INTO clients (id, full_name, phone, email) VALUES
(1, 'Смирнов Александр', '+79101234567', 'smirnov@mail.ru'),
(2, 'Козлова Мария', '+79107654321', 'kozlova@gmail.com'),
(3, 'Новиков Дмитрий', '+79109876543', NULL);

-- Автомобили клиентов
INSERT INTO cars (id, client_id, brand, model, license_plate, year) VALUES
(1, 1, 'Toyota', 'Camry', 'А123БВ77', 2020),
(2, 1, 'Kia', 'Rio', 'Е456ОР77', 2018),
(3, 2, 'Hyundai', 'Solaris', 'М789НХ99', 2022),
(4, 3, 'Volkswagen', 'Polo', 'К321СТ50', 2019);

-- Записи (с разными статусами)
INSERT INTO appointments (id, client_id, employee_id, car_id, appointment_datetime, status, notes) VALUES
(1, 1, 1, 1, '2026-11-25 10:00:00', 'scheduled', 'Плановое ТО'),
(2, 2, 2, 3, '2026-11-24 14:00:00', 'scheduled', 'Замена масла'),
(3, 3, 3, 4, '2026-11-20 11:00:00', 'completed', 'Шиномонтаж + балансировка'),
(4, 1, 1, 2, '2026-11-15 09:30:00', 'completed', 'Диагностика двигателя'),
(5, 2, 2, 3, '2026-11-10 16:00:00', 'cancelled', 'Клиент отменил');

-- Услуги в рамках записей
INSERT INTO appointment_services (appointment_id, service_id, actual_price, is_completed, completed_at) VALUES
(1, 5, 7000.00, 0, NULL),                         -- ТО-1 (запланировано)
(2, 1, 1500.00, 0, NULL),                         -- замена масла (запланировано)
(3, 3, 3000.00, 1, '2026-11-20 12:30:00'),       -- шиномонтаж (выполнено)
(4, 2, 2000.00, 1, '2026-11-15 10:30:00'),       -- диагностика (выполнено)
(4, 1, 1500.00, 1, '2026-11-15 11:00:00');       -- + замена масла (выполнено)