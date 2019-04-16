FROM lnxjedi/gopherbot:amazon

USER root:root
ENV HOSTNAME=clu.container

# Customisation section. For Clu, it installs gcc, zip
# and Go - needed to build Gopherbot.
ARG goversion=1.12.4
ENV PATH=${PATH}:${HOME}/go/bin:/usr/local/go/bin

RUN yum -y install \
    gcc \
    zip && \
  yum clean all && \
  rm -rf /var/cache/yum && \
  cd /usr/local && \
  curl -L https://dl.google.com/go/go${goversion}.linux-amd64.tar.gz | tar xzf -
# /end Customisation

COPY .env ${HOME}

RUN chown bin:bin .env && \
  chmod 0400 .env

USER ${USER}:${GROUP}

# Uncomment for debugging start-up issues
#ENTRYPOINT [ ]
