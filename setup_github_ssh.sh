#!/bin/bash
# Скрипт для настройки автоматической синхронизации с GitHub через SSH
# Выполните этот скрипт на сервере Home Assistant

echo "=== Настройка автоматической синхронизации с GitHub ==="

# Проверяем есть ли SSH ключ для GitHub
if [ ! -f ~/.ssh/id_ed25519_github ]; then
    echo "Создание SSH ключа для GitHub..."
    ssh-keygen -t ed25519 -C "github-sync@hassio" -f ~/.ssh/id_ed25519_github -N ""
    echo "✅ SSH ключ создан"
else
    echo "✅ SSH ключ уже существует"
fi

# Показываем публичный ключ
echo ""
echo "=== ПУБЛИЧНЫЙ SSH КЛЮЧ (скопируйте его) ==="
cat ~/.ssh/id_ed25519_github.pub
echo ""
echo "=== КОНЕЦ КЛЮЧА ==="
echo ""

# Настраиваем SSH config
if [ ! -f ~/.ssh/config ]; then
    touch ~/.ssh/config
    chmod 600 ~/.ssh/config
fi

# Добавляем конфигурацию для GitHub (если еще нет)
if ! grep -q "Host github.com" ~/.ssh/config; then
    cat >> ~/.ssh/config << 'EOF'

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github
    IdentitiesOnly yes
    StrictHostKeyChecking no
EOF
    echo "✅ SSH config обновлен"
else
    echo "✅ SSH config уже настроен"
fi

# Изменяем remote URL на SSH
cd /config
CURRENT_REMOTE=$(git remote get-url origin)
if [[ "$CURRENT_REMOTE" == *"https://"* ]]; then
    echo "Изменение remote URL на SSH..."
    git remote set-url origin git@github.com:polysfrut/HomeAssistant-FERMA.git
    echo "✅ Remote URL изменен на SSH"
else
    echo "✅ Remote URL уже использует SSH"
fi

# Проверяем подключение
echo ""
echo "Проверка подключения к GitHub..."
ssh -T git@github.com 2>&1 | head -1

echo ""
echo "=== ИНСТРУКЦИИ ==="
echo "1. Скопируйте публичный ключ выше"
echo "2. Откройте: https://github.com/settings/ssh/new"
echo "3. Вставьте ключ и нажмите 'Add SSH key'"
echo "4. После этого git push будет работать без пароля!"
echo ""

