FROM node:14

RUN mkdir app
COPY app/ app

WORKDIR app

EXPOSE 3000
CMD DEBUG=* ./bin/www
