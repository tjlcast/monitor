rm *.tar.gz

cp -r ../src ./

docker build -t simple-monitor .

rm -rf ./src

docker save simple-monitor > Docker_simple-monitor.tar.gz
