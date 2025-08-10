FROM ruby:3.1.1

# SETUP BUILD ARGUMENTS
ARG SSH_PUB_KEY

# SETUP SSH
RUN apt-get update && \
    apt-get install -y openssh-server && \
    mkdir -p /root/.ssh && \
    echo "$SSH_PUB_KEY" > /root/.ssh/authorized_keys

# INSTALL REQUIRED PACKETS
RUN apt-get install -y cron build-essential libpq-dev libxml2-dev libxslt1-dev zlib1g-dev

ENV NOKOGIRI_USE_SYSTEM_LIBRARIES=1

# INSTALL APPLICATION
WORKDIR /budoman-backend
COPY . /budoman-backend/
RUN bundle config set force_ruby_platform true && \
    bundle install

# START THE APPLICATION
ENTRYPOINT ["/bin/sh", "-c", "chmod u+x /budoman-backend/bin/container-startup.sh && /budoman-backend/bin/container-startup.sh"]
