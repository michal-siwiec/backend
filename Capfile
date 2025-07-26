require 'capistrano/setup' # Load DSL and set up stages
require 'capistrano/deploy' # Include default deployment tasks

# Make possible to work with Git
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

require 'capistrano/rbenv' # Make possible to use rbenv

# Make possible to use Puma as web server
require 'capistrano/puma'
install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Systemd

require 'capistrano/rails/migrations' # Add Capistrano tasks && turn on automatically migrations
require 'capistrano/sidekiq' # Make possible to use Sidekiq as system for async tasks

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }

# TODO: Why do I need Procfile?
# TODO: Add Cypress tests after changing logic here
# TODO: Should I move Cypress tests to other repository?
