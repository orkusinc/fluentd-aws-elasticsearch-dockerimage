VERSION_FILE=version.txt
VERSION ?= $(shell test -e $(VERSION_FILE) && cat $(VERSION_FILE) || date -u +"%Y-%m-%dT%H-%M-%SZ"  | tee $(VERSION_FILE))
AWS_REGION ?= us-west-2

CURRENT_WORKING_DIR := $(shell pwd)
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

empty :=

FLUENTD_PORT ?= 24224

ifdef STAGE
	STAGE_STR=-$(STAGE)
else
	STAGE_STR=$(empty)
endif
ifdef CONF_FILE
	CONF_FILE_MOUNT=-v $(CONF_FILE):/fluent/etc/fluent.conf
else
	CONF_FILE_MOUNT=$(empty)
endif

IMAGE_NAME=fluentd-aws-elasticsearch
CONTAINER_NAME=fluentd-aws-elasticsearch$(STAGE_STR)

clean:
	rm -f $(VERSION_FILE)
	rm -f fluent.conf

prepare-config:
	sed -e s@AWS_ELASTICSEARCH_URL@$(AWS_ELASTICSEARCH_URL)@ $(MAKEFILE_DIR)/$(CONF_FILE_TEMPLATE) \
		| sed -e s@AWS_REGION@$(AWS_REGION)@ \
		> $(MAKEFILE_DIR)/fluent.conf

docker-build:
	docker build \
		--file=$(MAKEFILE_DIR)/Dockerfile \
		--tag=$(IMAGE_NAME):$(VERSION) \
		$(MAKEFILE_DIR)

docker-run:
	docker run \
		-d \
		-e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION} \
		--name $(CONTAINER_NAME) \
		-p $(FLUENTD_PORT):24224 \
		-p $(FLUENTD_PORT):24224/udp \
		$(CONF_FILE_MOUNT) \
		$(IMAGE_NAME):$(VERSION)

docker-force-run: docker-rm docker-run

docker-rm:
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)

docker-push:
	docker tag $(IMAGE_NAME):$(VERSION) 264676673172.dkr.ecr.us-west-2.amazonaws.com/$(IMAGE_NAME):latest
	docker push 264676673172.dkr.ecr.us-west-2.amazonaws.com/$(IMAGE_NAME):latest
	docker push $(IMAGE_NAME):latest
