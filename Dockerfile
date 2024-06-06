FROM openjdk:17-jdk-slim

ENV LANG C.UTF-8
ENV JAVA_TOOL_OPTIONS -XX:+UseContainerSupport

RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    vim\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN wget https://apache.osuosl.org/maven/maven-3/3.9.7/binaries/apache-maven-3.9.7-bin.zip \
    && unzip apache-maven-3.9.7-bin.zip \
    && mv apache-maven-3.9.7 /opt/maven \
    && ln -s /opt/maven/bin/mvn /usr/bin/mvn \
    && rm apache-maven-3.9.7-bin.zip

ENV MAVEN_HOME /opt/maven
ENV PATH $MAVEN_HOME/bin:$PATH

COPY . /opt/extremexp-dsl-framework

WORKDIR /opt/extremexp-dsl-framework/eu.extremexp.dsl.parent
RUN mvn clean install

RUN mkdir /opt/log
RUN mkdir /home/user

EXPOSE 5007

CMD ["bash", "-c", "/opt/extremexp-dsl-framework/launch.sh 2>/opt/log/erros.log >/opt/log/access.log"]

