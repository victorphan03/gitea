#!/bin/bash

BACKUP_DIR="$HOME/gitea-backups"
VOLUME_NAME="gitea_data"
DATE=$(date +%F_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/gitea_backup_$DATE.tar.gz"
RCLONE_REMOTE="gdrive"
RCLONE_REMOTE_DIR="GiteaBackups"

mkdir -p "$BACKUP_DIR"

echo ">>> Dừng container Gitea..."
docker-compose down

echo ">>> Backup volume $VOLUME_NAME sang file $BACKUP_FILE ..."
docker run --rm -v $VOLUME_NAME:/volume -v "$BACKUP_DIR":/backup busybox \
    tar czvf "/backup/gitea_backup_$DATE.tar.gz" -C /volume .

echo ">>> Khởi động lại container Gitea..."
docker-compose up -d

echo ">>> Upload file backup lên Google Drive ($RCLONE_REMOTE:$RCLONE_REMOTE_DIR)..."
rclone copy "$BACKUP_FILE" "$RCLONE_REMOTE:$RCLONE_REMOTE_DIR" --progress

echo ">>> Xóa thư mục backup $BACKUP_DIR để giải phóng dung lượng..."
rm -rf "$BACKUP_DIR"

echo ">>> Hoàn tất backup, upload và dọn dẹp!"
