#!/bin/bash
chcp 65001

C:\sqlite\sqlite3.exe movies_rating.db < db_init.sql

echo "1. Список фильмов, имеющих хотя бы одну оценку. Отсортировать по году и названию. Первые 10."
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "SELECT DISTINCT m.title, CAST(substr(m.title, instr(m.title, '(') + 1, 4) AS INTEGER) AS year FROM movies m INNER JOIN ratings r ON m.id = r.movie_id ORDER BY year, m.title LIMIT 10;"
echo " "

echo "2. Пользователи, фамилии которых начинаются на 'A'. Отсортировать по дате регистрации. Первые 5."
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "SELECT * FROM users WHERE substr(name, instr(name, ' ') + 1, 1) = 'A' ORDER BY register_date LIMIT 5;"
echo " "

echo "3. Рейтинги в читаемом формате: имя, фильм, год, оценка, дата (ГГГГ-ММ-ДД). Первые 50."
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "SELECT u.name, m.title, CAST(substr(m.title, instr(m.title, '(') + 1, 4) AS INTEGER) AS year, r.rating, strftime('%Y-%m-%d', r.timestamp, 'unixepoch') as rating_date FROM ratings r INNER JOIN users u ON r.user_id = u.id INNER JOIN movies m ON r.movie_id = m.id ORDER BY u.name, m.title, r.rating LIMIT 50;"
echo " "

echo "4. Фильмы с тегами. Сортировка: год, название, тег. Первые 40."
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "SELECT m.title, CAST(substr(m.title, instr(m.title, '(') + 1, 4) AS INTEGER) AS year, t.tag FROM movies m INNER JOIN tags t ON m.id = t.movie_id ORDER BY year, m.title, t.tag LIMIT 40;"
echo " "

echo "5. Самые свежие фильмы (последний год выпуска)."
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "SELECT title, CAST(substr(title, instr(title, '(') + 1, 4) AS INTEGER) AS year FROM movies WHERE CAST(substr(title, instr(title, '(') + 1, 4) AS INTEGER) = (SELECT MAX(CAST(substr(title, instr(title, '(') + 1, 4) AS INTEGER)) FROM movies) ORDER BY title;"
echo " "

echo "6. Комедии после 2000 с оценкой >= 4.5 от мужчин. Название, год, количество оценок."
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "SELECT m.title, CAST(substr(m.title, instr(m.title, '(') + 1, 4) AS INTEGER) AS year, COUNT(r.id) as good_ratings_count FROM movies m INNER JOIN ratings r ON m.id = r.movie_id INNER JOIN users u ON r.user_id = u.id WHERE m.genres LIKE '%Comedy%' AND CAST(substr(m.title, instr(m.title, '(') + 1, 4) AS INTEGER) > 2000 AND r.rating >= 4.5 AND u.gender = 'male' GROUP BY m.id, m.title, m.year ORDER BY year, m.title;"
echo " "

echo "7. Анализ профессий: количество пользователей для каждой профессии."
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "SELECT occupation, COUNT(*) as user_count FROM users GROUP BY occupation ORDER BY user_count DESC;"
echo " "

echo "Самая распространенная профессия:"
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "SELECT occupation, COUNT(*) as user_count FROM users GROUP BY occupation ORDER BY user_count DESC LIMIT 1;"
echo " "

echo "Самая редкая профессия:"
echo --------------------------------------------------
C:\sqlite\sqlite3.exe movies_rating.db -box -echo "SELECT occupation, COUNT(*) as user_count FROM users GROUP BY occupation ORDER BY user_count ASC LIMIT 1;"
echo " "