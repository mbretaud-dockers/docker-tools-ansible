FROM alpine-python:3.11

# Metadata params
ARG ANSIBLE_VERSION=2.8.2

# Packages
ENV PACKAGES="\
        ca-certificates \
        git \
        openssh-client \
        openssl \
        python3\
        rsync \
        sshpass \
    "
ENV VIRTUAL_PACKAGES="\
        .build-deps \
        python3-dev \
        libffi-dev \
        openssl-dev \
        build-base \
    "
ENV PYTHON_PACKAGES="\
        pip \
        cffi \
    "

RUN set -ex ;\
    # Install packages
    apk update \
      && apk --no-cache add $PACKAGES \
      && apk add --virtual $VIRTUAL_PACKAGES ;\

    # Install Python packages
    pip3 install --upgrade $PYTHON_PACKAGES ;\

    # Install Ansible packages
    pip3 install ansible==${ANSIBLE_VERSION} ansible-lint ;\

    # Remove build dependencies and any leftover apk cache
    apk del .build-deps ;\
    rm -rf /var/cache/apk/*

ARG uid=1000
ARG gid=1000

RUN mkdir -p /etc/ansible \
 && echo 'localhost' > /etc/ansible/hosts \
 && echo -e """\
\n\
Host *\n\
    StrictHostKeyChecking no\n\
    UserKnownHostsFile=/dev/null\n\
""" >> /etc/ssh/ssh_config

# Configure environment
RUN mkdir -p /opt/application/ansible
COPY entrypoint.sh /
RUN addgroup --gid ${gid} ansible \
 && adduser --home /opt/application/ansible --disabled-password --gecos "" --uid ${uid} --ingroup ansible ansible \
 && mkdir -p /opt/application/ansible/playbooks \
 && mkdir -p /opt/application/ansible/modules \
 && mkdir -p /opt/application/ansible/roles \
 && chown -R ansible:ansible /opt/application/ansible \
 && chmod +x /entrypoint.sh

# Environment variables for Ansible
ENV ANSIBLE_ROLES_PATH=/opt/application/ansible/roles
ENV ANSIBLE_LIBRARY=/opt/application/ansible/modules
ENV ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3.8

# Workspace
WORKDIR /opt/application/ansible/playbooks

USER ansible

CMD ["/bin/bash"]

ENTRYPOINT ["/entrypoint.sh"]