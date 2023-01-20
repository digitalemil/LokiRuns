FROM grafana/agent:main

RUN apt-get update -y
RUN apt-get upgrade -y 

COPY lokiruns-agent-config.yaml /opt

ENTRYPOINT /bin/agent -config.expand-env -enable-features integrations-next --config.file=/opt/lokiruns-agent-config.yaml

