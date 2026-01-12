#!/bin/bash
# Скрипт для настройки автоматической аутентификации GitHub через токен
# Выполните этот скрипт на сервере Home Assistant

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Настройка автоматической аутентификации GitHub ===${NC}"

# Токен (будет передан как аргумент или введен)
if [ -z "$1" ]; then
    echo -e "${YELLOW}Использование: bash setup_github_token.sh YOUR_TOKEN${NC}"
    echo -e "${YELLOW}Или введите токен:${NC}"
    read -s GITHUB_TOKEN
else
    GITHUB_TOKEN="$1"
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}Ошибка: токен не указан${NC}"
    exit 1
fi

# Проверяем что мы в правильной директории
if [ ! -f "configuration.yaml" ]; then
    echo -e "${YELLOW}Переход в директорию /config...${NC}"
    cd /config 2>/dev/null || {
        echo -e "${RED}Ошибка: не могу найти директорию /config${NC}"
        exit 1
    }
fi

# Изменяем remote URL чтобы включить токен
echo -e "${YELLOW}Настройка remote URL с токеном...${NC}"
git remote set-url origin https://${GITHUB_TOKEN}@github.com/polysfrut/HomeAssistant-FERMA.git

# Настраиваем credential helper для сохранения токена
echo -e "${YELLOW}Настройка credential helper...${NC}"
git config --global credential.helper store

# Сохраняем токен в credential store
echo "https://polysfrut:${GITHUB_TOKEN}@github.com" > ~/.git-credentials
chmod 600 ~/.git-credentials

# Альтернативный способ - через git config (менее безопасно, но работает)
git config --global credential.https://github.com.username polysfrut
echo "$GITHUB_TOKEN" | git credential approve <<EOF
protocol=https
host=github.com
username=polysfrut
password=${GITHUB_TOKEN}
EOF

echo -e "${GREEN}✅ Токен настроен!${NC}"

# Проверяем подключение
echo -e "${YELLOW}Проверка подключения...${NC}"
if git ls-remote origin > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Подключение к GitHub успешно!${NC}"
else
    echo -e "${RED}❌ Ошибка подключения к GitHub${NC}"
    echo -e "${YELLOW}Проверьте токен и попробуйте снова${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}=== Готово! ===${NC}"
echo -e "${YELLOW}Теперь git push будет работать автоматически без ввода пароля${NC}"
echo ""
echo -e "${BLUE}Для синхронизации используйте:${NC}"
echo -e "  bash sync_to_github.sh"

