#!/bin/bash
# Скрипт для переименования существующих датчиков через Home Assistant Entity Registry API

HA_URL="http://192.168.100.100:8123"
HA_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJlOTBjODJmYjhkMjg0M2QwOTYwYWJmYzdkNjhlNzUwMSIsImlhdCI6MTc2NjQwODQwMSwiZXhwIjoyMDgxNzY4NDAxfQ.WQpY8HrrR6Gx-05QHx9goJ5QHO3bMxALDx2juSlZbzE"

echo "=== Переименование датчиков через Entity Registry ==="
echo ""

# Маппинг старых entity_id на новые
declare -A RENAME_MAP
RENAME_MAP["sensor.temperatura_brudera"]="sensor.brooder_temperature"
RENAME_MAP["sensor.temperatura_brudera_2"]="sensor.brooder_temperature"
RENAME_MAP["sensor.vlazhnost_brudera"]="sensor.brooder_humidity"
RENAME_MAP["sensor.vlazhnost_brudera_2"]="sensor.brooder_humidity"

# Функция для получения entity registry entry
get_entity_registry() {
    local entity_id=$1
    curl -s -X GET \
        -H "Authorization: Bearer $HA_TOKEN" \
        -H "Content-Type: application/json" \
        "$HA_URL/api/config/entity_registry/$entity_id" 2>/dev/null
}

# Функция для обновления entity_id в registry через UPDATE endpoint
update_entity_id() {
    local old_id=$1
    local new_id=$2
    
    echo "Переименование: $old_id → $new_id"
    
    # Получаем текущую запись из registry
    registry_data=$(get_entity_registry "$old_id")
    
    if echo "$registry_data" | grep -q "entity_id"; then
        echo "  → Найден в registry"
        
        # Извлекаем данные из старой записи
        unique_id=$(echo "$registry_data" | grep -o '"unique_id":"[^"]*"' | cut -d'"' -f4)
        device_id=$(echo "$registry_data" | grep -o '"device_id":"[^"]*"' | cut -d'"' -f4)
        area_id=$(echo "$registry_data" | grep -o '"area_id":"[^"]*"' | cut -d'"' -f4)
        name=$(echo "$registry_data" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
        icon=$(echo "$registry_data" | grep -o '"icon":"[^"]*"' | cut -d'"' -f4)
        disabled_by=$(echo "$registry_data" | grep -o '"disabled_by":"[^"]*"' | cut -d'"' -f4)
        
        echo "    unique_id: $unique_id"
        echo "    device_id: $device_id"
        
        # Обновляем entity_id через UPDATE endpoint
        # Формируем JSON для обновления
        update_json="{"
        update_json+="\"entity_id\":\"$new_id\""
        if [ -n "$name" ]; then
            update_json+=",\"name\":\"$name\""
        fi
        if [ -n "$icon" ]; then
            update_json+=",\"icon\":\"$icon\""
        fi
        if [ -n "$area_id" ]; then
            update_json+=",\"area_id\":\"$area_id\""
        fi
        if [ -n "$disabled_by" ]; then
            update_json+=",\"disabled_by\":\"$disabled_by\""
        fi
        update_json+="}"
        
        echo "  → Обновление через Entity Registry API..."
        update_response=$(curl -s -X PUT \
            -H "Authorization: Bearer $HA_TOKEN" \
            -H "Content-Type: application/json" \
            -d "$update_json" \
            "$HA_URL/api/config/entity_registry/$old_id" 2>/dev/null)
        
        if echo "$update_response" | grep -q "entity_id"; then
            echo "  ✓ Успешно переименован в $new_id"
        else
            echo "  ✗ Ошибка при переименовании"
            echo "    Ответ: $update_response"
            echo "  → Попробуем альтернативный способ..."
        fi
        
    else
        echo "  → Не найден в registry, возможно уже переименован или не существует"
    fi
    echo ""
}

# Проверяем существующие датчики
echo "=== Поиск датчиков для переименования ==="
echo ""

# Получаем все entities из registry
all_entities=$(curl -s -X GET \
    -H "Authorization: Bearer $HA_TOKEN" \
    -H "Content-Type: application/json" \
    "$HA_URL/api/config/entity_registry" 2>/dev/null)

# Ищем датчики, которые нужно переименовать
for old_id in "${!RENAME_MAP[@]}"; do
    new_id="${RENAME_MAP[$old_id]}"
    
    # Проверяем, существует ли старый датчик
    if echo "$all_entities" | grep -q "\"entity_id\":\"$old_id\""; then
        echo "Найден датчик для переименования: $old_id"
        update_entity_id "$old_id" "$new_id"
    else
        echo "Датчик $old_id не найден в registry"
    fi
done

echo "=== Альтернативный способ: обновление через конфигурацию ==="
echo ""
echo "Так как Entity Registry API не поддерживает прямое переименование,"
echo "лучший способ - это обновить конфигурацию так, чтобы использовать"
echo "существующие entity_id или перезагрузить шаблоны."
echo ""
echo "Перезагрузка шаблонов..."
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
echo "=== Проверка новых датчиков ==="
echo ""

sleep 2

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
        friendly_name=$(echo "$response" | grep -o '"attributes":{[^}]*"friendly_name":"[^"]*"' | grep -o '"friendly_name":"[^"]*"' | cut -d'"' -f4 || echo "N/A")
        echo "  ✓ Найден"
        echo "    Состояние: $state"
        echo "    Название: $friendly_name"
    else
        echo "  ✗ Не найден"
    fi
    echo ""
done

echo "=== Готово! ==="
echo ""
echo "Если датчики не переименовались автоматически, можно:"
echo "1. Перезагрузить Home Assistant полностью"
echo "2. Или вручную переименовать через UI:"
echo "   Settings → Devices & Services → Entities → найти старый датчик →"
echo "   → нажать на него → изменить entity_id вручную"

