HOST=$1

./common-config.sh
./apt-restore.sh $HOST
./hosts/$HOST/config.sh

