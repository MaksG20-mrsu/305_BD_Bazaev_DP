PRAGMA foreign_keys = ON;

-- ============================================================
-- 1. Добавляем 5 новых пользователей (дата регистрации = системное время)
-- ============================================================
INSERT INTO users (name, email, gender)
SELECT 'Базаев Даниил', 'bazaev.damill2006@gmail.com', 'male'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'bazaev.damill2006@gmail.com');

-- Сосед 1 по списку группы
INSERT INTO users (name, email, gender)
SELECT 'Иванов Иван', 'ivanov@gmail.com', 'male'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'ivanov@gmail.com');

-- Сосед 2 по списку группы
INSERT INTO users (name, email, gender)
SELECT 'Петрова Анна', 'petrova@yandex.ru', 'female'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'ppetrova@yandex.ru');

-- Сосед 3 по списку группы
INSERT INTO users (name, email, gender)
SELECT 'Сидоров Алексей', 'sidorov@yandex.ru', 'male'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'sidorov@yandex.ru');

-- Сосед 4 по списку группы
INSERT INTO users (name, email, gender)
SELECT 'Смирнова Елена', 'smirnova@yandex.ru', 'female'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'smirnova@yandex.ru');

-- ============================================================
-- 2. Добавляем 3 новых фильма разных жанров
-- ============================================================
INSERT INTO movies (title, year)
SELECT 'Реляционные тайны: 3NF', 2024
WHERE NOT EXISTS (SELECT 1 FROM movies WHERE title = 'Реляционные тайны: 3NF');

INSERT INTO movies (title, year)
SELECT 'Приключения SQL-запроса', 2023
WHERE NOT EXISTS (SELECT 1 FROM movies WHERE title = 'Приключения SQL-запроса');

INSERT INTO movies (title, year)
SELECT 'Документалка про SQLite', 2022
WHERE NOT EXISTS (SELECT 1 FROM movies WHERE title = 'Документалка про SQLite');

-- Связываем фильмы с жанрами (динамически находим ID по имени)
INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id FROM movies m, genres g
WHERE m.title = 'Реляционные тайны: 3NF' AND g.name = 'Sci-Fi'
  AND NOT EXISTS (SELECT 1 FROM movie_genres WHERE movie_id = m.id AND genre_id = g.id);

INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id FROM movies m, genres g
WHERE m.title = 'Приключения SQL-запроса' AND g.name = 'Adventure'
  AND NOT EXISTS (SELECT 1 FROM movie_genres WHERE movie_id = m.id AND genre_id = g.id);

INSERT INTO movie_genres (movie_id, genre_id)
SELECT m.id, g.id FROM movies m, genres g
WHERE m.title = 'Документалка про SQLite' AND g.name = 'Documentary'
  AND NOT EXISTS (SELECT 1 FROM movie_genres WHERE movie_id = m.id AND genre_id = g.id);

-- ============================================================
-- 3. Три отзыва от меня (Базеева) на добавленные фильмы
-- Запросы не зависят от конкретных ID
-- ============================================================
INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT u.id, m.id, 5.0, strftime('%s', 'now')
FROM users u, movies m
WHERE u.email = 'bazaev.damill2006@gmail.com'
  AND m.title = 'Реляционные тайны: 3NF'
  AND NOT EXISTS (SELECT 1 FROM ratings WHERE user_id = u.id AND movie_id = m.id);

INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT u.id, m.id, 4.5, strftime('%s', 'now')
FROM users u, movies m
WHERE u.email = 'bazaev.damill2006@gmail.com'
  AND m.title = 'Приключения SQL-запроса'
  AND NOT EXISTS (SELECT 1 FROM ratings WHERE user_id = u.id AND movie_id = m.id);

INSERT INTO ratings (user_id, movie_id, rating, timestamp)
SELECT u.id, m.id, 5.0, strftime('%s', 'now')
FROM users u, movies m
WHERE u.email = 'bazaev.damill2006@gmail.com'
  AND m.title = 'Документалка про SQLite'
  AND NOT EXISTS (SELECT 1 FROM ratings WHERE user_id = u.id AND movie_id = m.id);