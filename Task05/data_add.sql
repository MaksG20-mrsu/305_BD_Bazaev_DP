PRAGMA foreign_keys = ON;

-- 1. Добавляем 5 новых пользователей (дата регистрации = системное время)
-- ЗАМЕНИ имена и email на свои и своих 4 соседей по группе!
-- Мы используем SELECT, чтобы динамически найти occupation_id для 'student'
INSERT INTO users (name, email, gender, register_date, occupation_id) 
SELECT 'Базаев Даниил', 'bazaev@student.mrsu.ru', 'male', datetime('now'), id FROM occupations WHERE name = 'student' LIMIT 1;

INSERT INTO users (name, email, gender, register_date, occupation_id) 
SELECT 'Иванов Иван', 'ivanov@student.mrsu.ru', 'male', datetime('now'), id FROM occupations WHERE name = 'student' LIMIT 1;

INSERT INTO users (name, email, gender, register_date, occupation_id) 
SELECT 'Петрова Анна', 'petrova@student.mrsu.ru', 'female', datetime('now'), id FROM occupations WHERE name = 'student' LIMIT 1;

INSERT INTO users (name, email, gender, register_date, occupation_id) 
SELECT 'Сидоров Алексей', 'sidorov@student.mrsu.ru', 'male', datetime('now'), id FROM occupations WHERE name = 'student' LIMIT 1;

INSERT INTO users (name, email, gender, register_date, occupation_id) 
SELECT 'Смирнова Елена', 'smirnova@student.mrsu.ru', 'female', datetime('now'), id FROM occupations WHERE name = 'student' LIMIT 1;

-- 2. Добавляем 3 новых фильма разных жанров
INSERT INTO movies (title, year) VALUES 
('Лабораторная работа 5: Документальный', 2024),
('Приключения Git и GitHub', 2023),
('Тайны реляционных баз данных', 2022);

-- Связываем фильмы с жанрами (динамически находим ID по названию фильма и жанра)
INSERT INTO movie_genres (movie_id, genre_id) 
SELECT m.id, g.id FROM movies m, genres g WHERE m.title = 'Лабораторная работа 5: Документальный' AND g.name = 'Documentary';

INSERT INTO movie_genres (movie_id, genre_id) 
SELECT m.id, g.id FROM movies m, genres g WHERE m.title = 'Приключения Git и GitHub' AND g.name = 'Action';

INSERT INTO movie_genres (movie_id, genre_id) 
SELECT m.id, g.id FROM movies m, genres g WHERE m.title = 'Тайны реляционных баз данных' AND g.name = 'Mystery';

-- 3. Добавляем 3 отзыва от себя 
-- (динамически находим свой user_id по email, а movie_id по названию фильма)
INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT u.id, m.id, 5.0, strftime('%s', 'now')
FROM users u, movies m
WHERE u.email = 'bazaev@student.mrsu.ru' AND m.title = 'Лабораторная работа 5: Документальный';

INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT u.id, m.id, 4.5, strftime('%s', 'now')
FROM users u, movies m
WHERE u.email = 'bazaev@student.mrsu.ru' AND m.title = 'Приключения Git и GitHub';

INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT u.id, m.id, 5.0, strftime('%s', 'now')
FROM users u, movies m
WHERE u.email = 'bazaev@student.mrsu.ru' AND m.title = 'Тайны реляционных баз данных';