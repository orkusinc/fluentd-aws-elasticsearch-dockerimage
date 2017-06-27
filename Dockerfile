FROM fluent/fluentd:stable

RUN fluent-gem install fluent-plugin-aws-elasticsearch-service \
	&& gem sources --clear-all \
	&& rm -rf /var/cache/apk/* 
COPY fluent.conf /fluentd/etc/fluent.conf
