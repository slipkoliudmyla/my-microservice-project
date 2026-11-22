# Django, PostgreSQL та Nginx у Docker

## Запуск

Потрібен Docker з Docker Compose. Запустіть із кореня проєкту.

```bash
docker compose up --build -d
docker compose ps
```

Відкрийте `http://localhost/`, щоб побачити сторінку Django. Адреса `http://localhost/health/` повертає `{"database":"ok"}`, коли Django успішно виконує запит до PostgreSQL.

Якщо порт `80` зайнято, запустіть `HTTP_PORT=8080 docker compose up --build -d` і відкрийте `http://localhost:8080/`.

## Сервіси

- `db` запускає PostgreSQL і зберігає дані в томі `postgres_data`.
- `web` запускає міграції Django, а потім стартує Gunicorn. Контейнер підключається до бази за ім’ям `db`.
- `nginx` приймає HTTP-запити на локальному порту та передає їх до `web:8000` через мережу Compose.

Типові значення пароля бази та ключа Django призначені для локального запуску. За потреби їх можна задати через `POSTGRES_PASSWORD` і `DJANGO_SECRET_KEY` перед першим запуском. Compose публікує лише порт Nginx на `127.0.0.1`.

```bash
docker compose down
```

Після зупинки том PostgreSQL з даними залишається на диску.
