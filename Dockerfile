FROM dordoka/rpi-java8
MAINTAINER dhermanns <docker.hermanns@spamgourmet.com>

ARG DOWNLOAD_URL="https://openhab.ci.cloudbees.com/job/openHAB-Distribution/lastSuccessfulBuild/artifact/distributions/openhab-online/target/openhab-online-2.0.0-SNAPSHOT.zip"
ENV APPDIR="/openhab" OPENHAB_HTTP_PORT='8080' OPENHAB_HTTPS_PORT='8443' EXTRA_JAVA_OPTS='-Duser.timezone=Europe/Berlin'

# Install Basepackages
RUN \
    apt-get update && \
    apt-get install --no-install-recommends -y \
      software-properties-common \
      sudo \
      unzip \
      wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${APPDIR}

RUN \
    wget --no-check-certificate -nv -O /tmp/openhab.zip ${DOWNLOAD_URL} &&\
    unzip -q /tmp/openhab.zip -d ${APPDIR} &&\
    rm /tmp/openhab.zip

RUN mkdir -p ${APPDIR}/userdata/logs && touch ${APPDIR}/userdata/logs/openhab.log

# Copy directories for host volumes
RUN cp -a /openhab/userdata /openhab/userdata.dist && \
    cp -a /openhab/conf /openhab/conf.dist
COPY files/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

# Expose volume with configuration and userdata dir
VOLUME ${APPDIR}/conf ${APPDIR}/userdata ${APPDIR}/addons
EXPOSE 8080 8443 5555 9124
CMD ["server"]

