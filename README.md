# Linux адміністрування

Скрипт встановлює Docker, Docker Compose, Python 3.9+ і Django на Ubuntu або Debian. Для системних пакетів потрібен доступ до `apt`. Якщо скрипт запущено від звичайного користувача, для встановлення пакетів використовується `sudo`.

```bash
./install_dev_tools.sh
```

Скрипт перевіряє наявні версії та встановлює тільки ті інструменти, яких бракує. Якщо Django ще не встановлений, `pip` додає його у віртуальне середовище `.venv` поруч зі скриптом. Це дозволяє користуватися Django окремо від системних пакетів Python.

```bash
docker --version
docker compose version  # або docker-compose version
python3 --version
.venv/bin/python -m django --version  # якщо скрипт створив .venv
```
