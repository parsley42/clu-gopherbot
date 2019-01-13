FROM lnxjedi/gopherbot:amazon

USER root:root

ARG goversion=1.11.4
ENV HOSTNAME=clu.container
ENV PATH=${PATH}:${HOME}/go/bin:/usr/local/go/bin

COPY .env ${HOME}

RUN chown bin:bin .env && \
  chmod 0400 .env && \
  yum -y install \
    gcc \
    zip && \
  yum clean all && \
  rm -rf /var/cache/yum && \
  cd /usr/local && \
  curl -L https://dl.google.com/go/go${goversion}.linux-amd64.tar.gz | tar xzf -

USER ${USER}:${GROUP}

# Uncomment for debugging start-up issues
#ENTRYPOINT [ ]
