FROM java:openjdk-8-jdk-alpine
MAINTAINER John Bowler <john@memsql.com>

ARG jenkins_home=/home/jenkins
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN apk update

# setup docker
RUN apk add --no-cache docker supervisor

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN supervisord -c /etc/supervisor/conf.d/supervisord.conf

# setup jenkins-slave
RUN apk add --no-cache git openssh-client curl zip unzip bash

ENV JENKINS_HOME ${jenkins_home}

RUN addgroup -g ${gid} ${group} \
    && adduser -h "$JENKINS_HOME" -u ${uid} -G ${group} -s /bin/bash -D ${user}

RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar http://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/2.52/remoting-2.52.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

COPY jenkins-slave /usr/local/bin/jenkins-slave

WORKDIR ${jenkins_home}
USER ${user}

ENTRYPOINT ["jenkins-slave"]
