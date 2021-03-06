#!/usr/bin/env -S docker build --compress -t pvtmert/jupyter -f

FROM debian:stable

RUN apt update
RUN apt install -y python3-pip python3-dev python3
RUN pip3 install jupyter ipython numpy scipy tensorflow keras sklearn pandas

RUN mkdir -p "${HOME:-/root}/.jupyter"

ARG PASSWORD
RUN printf "%s\n%s\n" "${PASSWORD}" "${PASSWORD}" \
	| jupyter notebook password

WORKDIR /data
ENV PORT 8888
EXPOSE ${PORT}
CMD jupyter notebook \
	--allow-root \
	--no-browser \
	--ip=0.0.0.0 \
	--port=${PORT}

