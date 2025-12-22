#!/bin/bash

# Скрипт для синхронизации конфигурации с Home Assistant
# Использование: ./sync_to_ha.sh

HA_IP="192.168.100.100"
HA_USER="Polysfrut"
HA_PASS="123qweASD"
HA_SSH_PORT="22222"  # Стандартный порт для SSH add-on в HA

echo "🔄 Синхронизация с Home Assistant..."

# Проверяем доступность Home Assistant
if ! ping -c 1 -W 1 $HA_IP > /dev/null 2>&1; then
    echo "❌ Home Assistant недоступен по адресу $HA_IP"
    exit 1
fi

# Пробуем подключиться через SSH (порт 22222 для SSH add-on)
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -p $HA_SSH_PORT root@$HA_IP "echo 'SSH доступен'" > /dev/null 2>&1; then
    echo "✅ SSH доступен, выполняю git pull..."
    ssh -p $HA_SSH_PORT root@$HA_IP << 'EOF'
        cd /config
        if [ -d .git ]; then
            git pull origin main
            echo "✅ Конфигурация обновлена через Git"
        else
            echo "⚠️  Git не инициализирован в /config"
            echo "Инициализирую Git..."
            git init
            git remote add origin https://github.com/polysfrut/HomeAssistant-FERMA.git
            git fetch origin
            git checkout -b main origin/main
            echo "✅ Git инициализирован и синхронизирован"
        fi
EOF
else
    echo "⚠️  SSH недоступен на порту $HA_SSH_PORT"
    echo ""
    echo "📋 Инструкция для ручной синхронизации:"
    echo ""
    echo "1. Откройте Home Assistant: http://$HA_IP:8123"
    echo "2. Установите SSH & Web Terminal add-on:"
    echo "   - Settings → Add-ons → Add-on Store"
    echo "   - Найдите 'SSH & Web Terminal'"
    echo "   - Установите и запустите"
    echo ""
    echo "3. Или установите Git pull add-on:"
    echo "   - Найдите 'Git pull' в Add-on Store"
    echo "   - Настройте:"
    echo "     Repository: https://github.com/polysfrut/HomeAssistant-FERMA.git"
    echo "     Branch: main"
    echo "     Repeat: startup"
    echo ""
    echo "4. После установки SSH add-on запустите этот скрипт снова"
fi

echo ""
echo "✨ Готово!"

