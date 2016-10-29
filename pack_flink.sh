set -e

mkdir -p flink/flink-1.2-SNAPSHOT
cp -v -a ~/dev/makman2-flink/build-target/. ~/dev/dcos-flink-docker/flink/flink-1.2-SNAPSHOT/.
cd ~/dev/dcos-flink-docker/flink
tar -cvzf flink-1.2-DEV-SNAPSHOT-bin-hadoop2.tar.gz flink-1.2-SNAPSHOT
cd ..
docker build -t makman2/dcos-flink .
docker push makman2/dcos-flink
