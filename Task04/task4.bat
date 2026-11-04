#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Все пары пользователей, оценивших один и тот же фильм (без дубликатов и пар с самим собой). Первые 100 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT u1.name AS user1, u2.name AS user2, m.title AS movie FROM ratings r1 INNER JOIN ratings r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id INNER JOIN users u1 ON r1.user_id = u1.id INNER JOIN users u2 ON r2.user_id = u2.id INNER JOIN movies m ON r1.movie_id = m.id ORDER BY m.title, u1.name, u2.name LIMIT 100;"
echo " "

echo "2. Найти 10 самых свежих оценок от разных пользователей: фильм, имя, оценка, дата (ГГГГ-ММ-ДД)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title, u.name, r.rating, date(r.timestamp, 'unixepoch') AS review_date FROM (SELECT *, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp DESC) AS rn FROM ratings) r INNER JOIN users u ON r.user_id = u.id INNER JOIN movies m ON r.movie_id = m.id WHERE r.rn = 1 ORDER BY r.timestamp DESC LIMIT 10;"
echo " "

echo "3. Фильмы с максимальным и минимальным средним рейтингом в одном списке, с колонкой Рекомендуем. Сортировка по году и названию."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH avg_ratings AS (SELECT movie_id, AVG(rating) AS avg_r FROM ratings GROUP BY movie_id) SELECT m.title, m.year, ROUND(ar.avg_r, 2) AS avg_rating, CASE WHEN ar.avg_r = (SELECT MAX(avg_r) FROM avg_ratings) THEN 'Да' ELSE 'Нет' END AS 'Рекомендуем' FROM movies m INNER JOIN avg_ratings ar ON m.id = ar.movie_id WHERE ar.avg_r = (SELECT MAX(avg_r) FROM avg_ratings) OR ar.avg_r = (SELECT MIN(avg_r) FROM avg_ratings) ORDER BY m.year, m.title;"
echo " "

echo "4. Количество оценок и средняя оценка от женщин за 2010-2012 годы."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT COUNT(*) AS rating_count, ROUND(AVG(r.rating), 2) AS avg_rating FROM ratings r INNER JOIN users u ON r.user_id = u.id WHERE u.gender = 'female' AND CAST(substr(date(r.timestamp, 'unixepoch'), 1, 4) AS INTEGER) BETWEEN 2010 AND 2012;"
echo " "

echo "5. Фильмы со средней оценкой и местом в рейтинге. Сортировка по году и названию. Первые 20."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title, m.year, ROUND(AVG(r.rating), 2) AS avg_rating, RANK() OVER (ORDER BY AVG(r.rating) DESC) AS rank_position FROM movies m INNER JOIN ratings r ON m.id = r.movie_id GROUP BY m.id, m.title, m.year ORDER BY m.year, m.title LIMIT 20;"
echo " "

echo "6. 10 последних зарегистрированных пользователей в формате Фамилия Имя|Дата регистрации."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT substr(name, instr(name, ' ') + 1) || ' ' || substr(name, 1, instr(name, ' ') - 1) || '|' || register_date AS user_info FROM users ORDER BY register_date DESC LIMIT 10;"
echo " "

echo "7. Таблица умножения от 1 до 10 (рекурсивный CTE)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE mult(i, j) AS (SELECT 1, 1 UNION ALL SELECT CASE WHEN j = 10 THEN i + 1 ELSE i END, CASE WHEN j = 10 THEN 1 ELSE j + 1 END FROM mult WHERE i <= 10) SELECT i || 'x' || j || '=' || (i * j) AS multiplication_table FROM mult WHERE i <= 10 ORDER BY i, j;"
echo " "

echo "8. Все жанры фильмов из таблицы movies (рекурсивный CTE), каждый жанр в отдельной строке."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE genre_split(genre, rest) AS (SELECT CASE WHEN instr(genres, '|') > 0 THEN substr(genres, 1, instr(genres, '|') - 1) ELSE genres END, CASE WHEN instr(genres, '|') > 0 THEN substr(genres, instr(genres, '|') + 1) ELSE '' END FROM movies WHERE genres IS NOT NULL AND genres != '' UNION ALL SELECT CASE WHEN instr(rest, '|') > 0 THEN substr(rest, 1, instr(rest, '|') - 1) ELSE rest END, CASE WHEN instr(rest, '|') > 0 THEN substr(rest, instr(rest, '|') + 1) ELSE '' END FROM genre_split WHERE rest != '') SELECT DISTINCT genre FROM genre_split WHERE genre != '' AND genre != '(no genres listed)' ORDER BY genre;"
echo " "