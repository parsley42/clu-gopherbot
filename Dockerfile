FROM lnxjedi/gopherbot:amazon

USER root:root

ARG goversion=1.11.4
ENV HOSTNAME=clu.container
ENV PATH=${PATH}:${HOME}/go/bin:/usr/local/go/bin

COPY .env ${HOME}
COPY brain ${HOME}/brain

RUN chown -R bin:bin .env brain/ && \
  chmod 0400 .env && \
  cd /usr/local && \
  curl -L https://dl.google.com/go/go${goversion}.linux-amd64.tar.gz | tar xzf -

USER ${USER}:${GROUP}

#ENTRYPOINT [ ]
