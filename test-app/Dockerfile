FROM ruby:3.1.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       git \
       curl \
       libssl-dev \
       libreadline-dev \
       zlib1g-dev \
       autoconf \
       bison \
       build-essential \
       libyaml-dev \
       libreadline-dev \
       libncurses5-dev \
       libffi-dev \
       libgdbm-dev \
       nodejs \
       vim \
       nano \
       apache2-utils

WORKDIR /var/app/
COPY . /var/app/

ARG OBOE_ENV
ARG BUNDLE_RUBYGEMS__PKG__GITHUB__COM

RUN bundle install

EXPOSE 8002

# for testing: rails server -b 0.0.0.0 -p 8002
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "8002"]
