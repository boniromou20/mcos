FROM cheokman/lax-base:latest
#FROM cheokman/todo-ruby:2.3.1
MAINTAINER Ben Wu <wucheokman@gmail.com>

ENV DEPLOY_PATH=/opt/deploy
ENV APP_PATH=$DEPLOY_PATH/application
ENV REL_PATH=$APP_PATH/release
ENV SHARE_PATH=$APP_PATH/shared

RUN mkdir -p $APP_PATH

WORKDIR $REL_PATH
COPY .ruby-version $REL_PATH/.ruby-version

RUN /bin/bash -l -c "rvm install $(cat .ruby-version); gem install bundler; rvm cleanup all"

COPY target/. $APP_PATH
