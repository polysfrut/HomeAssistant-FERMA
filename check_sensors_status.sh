#!/bin/bash
# Скрипт для проверки статуса датчиков и определения правильного номера

echo "=========================================="
echo "ПРОВЕРКА ДАТЧИКОВ ТЕМПЕРАТУРЫ И ВЛАЖНОСТИ"
echo "=========================================="
echo ""

echo "Проверка датчиков температуры:"
echo "--------------------------------"
ha core states list | grep "sensor.waveshare001_rs485_temperature" | head -5

echo ""
echo "Проверка датчиков влажности:"
echo "--------------------------------"
ha core states list | grep "sensor.waveshare001_rs485_humidity" | head -5

echo ""
echo "=========================================="
echo "ТЕКУЩЕЕ ИСПОЛЬЗОВАНИЕ В КОНФИГУРАЦИИ:"
echo "=========================================="
echo ""
echo "В автоматизациях (packages/brooder.yaml):"
grep -o "sensor.waveshare001_rs485_temperature_1[01]" packages/brooder.yaml | sort -u
grep -o "sensor.waveshare001_rs485_humidity_1[01]" packages/brooder.yaml | sort -u

echo ""
echo "В dashboard (ui-lovelace.yaml):"
grep -o "sensor.waveshare001_rs485_temperature_1[01]" ui-lovelace.yaml | sort -u
grep -o "sensor.waveshare001_rs485_humidity_1[01]" ui-lovelace.yaml | sort -u

echo ""
echo "=========================================="
echo "РЕКОМЕНДАЦИЯ:"
echo "=========================================="
echo "Если датчики _10 и _11 оба существуют, нужно выбрать один и использовать везде."
echo "Если правильный датчик _11, нужно обновить автоматизации."
echo "Если правильный датчик _10, нужно обновить dashboard."
echo ""

