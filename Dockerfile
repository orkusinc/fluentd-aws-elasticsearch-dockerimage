FROM fluent/fluentd:stable

RUN apk update \
    && apk add ruby-dev \
    && apk add build-base \
    && fluent-gem install fluent-plugin-aws-elasticsearch-service \
    && fluent-gem install fluent-plugin-record-modifier \
    && fluent-gem install fluent-plugin-concat \
    && gem sources --clear-all \
    && apk del ruby-dev \
    && apk del build-base \
    && rm -rf /var/cache/apk/*
COPY fluent.conf /fluentd/etc/fluent.conf
