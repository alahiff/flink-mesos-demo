FROM centos:7

RUN yum -y install http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm
RUN yum -y install mesos
RUN yum -y install java

ENV JAVA_HOME /usr/lib/jvm/jre-1.8.0-openjdk/jre
ENV MESOS_NATIVE_JAVA_LIBRARY /usr/lib/libmesos-1.3.0.so

ADD https://s3.amazonaws.com/flink-nightly/flink-1.3-SNAPSHOT-bin-hadoop2.tgz /tmp/flink.tgz
RUN tar xzf /tmp/flink.tgz -C /opt
RUN mv /opt/flink-1.3-SNAPSHOT /opt/flink

ENV _CLIENT_SHIP_FILES flink-python_2.10-1.3-SNAPSHOT.jar,log4j-1.2.17.jar,slf4j-log4j12-1.7.7.jar,log4j.properties
ENV _FLINK_CLASSPATH *

ENV _CLIENT_TM_MEMORY 1024
ENV _CLIENT_TM_COUNT 1
ENV _SLOTS 2

ENV _CLIENT_USERNAME root
ENV _CLIENT_SESSION_ID default

WORKDIR /opt
