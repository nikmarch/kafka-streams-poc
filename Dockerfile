FROM jruby:9.3

WORKDIR /app
COPY ./app/ /app

RUN bundle install

CMD bundle exec ruby stream.rb
