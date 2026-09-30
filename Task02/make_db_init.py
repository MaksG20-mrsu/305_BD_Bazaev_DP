import csv
import os

# Функция для безопасного экранирования строк в SQL (заменяет ' на '')
def escape_sql(value):
    if value is None or value == '':
        return 'NULL'
    # Пробуем преобразовать в число, если получится - возвращаем как есть
    try:
        float(value)
        return value
    except ValueError:
        # Если это текст, оборачиваем в кавычки и экранируем одинарные кавычки
        return f"'{value.replace(chr(39), chr(39)+chr(39))}'"

# Конфигурация таблиц и соответствующих им CSV-файлов
tables_config = {
    'movies': {
        'file': 'movies.csv',
        'columns': ['id', 'title', 'year', 'genres'],
        'schema': 'id INTEGER PRIMARY KEY, title TEXT, year INTEGER, genres TEXT'
    },
    'ratings': {
        'file': 'ratings.csv',
        'columns': ['id', 'user_id', 'movie_id', 'rating', 'timestamp'],
        'schema': 'id INTEGER PRIMARY KEY, user_id INTEGER, movie_id INTEGER, rating REAL, timestamp INTEGER'
    },
    'tags': {
        'file': 'tags.csv',
        'columns': ['id', 'user_id', 'movie_id', 'tag', 'timestamp'],
        'schema': 'id INTEGER PRIMARY KEY, user_id INTEGER, movie_id INTEGER, tag TEXT, timestamp INTEGER'
    },
    'users': {
        'file': 'users.txt',
        'columns': ['id', 'name', 'email', 'gender', 'register_date', 'occupation'],
        'schema': 'id INTEGER PRIMARY KEY, name TEXT, email TEXT, gender TEXT, register_date TEXT, occupation TEXT'
    }
}

output_sql = 'db_init.sql'

with open(output_sql, 'w', encoding='utf-8') as f:
    # Сначала удаляем старые таблицы, если они есть
    for table_name in tables_config.keys():
        f.write(f"DROP TABLE IF EXISTS {table_name};\n")
    
    # Создаем новые таблицы
    for table_name, config in tables_config.items():
        f.write(f"CREATE TABLE {table_name} ({config['schema']});\n")
    
    # Генерируем INSERT для каждой таблицы
    for table_name, config in tables_config.items():
        csv_file = config['file']
        columns = config['columns']
        
        if not os.path.exists(csv_file):
            print(f"ВНИМАНИЕ: Файл {csv_file} не найден. Пропускаю.")
            continue
            
        print(f"Обработка {csv_file}...")
        
        with open(csv_file, 'r', encoding='utf-8') as csv_f:
            reader = csv.DictReader(csv_f)
            for row in reader:
                # Собираем значения для INSERT, соблюдая порядок колонок
                values = [escape_sql(row.get(col, '')) for col in columns]
                values_str = ', '.join(values)
                cols_str = ', '.join(columns)
                
                f.write(f"INSERT INTO {table_name} ({cols_str}) VALUES ({values_str});\n")

print("Файл db_init.sql создан.")