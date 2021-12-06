FROM jruby:9.3.1.0

env JARS_HOME /app/pkg

WORKDIR /app
COPY ./app/ /app

RUN gem install bundler:1.17.3
RUN bundle install
RUN bundle exec jbundle install
RUN bundle exec jbundle update

CMD bundle exec ruby start_stream.rb
