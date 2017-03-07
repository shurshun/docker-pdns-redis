FROM shurshun/pdns

LABEL maintainer "4lifenet@gmail.com"

ENV PDNS_REDIS_MASTER="REMOTE_REDIS 6390"

RUN set -ex \
	&& apk add --no-cache \
		redis lua-hiredis

ADD conf/ /etc/
ADD bin/  /bin/

RUN echo "slaveof $PDNS_REDIS_MASTER" >> /etc/redis.conf

CMD ["entrypoint.sh"]