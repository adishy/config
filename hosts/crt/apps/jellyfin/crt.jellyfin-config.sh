
# 6. DIRECTORY PERMISSIONS

MAIN_DIR="$HOME/personal.data.adishy.com"
APP_DATA_BASE_DIR="$MAIN_DIR/tmp/apps/jellyfin"
CACHE_DIR="$APP_DATA_BASE_DIR/cache"
CONFIG_DIR="$APP_DATA_BASE_DIR/config"

echo "Setting up directories Jellyfin..."
echo "Directories: [$CACHE_DIR, $CONFIG_DIR]"
mkdir -p $CACHE_DIR $CONFIG_DIR
sudo chown -R 1000:1000 $CACHE_DIR $CONFIG_DIR
chmod -R 775 $CACHE_DIR $CONFIG_DIR

echo "Complete!"
echo "Created in $APP_DATA_BASE_DIR"
ls -l $APP_DATA_BASE_DIR
