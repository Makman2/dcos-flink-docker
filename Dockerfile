FROM mesosphere/mesos:1.0.1-2.0.93.ubuntu1404

# The base image contains java 7, but it has no environment variables set for it.
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64/jre
#ENV MESOS_NATIVE_JAVA_LIBRARY /usr/lib/libmesos-1.0.1.so

# TODO Change to flink stable 1.2 version
RUN apt-get update \
    && apt-get -y install curl \
    && curl https://s3.amazonaws.com/flink-nightly/flink-1.2-SNAPSHOT-bin-hadoop2.tgz \
    | tar -xz

#ENV MESOS_SANDBOX flink-1.2-SNAPSHOT
COPY conf/ flink-1.2-SNAPSHOT/conf/
WORKDIR flink-1.2-SNAPSHOT

ENV _CLIENT_SHIP_FILES flink-python_2.10-1.2-SNAPSHOT.jar,log4j-1.2.17.jar,slf4j-log4j12-1.7.7.jar,log4j.properties
ENV _FLINK_CLASSPATH *

# TODO Shouldn't this be something inside flink-conf.yaml ???
ENV _CLIENT_TM_MEMORY 1024
ENV _CLIENT_TM_COUNT 1
ENV _SLOTS 2
ENV _CLIENT_USERNAME root
ENV _CLIENT_SESSION_ID default

# TODO The flink config needs to be in the sandbox. This should be definitely changed to the working directory in code.
CMD ln -s $(pwd)/lib/flink-dist_2.10-1.2-SNAPSHOT.jar $MESOS_SANDBOX/flink.jar \
    && ln -s $(pwd)/lib/flink-python_2.10-1.2-SNAPSHOT.jar $MESOS_SANDBOX/flink-python_2.10-1.2-SNAPSHOT.jar \
    && ln -s $(pwd)/lib/log4j-1.2.17.jar $MESOS_SANDBOX/log4j-1.2.17.jar \
    && ln -s $(pwd)/lib/slf4j-log4j12-1.7.7.jar $MESOS_SANDBOX/slf4j-log4j12-1.7.7.jar \
    && ln -s $(pwd)/conf/flink-conf.yaml $MESOS_SANDBOX/flink-conf.yaml \
    && ln -s $(pwd)/conf/log4j.properties $MESOS_SANDBOX/log4j.properties \
    && $JAVA_HOME/bin/java -cp "lib/*" -Dlog.file=jobmaster.log -Dlog4j.configuration=file:log4j.properties org.apache.flink.mesos.runtime.clusterframework.MesosApplicationMasterRunner --configDir .
