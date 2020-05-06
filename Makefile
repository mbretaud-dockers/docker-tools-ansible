CURRENT_DIR = $(shell pwd)
DOCKER_CONTAINER_NAME=docker-tools-ansible
ANSIBLE_VERSION=2.8.2

buildArgs=--build-arg ANSIBLE_VERSION=$(ANSIBLE_VERSION)
containerName=$(DOCKER_CONTAINER_NAME)
containerPublish=
containerVolumes=
containerImage=$(DOCKER_CONTAINER_NAME):$(ANSIBLE_VERSION)

$(info ############################################### )
$(info # )
$(info # Environment variables )
$(info # )
$(info ############################################### )
$(info CURRENT_DIR: $(CURRENT_DIR))
$(info DOCKER_CONTAINER_NAME: $(DOCKER_CONTAINER_NAME))
$(info ANSIBLE_VERSION: $(ANSIBLE_VERSION))

$(info )
$(info ############################################### )
$(info # )
$(info # Parameters )
$(info # )
$(info ############################################### )
$(info buildArgs: $(buildArgs))
$(info containerName: $(containerName))
$(info containerPublish: $(containerPublish))
$(info containerVolumes: $(containerVolumes))
$(info containerImage: $(containerImage))
$(info )

include $(CURRENT_DIR)/make-commons-docker.mk
