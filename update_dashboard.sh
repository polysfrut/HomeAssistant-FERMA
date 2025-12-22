#!/bin/bash

# Скрипт для автоматического обновления dashboard в Home Assistant
# Использование: ./update_dashboard.sh

HA_IP="192.168.100.100"
HA_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJlOTBjODJmYjhkMjg0M2QwOTYwYWJmYzdkNjhlNzUwMSIsImlhdCI6MTc2NjQwODQwMSwiZXhwIjoyMDgxNzY4NDAxfQ.WQpY8LHrR6Gx-05QHx9goJ5QHO3bMxALDx2juSlZbzE"
LOCAL_DIR="/Users/polusfrutbozhko/Desktop/HomeAssistant-FERMA"

echo "🔄 Обновление dashboard в Home Assistant..."
echo ""

# Проверяем доступность Home Assistant
if ! curl -s -f -H "Authorization: Bearer $HA_TOKEN" "http://$HA_IP:8123/api/config" > /dev/null; then
    echo "❌ Не удалось подключиться к Home Assistant API"
    exit 1
fi

echo "✅ Подключение к Home Assistant установлено"
echo ""

# Проверяем файл dashboard
DASHBOARD_FILE="$LOCAL_DIR/brooder_dahsboard,yaml"
if [ ! -f "$DASHBOARD_FILE" ]; then
    echo "❌ Файл dashboard не найден: $DASHBOARD_FILE"
    exit 1
fi

echo "✅ Файл dashboard найден"
echo ""

# Проверяем наличие кнопки перезагрузки в файле
if grep -q "Перезагрузка контроллера" "$DASHBOARD_FILE"; then
    echo "✅ Кнопка 'Перезагрузка контроллера' найдена в файле"
else
    echo "❌ Кнопка 'Перезагрузка контроллера' не найдена в файле"
    exit 1
fi

echo ""
echo "📋 Инструкция для выполнения в веб-терминале Home Assistant:"
echo ""
echo "1. Откройте веб-терминал SSH add-on в Home Assistant"
echo ""
echo "2. Выполните следующие команды:"
echo ""
echo "   cd /config"
echo "   git pull origin main"
echo ""
echo "3. Проверьте, что файл обновлен:"
echo ""
echo "   grep -A 3 'Перезагрузка контроллера' brooder_dahsboard,yaml"
echo ""
echo "4. Перезагрузите Home Assistant:"
echo ""
echo "   ha core restart"
echo ""
echo "   Или через веб-интерфейс:"
echo "   Настройки → Система → Перезагрузка → Перезагрузить Home Assistant"
echo ""
echo "5. После перезагрузки обновите страницу в браузере (Ctrl+F5 или Cmd+Shift+R)"
echo ""
echo "✨ Готово! Dashboard должен обновиться."

