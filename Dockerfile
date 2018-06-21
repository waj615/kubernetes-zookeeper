FROM java:8

LABEL name="zookeeper" version="3.4.8"
ENV TZ=Asia/Shanghai

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY entrypoint.sh /entrypoint.sh
ADD zookeeper-3.4.8.tar.gz /opt

RUN apk add --no-cache bash \
    && chmod +x /entrypoint.sh \
    && mv /opt/zookeeper-3.4.8 /opt/zookeeper \
    && mkdir -p /opt/zookeeper/conf /opt/zookeeper/data /opt/zookeeper/wal /opt/zookeeper/log

COPY zoo.cfg /opt/zookeeper/conf/zoo.cfg
COPY log4j.properties /opt/zookeeper/conf/log4j.properties

EXPOSE 2181 2888 3888

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/opt/zookeeper/bin/zkServer.sh", "start-foreground" ]
