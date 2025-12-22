#!/bin/bash

# Скрипт для синхронизации конфигурации с Home Assistant через API
# Использование: ./sync_to_ha_api.sh

HA_IP="192.168.100.100"
HA_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJlOTBjODJmYjhkMjg0M2QwOTYwYWJmYzdkNjhlNzUwMSIsImlhdCI6MTc2NjQwODQwMSwiZXhwIjoyMDgxNzY4NDAxfQ.WQpY8LHrR6Gx-05QHx9goJ5QHO3bMxALDx2juSlZbzE"
REPO_URL="https://github.com/polysfrut/HomeAssistant-FERMA.git"

echo "🔄 Синхронизация с Home Assistant..."

# Проверяем доступность Home Assistant
if ! curl -s -f -H "Authorization: Bearer $HA_TOKEN" "http://$HA_IP:8123/api/config" > /dev/null; then
    echo "❌ Не удалось подключиться к Home Assistant API"
    exit 1
fi

echo "✅ Подключение к Home Assistant установлено"

# Проверяем SSH доступ
if ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no -p 22222 root@$HA_IP "echo 'SSH OK'" > /dev/null 2>&1; then
    echo "✅ SSH доступен, выполняю Git синхронизацию..."
    ssh -p 22222 root@$HA_IP << EOF
        cd /config
        if [ -d .git ]; then
            echo "📥 Обновляю репозиторий..."
            git pull origin main
            echo "✅ Конфигурация обновлена"
        else
            echo "📦 Инициализирую Git репозиторий..."
            git init
            git remote add origin $REPO_URL 2>/dev/null || git remote set-url origin $REPO_URL
            git fetch origin
            git checkout -b main 2>/dev/null || git checkout main
            git reset --hard origin/main
            echo "✅ Git репозиторий инициализирован и синхронизирован"
        fi
EOF
    echo ""
    echo "✨ Синхронизация завершена!"
    echo "📋 Проверьте конфигурацию в Home Assistant: http://$HA_IP:8123"
else
    echo "⚠️  SSH недоступен на порту 22222"
    echo ""
    echo "📋 Для автоматической синхронизации установите один из add-ons:"
    echo ""
    echo "1. SSH & Web Terminal:"
    echo "   - Settings → Add-ons → Add-on Store"
    echo "   - Найдите 'SSH & Web Terminal'"
    echo "   - Установите и запустите"
    echo "   - После установки запустите этот скрипт снова"
    echo ""
    echo "2. Git pull add-on:"
    echo "   - Settings → Add-ons → Add-on Store"
    echo "   - Найдите 'Git pull'"
    echo "   - Установите и настройте:"
    echo "     Repository: $REPO_URL"
    echo "     Branch: main"
    echo "     Repeat: startup"
    echo ""
    echo "3. Или скопируйте файлы вручную через File Editor в Home Assistant"
fi

