# Настройка Home Assistant в режиме YAML

## Что изменено:

1. **Lovelace переведен в YAML режим** - все dashboard настройки только через файлы
2. **Создан файл `ui-lovelace.yaml`** - основной файл dashboard
3. **Обновлен `configuration.yaml`** - добавлена конфигурация Lovelace в YAML режиме

## Инструкция по применению:

### 1. Синхронизация файлов в Home Assistant:

В веб-терминале Home Assistant выполните:

```bash
cd /config
git pull origin main
```

### 2. Переключение Lovelace в YAML режим:

**Вариант А: Через веб-интерфейс (если еще не переключено):**

1. Откройте Home Assistant
2. Профиль (внизу слева) → Настройки профиля
3. Найдите раздел "Lovelace"
4. Выберите "YAML" режим
5. Сохраните изменения

**Вариант Б: Через файл конфигурации (уже сделано):**

Файл `configuration.yaml` уже настроен с `lovelace: mode: yaml`

### 3. Перезагрузка Home Assistant:

```bash
ha core restart
```

Или через веб-интерфейс:
- Настройки → Система → Перезагрузка → Перезагрузить Home Assistant

### 4. Проверка:

После перезагрузки:
- Dashboard должен загружаться из файла `ui-lovelace.yaml`
- Редактирование через UI будет недоступно
- Все изменения только через редактирование YAML файлов

## Структура файлов:

```
/config/
├── configuration.yaml          # Основная конфигурация (lovelace: mode: yaml)
├── ui-lovelace.yaml            # Главный файл dashboard (YAML режим)
├── brooder_dahsboard,yaml      # Резервная копия (можно удалить)
├── lovelace_resources/         # Ресурсы Lovelace (JS/CSS модули)
├── automations.yaml            # Автоматизации
├── scripts.yaml                # Скрипты
└── packages/                   # Пакеты конфигурации
```

## Важно:

- После переключения в YAML режим все изменения dashboard нужно делать только через редактирование файла `ui-lovelace.yaml`
- После изменений в файле нужно перезагрузить Home Assistant или выполнить "Перезагрузить Lovelace" в Developer Tools
- UI редактор будет недоступен - это нормально для YAML режима

## Откат в UI режим (если нужно):

Если нужно вернуться в UI режим:

1. В `configuration.yaml` удалите или закомментируйте секцию `lovelace:`
2. Перезагрузите Home Assistant
3. Dashboard вернется в UI режим

