
FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget curl unzip tar git ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install OpenJDK 23 (early access)
RUN wget  https://download.java.net/java/GA/jdk23.0.2/6da2a6609d6e406f85c491fcb119101b/7/GPL/openjdk-23.0.2_linux-x64_bin.tar.gz && \
    tar -xzf openjdk-23.0.2_linux-x64_bin.tar.gz && \
    mv jdk-23.0.2 /opt/openjdk-23 && \
    rm openjdk-23.0.2_linux-x64_bin.tar.gz

ENV JAVA_HOME=/opt/openjdk-23
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install Maven 3.9.9
ENV MAVEN_VERSION=3.9.11
ENV MAVEN_HOME=/opt/maven

RUN wget https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    mv apache-maven-${MAVEN_VERSION} ${MAVEN_HOME} && \
    rm apache-maven-${MAVEN_VERSION}-bin.tar.gz

ENV PATH="${MAVEN_HOME}/bin:${PATH}"

WORKDIR /opt

COPY . /opt/extremexp-dsl-framework

WORKDIR /opt/extremexp-dsl-framework/eu.extremexp.dsl.parent
RUN mvn clean install

WORKDIR /opt/extremexp-dsl-framework/eu.extremexp.dsl.parent/eu.extremexp.dsl.ide
RUN mvn install -Plang-server

RUN mkdir /opt/log

# one trick is to use same user name with the code-server to find the files
RUN useradd -m -g root -s /bin/bash user && \
    echo "user:password" | chpasswd && \
    mkdir -p /home/user/workspace

# default language server port
EXPOSE 5007

CMD ["bash", "-c", "/opt/extremexp-dsl-framework/launch.sh 2>/opt/logs/erros.log >/opt/logs/access.log"]

