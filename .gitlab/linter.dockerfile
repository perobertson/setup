FROM python:3.12-slim

RUN apt-get update && apt-get install -y \
        bash \
        curl \
        git-core \
        pipx \
    && useradd \
        --user-group \
        --create-home \
        --shell=/bin/bash \
        linter \
    && cd /tmp \
    && curl -sSLO https://github.com/go-task/task/releases/download/v3.35.1/task_linux_amd64.deb \
    && apt-get install ./task_linux_amd64.deb \
    && ln -s /usr/bin/task /usr/local/bin/go-task \
    && rm task_linux_amd64.deb

USER linter
WORKDIR /home/linter
ENV PATH="/home/linter/.local/bin:${PATH}"

COPY --chown=linter:linter bootstrap/install_ansible.bash /tmp
RUN /tmp/install_ansible.bash \
    && pipx inject --include-apps --include-deps ansible ansible-lint \
    && pipx install yamllint \
    && ansible-lint --version \
    && yamllint --version \
    && rm /tmp/install_ansible.bash
