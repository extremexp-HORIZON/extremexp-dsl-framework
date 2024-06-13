FROM openjdk:17-jdk-slim

ENV LANG C.UTF-8
ENV JAVA_TOOL_OPTIONS -XX:+UseContainerSupport

# we dont need vim for release
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    vim\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

# the actual project use mvn-3.8, but we can use a newer one with tycho 4.0.8
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

WORKDIR /opt/extremexp-dsl-framework/eu.extremexp.dsl.parent/eu.extremexp.dsl.ide
RUN mvn install -Plang-server

RUN mkdir /opt/log

# one trick is to use same user name with the code-server to find the files
RUN useradd -m -s /bin/bash user && \
    echo "user:password" | chpasswd && \
    mkdir -p /home/user/workspace

# default language server port
EXPOSE 5007

CMD ["bash", "-c", "/opt/extremexp-dsl-framework/launch.sh 2>/opt/logs/erros.log >/opt/logs/access.log"]

