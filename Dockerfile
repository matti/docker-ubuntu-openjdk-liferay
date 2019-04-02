FROM ubuntu:18.04 as builder

RUN apt-get update && apt-get upgrade -y
RUN apt-get update && apt-get install -y \
  p7zip-full

WORKDIR /
ADD https://downloads.sourceforge.net/project/lportal/Liferay%20Portal/7.1.2%20GA3/liferay-ce-portal-tomcat-7.1.2-ga3-20190107144105508.7z?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Flportal%2Ffiles%2FLiferay%2520Portal%2F7.1.2%2520GA3%2Fliferay-ce-portal-tomcat-7.1.2-ga3-20190107144105508.7z%2Fdownload%3Fuse_mirror%3Dkent&ts=1554186123&use_mirror=kent .

RUN ls -l
RUN 7z x liferay-ce-portal-tomcat-7.1.2-ga3-20190107144105508.7z
RUN mv liferay-ce-portal-7.1.2-ga3 /liferay

ADD https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz .
RUN ls -l
WORKDIR /openjdk
RUN tar --extract --file /openjdk-11.0.2_linux-x64_bin.tar.gz --directory "/openjdk" --strip-components 1

FROM ubuntu:18.04
ENV JAVA_HOME=/opt/openjdk
ENV PATH=/opt/openjdk/bin:$PATH

# https://github.com/docker-library/openjdk/blob/master/11/jdk/oracle/Dockerfile#L8
# https://bugs.launchpad.net/ubuntu/+source/openjdk-lts/+bug/1780151

COPY --from=builder /openjdk /opt/openjdk/

# https://github.com/docker-library/openjdk/blob/master/11/jdk/oracle/Dockerfile#L45
# "you may want to use class data sharing archive in the OpenJDK image, to improve startup time and memory sharing. While there is a JEP to make CDS part of the default build at http://openjdk.java.net/jeps/341 at some point in the future, -Xshare:dump still needs to be run on install in current releases.""

RUN java -Xshare:dump && \
  useradd -ms /bin/bash liferay && \
  apt-get update && apt-get upgrade -y && \
  apt-get install --no-install-recommends -y \
  netcat-openbsd curl wget nano htop iputils-ping \
  fontconfig libfontconfig1 libfreetype6 && \
  rm -rf /var/lib/apt/lists/*

COPY --chown=liferay:liferay --from=builder /liferay /app

WORKDIR /app
USER liferay
