FROM ruby:2.4.1

MAINTAINER Kouhei Sutou <kou@clear-code.com>

RUN \
  apt update && \
  apt install apt-transport-https && \
  echo "deb https://packages.groonga.org/debian/ jessie main" > \
    /etc/apt/sources.list.d/groonga.list && \
  apt update && \
  apt install -y --allow-unauthenticated groonga-keyring && \
  apt update && \
  apt install -y libarrow-glib-dev

RUN mkdir /app
WORKDIR /app
COPY . /app
RUN bundle install

