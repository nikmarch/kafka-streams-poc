FROM jruby:9.3

WORKDIR /app
COPY ./app/ /app

RUN bundle install
RUN bundle exec jbundle

CMD bundle exec ruby stream.rb
