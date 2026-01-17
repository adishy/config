HOST=$1

./common-install.sh
./apt-restore.sh $HOST
./hosts/$HOST/install.sh

