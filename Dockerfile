FROM ruby:2.4.1

MAINTAINER Kouhei Sutou <kou@clear-code.com>

RUN \
  echo "deb http://packages.groonga.org/debian/ jessie main" > \
    /etc/apt/sources.list.d/groonga.list && \
  sudo apt update && \
  sudo apt install -y --allow-unauthenticated groonga-keyring && \
  sudo apt update && \
  sudo apt install -y libarrow-glib-dev && \
  sudo apt clean

RUN mkdir /app
WORKDIR /app
COPY . /app
RUN bundle install

