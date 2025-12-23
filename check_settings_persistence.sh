#!/bin/bash
# Скрипт для проверки сохранения настроек после перезагрузки Home Assistant

echo "=========================================="
echo "ПРОВЕРКА СОХРАНЕНИЯ НАСТРОЕК"
echo "=========================================="
echo ""

# 1. Проверка файла restore_state
echo "1. Проверка файла .storage/core.restore_state:"
if [ -f "/config/.storage/core.restore_state" ]; then
    echo "   ✓ Файл существует"
    FILE_SIZE=$(stat -f%z "/config/.storage/core.restore_state" 2>/dev/null || stat -c%s "/config/.storage/core.restore_state" 2>/dev/null)
    echo "   Размер файла: $FILE_SIZE байт"
    
    # Проверяем наличие input_number в файле
    if grep -q "input_number" "/config/.storage/core.restore_state" 2>/dev/null; then
        echo "   ✓ Найдены input_number entities"
    else
        echo "   ⚠ input_number entities не найдены"
    fi
    
    # Проверяем наличие input_boolean в файле
    if grep -q "input_boolean" "/config/.storage/core.restore_state" 2>/dev/null; then
        echo "   ✓ Найдены input_boolean entities"
    else
        echo "   ⚠ input_boolean entities не найдены"
    fi
else
    echo "   ✗ Файл не существует"
fi

echo ""
echo "2. Текущие значения настроек:"
echo "   min_temp: $(ha core states get input_number.min_temp 2>/dev/null | grep -o '"state":"[^"]*"' | cut -d'"' -f4 || echo 'недоступно')"
echo "   max_temp: $(ha core states get input_number.max_temp 2>/dev/null | grep -o '"state":"[^"]*"' | cut -d'"' -f4 || echo 'недоступно')"
echo "   min_hum: $(ha core states get input_number.min_hum 2>/dev/null | grep -o '"state":"[^"]*"' | cut -d'"' -f4 || echo 'недоступно')"
echo "   max_hum: $(ha core states get input_number.max_hum 2>/dev/null | grep -o '"state":"[^"]*"' | cut -d'"' -f4 || echo 'недоступно')"
echo "   ruchnoi_rezhim: $(ha core states get input_boolean.ruchnoi_rezhim 2>/dev/null | grep -o '"state":"[^"]*"' | cut -d'"' -f4 || echo 'недоступно')"
echo "   avtomaticheskii_rezhim: $(ha core states get input_boolean.avtomaticheskii_rezhim 2>/dev/null | grep -o '"state":"[^"]*"' | cut -d'"' -f4 || echo 'недоступно')"

echo ""
echo "3. Проверка базы данных recorder:"
if [ -f "/config/.storage/home-assistant_v2.db" ]; then
    echo "   ✓ База данных существует"
    DB_SIZE=$(stat -f%z "/config/.storage/home-assistant_v2.db" 2>/dev/null || stat -c%s "/config/.storage/home-assistant_v2.db" 2>/dev/null)
    echo "   Размер базы данных: $DB_SIZE байт"
else
    echo "   ⚠ База данных не найдена (может быть создана позже)"
fi

echo ""
echo "=========================================="
echo "ИНСТРУКЦИЯ ПО ПРОВЕРКЕ:"
echo "=========================================="
echo "1. Измените любую настройку (например, min_temp)"
echo "2. Подождите 5-10 секунд"
echo "3. Запишите текущее значение"
echo "4. Перезагрузите Home Assistant: ha core restart"
echo "5. После перезагрузки проверьте, что значение сохранилось"
echo ""
echo "Для просмотра всех input_number entities:"
echo "  ha core states list | grep input_number"
echo ""
echo "Для просмотра всех input_boolean entities:"
echo "  ha core states list | grep input_boolean"
echo ""

