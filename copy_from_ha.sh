#!/bin/bash

# Скрипт для копирования всех файлов конфигурации из Home Assistant
# Использование: ./copy_from_ha.sh

HA_IP="192.168.100.100"
HA_SSH_PORT="22"
HA_USER="root"
LOCAL_DIR="/Users/polusfrutbozhko/Desktop/HomeAssistant-FERMA"
REMOTE_DIR="/config"

echo "📋 Копирование файлов из Home Assistant..."
echo "IP: $HA_IP"
echo "Директория: $REMOTE_DIR"
echo ""

# Проверяем SSH доступ
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -p $HA_SSH_PORT $HA_USER@$HA_IP "echo 'SSH OK'" > /dev/null 2>&1; then
    echo "✅ SSH доступен"
    
    # Создаем резервную копию текущих файлов
    echo "📦 Создаю резервную копию локальных файлов..."
    BACKUP_DIR="${LOCAL_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp -r "$LOCAL_DIR"/* "$BACKUP_DIR/" 2>/dev/null
    echo "✅ Резервная копия создана: $BACKUP_DIR"
    
    # Копируем файлы через rsync (исключаем большие файлы БД и логи)
    echo "📥 Копирую файлы конфигурации..."
    rsync -avz --progress \
        --exclude='*.db' \
        --exclude='*.db-shm' \
        --exclude='*.db-wal' \
        --exclude='*.log' \
        --exclude='*.log.*' \
        --exclude='.storage/' \
        --exclude='deps/' \
        --exclude='tts/' \
        --exclude='www/' \
        --exclude='.git/' \
        -e "ssh -p $HA_SSH_PORT -o StrictHostKeyChecking=no" \
        $HA_USER@$HA_IP:$REMOTE_DIR/ \
        $LOCAL_DIR/
    
    echo ""
    echo "✅ Копирование завершено!"
    echo "📋 Проверьте файлы в: $LOCAL_DIR"
else
    echo "❌ SSH недоступен на порту $HA_SSH_PORT"
    echo ""
    echo "📋 Используйте веб-терминал Home Assistant:"
    echo ""
    echo "1. Откройте веб-терминал SSH add-on"
    echo "2. Выполните команды для создания архива:"
    echo ""
    echo "   cd /config"
    echo "   tar -czf /tmp/ha_config_backup.tar.gz \\"
    echo "     --exclude='*.db' \\"
    echo "     --exclude='*.db-shm' \\"
    echo "     --exclude='*.db-wal' \\"
    echo "     --exclude='*.log*' \\"
    echo "     --exclude='.storage' \\"
    echo "     --exclude='deps' \\"
    echo "     --exclude='tts' \\"
    echo "     --exclude='www' \\"
    echo "     --exclude='.git' \\"
    echo "     ."
    echo ""
    echo "3. Затем скачайте архив через File Editor или используйте:"
    echo "   curl -H 'Authorization: Bearer YOUR_TOKEN' \\"
    echo "        http://$HA_IP:8123/api/hassio/supervisor/snapshots/download/ARCHIVE_NAME"
fi

