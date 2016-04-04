FROM java:openjdk-8-jre-alpine

LABEL name="zookeeper" version="3.4.8"

ADD zookeeper-3.4.8.tar.gz /opt

RUN apk add --no-cache bash \
    && mv /opt/zookeeper-3.4.8 /opt/zookeeper \
    && mkdir -p /opt/zookeeper/conf /opt/zookeeper/data /opt/zookeeper/wal /opt/zookeeper/log

COPY zoo.cfg /opt/zookeeper/conf/zoo.cfg
COPY log4j.properties /opt/zookeeper/conf/log4j.properties

ENV PATH=/opt/zookeeper/bin:${PATH} \
    ZOO_LOG_DIR=/opt/zookeeper/log \
    ZOO_LOG4J_PROP="INFO, CONSOLE, ROLLINGFILE" \
    JMXPORT=9010

EXPOSE 2181 2888 3888 9010

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "zkServer.sh", "start-foreground" ]