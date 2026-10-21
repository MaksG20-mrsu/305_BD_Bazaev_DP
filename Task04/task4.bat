#!/bin/bash
chcp 65001

C:\sqlite\sqlite3.exe movies_rating.db < db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Первые 100 записей."
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "SELECT u1.name AS user1, u2.name AS user2, m.title FROM ratings r1 INNER JOIN ratings r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id INNER JOIN users u1 ON r1.user_id = u1.id INNER JOIN users u2 ON r2.user_id = u2.id INNER JOIN movies m ON r1.movie_id = m.id ORDER BY m.title, u1.name, u2.name LIMIT 100;"
echo " "

echo "2. Найти 10 самых свежих оценок от разных пользователей."
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "SELECT m.title, u.name, r.rating, strftime('%Y-%m-%d', r.timestamp, 'unixepoch') AS review_date FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp DESC) AS rn FROM ratings) r INNER JOIN users u ON r.user_id = u.id INNER JOIN movies m ON r.movie_id = m.id WHERE r.rn = 1 ORDER BY r.timestamp DESC LIMIT 10;"
echo " "

echo "3. Фильмы с максимальным и минимальным средним рейтингом."
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "SELECT m.title, CAST(substr(m.title, instr(m.title, '(') + 1, 4) AS INTEGER) AS year, ROUND(AVG(r.rating), 2) AS avg_rating, CASE WHEN ROUND(AVG(r.rating), 2) = (SELECT MAX(avg_r) FROM (SELECT AVG(rating) AS avg_r FROM ratings GROUP BY movie_id)) THEN 'Да' ELSE 'Нет' END AS 'Рекомендуем' FROM movies m INNER JOIN ratings r ON m.id = r.movie_id GROUP BY m.id, m.title HAVING ROUND(AVG(r.rating), 2) = (SELECT MAX(avg_r) FROM (SELECT AVG(rating) AS avg_r FROM ratings GROUP BY movie_id)) OR ROUND(AVG(r.rating), 2) = (SELECT MIN(avg_r) FROM (SELECT AVG(rating) AS avg_r FROM ratings GROUP BY movie_id)) ORDER BY year, m.title;"
echo " "

echo "4. Количество оценок и средняя оценка от женщин в 2010-2012 годах."
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "SELECT COUNT(r.id) AS rating_count, ROUND(AVG(r.rating), 2) AS avg_rating FROM ratings r INNER JOIN users u ON r.user_id = u.id WHERE u.gender = 'female' AND strftime('%Y', r.timestamp, 'unixepoch') BETWEEN '2010' AND '2012';"
echo " "

echo "5. Список фильмов со средней оценкой и местом в рейтинге. Первые 20."
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "SELECT m.title, CAST(substr(m.title, instr(m.title, '(') + 1, 4) AS INTEGER) AS year, ROUND(AVG(r.rating), 2) AS avg_rating, RANK() OVER (ORDER BY AVG(r.rating) DESC) AS rank_position FROM movies m INNER JOIN ratings r ON m.id = r.movie_id GROUP BY m.id, m.title ORDER BY year, m.title LIMIT 20;"
echo " "

echo "6. Список из 10 последних зарегистрированных пользователей в формате 'Фамилия Имя|Дата регистрации'."
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "SELECT substr(name, instr(name, ' ') + 1) || ' ' || substr(name, 1, instr(name, ' ') - 1) || '|' || register_date AS user_info FROM users ORDER BY register_date DESC LIMIT 10;"
echo " "

echo "7. Таблица умножения от 1 до 10 (рекурсивный CTE)."
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "WITH RECURSIVE multiply(i, j) AS (SELECT 1, 1 UNION ALL SELECT CASE WHEN j = 10 THEN i + 1 ELSE i END, CASE WHEN j = 10 THEN 1 ELSE j + 1 END FROM multiply WHERE i <= 10) SELECT i || 'x' || j || '=' || (i * j) AS result FROM multiply WHERE i <= 10 AND j <= 10 ORDER BY i, j;"
echo " "

echo "8. Выделить все жанры фильмов (рекурсивный CTE)."
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "WITH RECURSIVE genre_split(movie_id, genre, rest) AS (SELECT id, CASE WHEN instr(genres, '|') > 0 THEN substr(genres, 1, instr(genres, '|') - 1) ELSE genres END, CASE WHEN instr(genres, '|') > 0 THEN substr(genres, instr(genres, '|') + 1) ELSE '' END FROM movies UNION ALL SELECT movie_id, CASE WHEN instr(rest, '|') > 0 THEN substr(rest, 1, instr(rest, '|') - 1) ELSE rest END, CASE WHEN instr(rest, '|') > 0 THEN substr(rest, instr(rest, '|') + 1) ELSE '' END FROM genre_split WHERE rest != '') SELECT DISTINCT genre FROM genre_split WHERE genre != '' ORDER BY genre;"
echo " "