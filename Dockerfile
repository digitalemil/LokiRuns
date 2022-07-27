FROM grafana/agent:v0.25.1

RUN apt-get update -y
RUN apt-get upgrade -y 

COPY lokiruns-agent-config.yaml /opt

ENTRYPOINT /bin/agent -config.expand-env -enable-features integrations-next --config.file=/opt/lokiruns-agent-config.yaml

