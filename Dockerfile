FROM lnxjedi/gopherbot:amazon

USER root:root

ARG goversion=1.11.4
ENV HOSTNAME=clu.container
ENV PATH=${PATH}:${HOME}/go/bin:/usr/local/go/bin

COPY .env ${CONTEXT}/protected
COPY custom ${CONTEXT}/protected/custom
COPY brain ${CONTEXT}/protected/brain

RUN chown -R ${USER}:${GROUP} ${CONTEXT}/protected && \
  cd /usr/local && \
  curl -L https://dl.google.com/go/go${goversion}.linux-amd64.tar.gz | tar xzf -

USER bin:bin
