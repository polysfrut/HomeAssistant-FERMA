#!/bin/bash
# Скрипт для проверки и перезагрузки датчиков через Home Assistant API

HA_URL="http://192.168.100.100:8123"
HA_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJlOTBjODJmYjhkMjg0M2QwOTYwYWJmYzdkNjhlNzUwMSIsImlhdCI6MTc2NjQwODQwMSwiZXhwIjoyMDgxNzY4NDAxfQ.WQpY8HrrR6Gx-05QHx9goJ5QHO3bMxALDx2juSlZbzE"

echo "=== Проверка старых датчиков ==="
echo ""

# Список старых датчиков для проверки
OLD_SENSORS=(
    "sensor.temperatura_brudera"
    "sensor.temperatura_brudera_2"
    "sensor.vlazhnost_brudera"
    "sensor.vlazhnost_brudera_2"
)

# Проверяем старые датчики
for sensor in "${OLD_SENSORS[@]}"; do
    echo "Проверка: $sensor"
    response=$(curl -s -X GET \
        -H "Authorization: Bearer $HA_TOKEN" \
        -H "Content-Type: application/json" \
        "$HA_URL/api/states/$sensor" 2>/dev/null)
    
    if echo "$response" | grep -q "entity_id"; then
        state=$(echo "$response" | grep -o '"state":"[^"]*"' | cut -d'"' -f4)
        echo "  ⚠ Найден, состояние: $state"
        echo "  → Этот датчик нужно удалить вручную через UI:"
        echo "    Settings → Devices & Services → Entities → найти '$sensor' → удалить"
    else
        echo "  ✓ Не найден (уже удален или не существует)"
    fi
    echo ""
done

echo "=== Проверка новых датчиков ==="
echo ""

# Проверяем новые датчики
NEW_SENSORS=(
    "sensor.brooder_temperature"
    "sensor.brooder_humidity"
)

for sensor in "${NEW_SENSORS[@]}"; do
    echo "Проверка: $sensor"
    response=$(curl -s -X GET \
        -H "Authorization: Bearer $HA_TOKEN" \
        -H "Content-Type: application/json" \
        "$HA_URL/api/states/$sensor" 2>/dev/null)
    
    if echo "$response" | grep -q "entity_id"; then
        state=$(echo "$response" | grep -o '"state":"[^"]*"' | cut -d'"' -f4)
        friendly_name=$(echo "$response" | grep -o '"attributes":{[^}]*"friendly_name":"[^"]*"' | grep -o '"friendly_name":"[^"]*"' | cut -d'"' -f4)
        echo "  ✓ Найден"
        echo "    Состояние: $state"
        echo "    Название: $friendly_name"
    else
        echo "  ✗ Не найден"
        echo "  → Нужно перезагрузить шаблоны (Templates)"
    fi
    echo ""
done

echo "=== Перезагрузка шаблонов ==="
echo ""

# Перезагружаем шаблоны
echo "Вызов сервиса template.reload..."
response=$(curl -s -X POST \
    -H "Authorization: Bearer $HA_TOKEN" \
    -H "Content-Type: application/json" \
    "$HA_URL/api/services/template/reload" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "  ✓ Шаблоны перезагружены"
else
    echo "  ✗ Ошибка при перезагрузке шаблонов"
fi

echo ""
echo "=== Готово! ==="
echo ""
echo "Если старые датчики все еще видны, удалите их вручную:"
echo "1. Settings → Devices & Services → Entities"
echo "2. Найдите старые датчики (sensor.temperatura_brudera и т.д.)"
echo "3. Нажмите на каждый → три точки (⋮) → Удалить"
echo ""
echo "После этого перезагрузите Home Assistant или перезагрузите шаблоны."

