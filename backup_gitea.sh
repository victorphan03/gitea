#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Please chạy script với quyền root hoặc sudo"
  exit 1
fi

BACKUP_DIR="./gitea-backups"    # backup sẽ lưu trong thư mục con gitea-backups của gitea-data
DATE=$(date +%F_%H-%M-%S)
BACKUP_FILE="$BACKUP_DIR/gitea_data_$DATE.tar.gz"
RCLONE_REMOTE="gdrive"
RCLONE_REMOTE_DIR="GiteaBackups"
GITEA_DATA_DIR="./data"         # thư mục data con của gitea-data hiện tại

mkdir -p "$BACKUP_DIR"

echo ">>> Dừng container Gitea..."
docker-compose down

echo ">>> Đặt quyền chmod 777 recursively cho thư mục $GITEA_DATA_DIR ..."
chmod -R 777 "$GITEA_DATA_DIR"

echo ">>> Backup thư mục $GITEA_DATA_DIR sang file $BACKUP_FILE ..."
tar czvf "$BACKUP_FILE" -C "$GITEA_DATA_DIR" .

echo ">>> Khởi động lại container Gitea..."
docker-compose up -d

echo ">>> Upload file backup lên Google Drive ($RCLONE_REMOTE:$RCLONE_REMOTE_DIR)..."
rclone copy "$BACKUP_FILE" "$RCLONE_REMOTE:$RCLONE_REMOTE_DIR" --progress

echo ">>> Xóa thư mục backup $BACKUP_DIR để giải phóng dung lượng..."
rm -rf "$BACKUP_DIR"

echo ">>> Hoàn tất backup, upload và dọn dẹp!"
