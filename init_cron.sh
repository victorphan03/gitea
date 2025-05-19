#!/bin/bash

CRON_JOB="0 4 * * * /home/x79/gitea-data/backup_gitea.sh >> /home/x79/gitea-data/backup_gitea.log 2>&1"

# Kiểm tra nếu dòng lệnh chưa có trong crontab
crontab -l 2>/dev/null | grep -F "$CRON_JOB" >/dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Cron job đã tồn tại, không thêm nữa."
else
    # Thêm dòng lệnh vào crontab hiện tại
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "Đã thêm cron job:"
    echo "$CRON_JOB"
fi
