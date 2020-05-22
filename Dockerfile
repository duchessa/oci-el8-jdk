FROM oraclelinux:8

LABEL maintainer="ali.r <at> beautyandbellies.com"

ARG NODE_VERSION=12
ARG GRAAL_VERSION=20.1.0
ARG JDK_VERSION=11
ARG M2_VERSION=3.6.3

USER root

# Enable "CodeReady" Repository
RUN dnf config-manager --set-enabled ol8_codeready_builder

# Enable sbt Repository
RUN curl --retry 5 https://bintray.com/sbt/rpm/rpm > /etc/yum.repos.d/bintray-sbt-rpm.repo

# Update image, sbt, node and development tools
RUN dnf -y module enable nodejs:${NODE_VERSION} \
  && dnf -y distro-sync \
  && dnf -y update \
  && dnf -y module install nodejs/development \
  && dnf -y --exclude java-* group install --with-optional --skip-broken "Development Tools" "RPM Development Tools" \
  && dnf -y install \
    sudo \
    bzip2-devel \
    tar \
    gzip \
    unzip \
    zip \
    xz-devel \
    rsync \
    git \
    gpg \
    openssh-clients \
    openssl-devel \
    ed \
    gcc-gfortran \
    glibc-static \
    zlib-devel \
    zlib-static \
    fontconfig \
    libcurl-devel \
    readline-devel \
    graphviz \
    sbt \
  && dnf clean all

# Install Graal VM / JDK
ENV JAVA_HOME=/opt/graalvm-ce-java${JDK_VERSION}-${GRAAL_VERSION}
RUN curl -L --retry 5 https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-${GRAAL_VERSION}/graalvm-ce-java${JDK_VERSION}-linux-amd64-${GRAAL_VERSION}.tar.gz | tar xzf - -C /opt
RUN ${JAVA_HOME}/bin/gu install native-image
RUN for ex in "${JAVA_HOME}/bin/"*; do f="$(basename "${ex}")"; [ ! -e "/usr/bin/${f}" ]; alternatives --install "/usr/bin/${f}" "${f}" "${ex}" 30000; done
# Ensure distribution npm takes precedence over Graal npm
RUN alternatives --install /usr/bin/npm npm /usr/lib/node_modules/npm/bin/npm-cli.js 40000

# Install Maven
RUN curl -L --retry 5 http://www-us.apache.org/dist/maven/maven-3/${M2_VERSION}/binaries/apache-maven-${M2_VERSION}-bin.tar.gz | tar xzf - -C /opt
RUN alternatives --install /usr/bin/mvn mvn /opt/apache-maven-${M2_VERSION}/bin/mvn 30000
