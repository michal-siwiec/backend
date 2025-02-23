# Budoman-backend

## About project
Budoman-backend is a backend app for construction shop.
This is developed using:

- [Ruby](https://ruby-doc.org/3.1.1/) (3.1.1)
- [Rails](https://guides.rubyonrails.org/) (7.1.2)
- [PostgreSQL](https://www.postgresql.org/) (14.0.0)
- [Graphql](https://graphql-ruby.org/) (2.1.0)
- [RSpec](https://rspec.info/documentation/) (6.0.3)

## Requirements
- Ruby 3.1.1
- PostgreSQL 14

## Application setup
1. Make sure that you have filled .env, config/database.yml files
2. Make sure that you have Docker installed on your local machine
3. Make sure that you have generated ssh keys with default path
4. Run the following commands to start the application:
```bash
SSH_PUB_KEY=$(cat ~/.ssh/id_ed25519.pub) docker-compose build --no-cache # Build image (perform only once at the beggining)
docker-compose up # App should be available on port 3333
```

## Code quality
```bash
bundle exec rubocop # to turn on linter
bundle exec rspec # to turn on unit tests
bundle-audit check --update # to turn on bundle audit
```

## Tips
To turn on debugger inside container:
```bash
binding.pry # to stop performing app
docker attach budoman-backend-app # To have access to container's session
```

## Deploy
```bash
bundle exec cap production deploy
```
