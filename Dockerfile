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
 && echo '[local]' > /etc/ansible/hosts \
 && echo '192.168.1.37' > /etc/ansible/hosts \
 && echo -e """\
\n\
Host *\n\
    Port 22\n\
    IdentityFile ~/.ssh/id_rsa\n\
    StrictHostKeyChecking no\n\
    UserKnownHostsFile=/dev/null\n\
""" >> /etc/ssh/ssh_config

# Configure environment
RUN mkdir -p /opt/application/ansible \
 && mkdir -p /opt/application/ansible/.ssh

ADD ansible/hosts /etc/ansible/hosts
ADD entrypoint.sh /opt/application/ansible/entrypoint.sh
ADD ssh/id_rsa /opt/application/ansible/.ssh/id_rsa
ADD ssh/id_rsa.pub /opt/application/ansible/.ssh/id_rsa.pub
ADD ssh/authorized_keys /opt/application/ansible/.ssh/authorized_keys

RUN addgroup --gid ${gid} ansible \
 && adduser --home /opt/application/ansible --disabled-password --gecos "" --uid ${uid} --ingroup ansible ansible \
 && mkdir -p /opt/application/ansible/playbooks \
 && mkdir -p /opt/application/ansible/modules \
 && mkdir -p /opt/application/ansible/roles \
 && chown -R ansible:ansible /opt/application/ansible \
 && mkdir -p /opt/application/ansible/.ssh \
 && chmod 700 /opt/application/ansible/.ssh \
 && chmod 600 /opt/application/ansible/.ssh/id_rsa \
 && chmod 600 /opt/application/ansible/.ssh/id_rsa.pub \
 && ssh-keyscan github.com >> /opt/application/ansible/.ssh/known_hosts \ 
 && chown -R ansible:ansible /opt/application/ansible/.ssh \
 && chmod +x /opt/application/ansible/entrypoint.sh \
 && chown -R ansible:ansible /opt/application/ansible/entrypoint.sh

# Environment variables for Ansible
ENV ANSIBLE_ROLES_PATH=/opt/application/ansible/roles
ENV ANSIBLE_LIBRARY=/opt/application/ansible/modules
ENV ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3.8

# Workspace
WORKDIR /opt/application/ansible/playbooks

USER ansible

CMD ["/bin/bash"]

ENTRYPOINT ["/opt/application/ansible/entrypoint.sh"]