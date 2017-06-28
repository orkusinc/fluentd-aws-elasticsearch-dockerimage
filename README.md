# fluentd-aws-elasticsearch-dockerimage
Docker image based on official fluentd, installing necessary plugins for use with AWS ES

The container is supposed to listen on port 24224 (or FLUENTD\_PORT). Since docker has a fluentd log driver, it can get used to ingest other container's log messages.

The messages can get forwarded to an AWS ES instance via https transport.

One drawback of the fluentd log driver is, that the messages are not locally available with `docker logs`. Therefore, 3 example configs are shipped to 1) AWS ES, 2) a mountable local file, 3) to both 1) and 2).

## config
There are 2 ways to provide the config:
### target `prepare-config`
This takes one of the existing or any other self-created config template, replaces some env variables and copies it to fluent.conf.

This file is picked up in the `docker-build`-target and copied into the image and is the preferred way to prepare an image for deployment.

Example:
```bash
make prepare-config \
    AWS_ELASTICSEARCH_URL=https://search-awslogs-xxx.eu-west-1.es.amazonaws.com \
    AWS_REGION=eu-west-1 \
    CONF_FILE_TEMPLATE=fluent-aws.conf.tmpl
```

### mount a config into container
Alternatively, the config can be mounted into the container at runtime. This can be done using an environment variable for the respective make target:
```bash
make docker-run CONF_FILE=$(pwd)/fluent.conf
```

This is the preferred way for local/testing scenarios.


## ENV variables
Variable Name          |Default    |Description
---                    |---        |---
STAGE                  | (empty)   | When set, will set the container-name accordingly. `make docker-run STAGE=dev` => container name: fluentd-aws-elasticsearch-dev
FLUENTD\_PORT          | 24224     | Which port to export from the container to listen on for incoming log messages.
AWS\_REGION            | eu-west-1 | Used in substitution in case of target `prepare-config`
AWS\_ELASTICSEARCH\_URL| (empty)   | Used in substitution in case of target `prepare-config`
CONF\_FILE\_TEMPLATE   | (empty)   | Used as base config to apply substitutions to in case of target `prepare-config`
CONF\_FILE             | (empty)   | abs path to local conf file which should get mounted into the container with target `docker-run`

## IAM/Permissions
The base setup assumes that the container is allowed to ship messages to AWS ES by role or IP.
In case there is a need to fall back to AWS key and secret, this can be done by amending the config file.

## See also
* https://github.com/atomita/fluent-plugin-aws-elasticsearch-service
* https://hub.docker.com/r/fluent/fluentd/
* https://github.com/fluent/fluentd-docker-image
 
