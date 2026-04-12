# RAID-10 Infrastructure as Code (Ultimate Edition)

Автоматизированная система управления дисковой подсистемой Linux.

## Структура проекта

```text
.
├── deploy_raid.sh         # Главный оркестратор (запуск пайплайна)
├── Makefile               # Интерфейс управления (deploy, test, logs, clean)
├── README.md              # Данная документация
└── scripts/
    ├── fs/
    │   ├── mount_manager.sh     # Форматирование и запись в fstab
    │   └── setup_partitions.sh  # Разметка GPT
    ├── raid/
    │   ├── create_array.sh      # Инициализация RAID
    │   └── destroy_raid.sh      # Безопасный демонтаж и очистка
    └── tests/
        └── check_raid.sh        # Скрипт тестирования
```

## Функциональные возможности

* Идемпотентность: Повторный запуск скриптов не ломает систему.
* Интеллектуальный поиск: Защита системного диска через findmnt.
* Безопасный откат: make clean удаляет только специфичные записи в fstab.
* Обсервабельность: Единый трейс логов через syslog (RAID_DEPLOY).

## Команды управления

* make deploy - Сборка RAID и разметка (5 разделов).
* make test   - Запуск инфраструктурных тестов.
* make logs   - Просмотр логов развертывания в реальном времени.
* make clean  - Полная очистка и остановка массива.

## Диагностика

* cat /proc/mdstat - Статус массива.
* journalctl -t RAID_DEPLOY - История событий.

## Восстановление RAID после отказа (Break & Fix)

1. Симуляция отказа диска:
```bash
sudo mdadm --manage /dev/md10 --fail /dev/sdb
```

2. Удаление сломанного диска из массива:
```bash
sudo mdadm --manage /dev/md10 --remove /dev/sdb
```

3. Добавление нового диска (ребилд):
```bash
sudo mdadm --manage /dev/md10 --add /dev/sdb
```

4. Мониторинг восстановления:
```bash
watch -n 1 cat /proc/mdstat
```

Автор: Evgeny87 - Студент OTUS курса Linux Administrator Professional
