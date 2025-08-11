#!/bin/bash
USER="$1"
TOKEN="$2"
REPO="qr-tickets"

if [ -z "$USER" ] || [ -z "$TOKEN" ]; then
  echo "Використання: $0 GITHUB_USERNAME GITHUB_TOKEN"
  exit 1
fi

# Ініціалізація git
git init
git checkout -b main
git add .
git commit -m "Add HTML tickets"
git remote add origin https://$USER:$TOKEN@github.com/$USER/$REPO.git
git push -u origin main

# Увімкнення GitHub Pages
curl -u "$USER:$TOKEN"   -X PUT   -H "Accept: application/vnd.github.switcheroo-preview+json"   https://api.github.com/repos/$USER/$REPO/pages   -d '{"source":{"branch":"main","path":"/"}}'

echo "⏳ Очікування 30 секунд..."
sleep 30

# Генерація QR-кодів через Google Chart API
for i in $(seq -w 1 40); do
  final_url="https://$USER.github.io/$REPO/ticket${i}.html"
  qr_url="https://chart.googleapis.com/chart?cht=qr&chs=300x300&chl=$final_url"
  curl -L "$qr_url" -o ticket${i}_qr.png
done

# Пуш QR-кодів
git add *.png
git commit -m "Add final QR codes"
git push

echo "✅ Готово! Перевір: https://$USER.github.io/$REPO/index.html"
