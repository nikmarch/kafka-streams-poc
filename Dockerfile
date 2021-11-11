FROM jruby:9.3

WORKDIR /app
COPY ./app/ /app

RUN gem install bundler:1.17.3
RUN bundle install
RUN bundle exec jbundle

CMD bundle exec ruby stream.rb
