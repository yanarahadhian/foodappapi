# config valid only for Capistrano 3.1
lock '3.4.0'

set :application, 'foodappapi'
set :repo_url, 'ssh://git@gitlab.kiranatama.net:222/andi.sulistyo/foodappapi.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5
set :use_sudo, true
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
set :default_shell, '/bin/bash -l'

set :default_environment, {
  'PATH' => "#{deploy_to}/bin:$PATH",
  'GEM_HOME' => "#{deploy_to}/gems"
}

# TRUST RVM
namespace :rvmrc do
  desc "Trust rvmrc file"
  task :trust do
      on roles(:app) do
        releases = capture("ls #{File.join(fetch(:deploy_to), 'releases')}")
      if this_host_last_release = releases.split("\n").sort.last
          execute "~/.rvm/bin/rvm rvmrc trust #{releases_path}/#{this_host_last_release}"
      end
    end
  end
end

# file: deploy.rb, in the end

namespace :deploy do
  desc 'Seed Database'
  task :seed do
    puts "\n=== Seeding Database ===\n"
    puts "\n #{release_path} \n"
    on primary fetch(:migration_role) do
      within release_path do
        with rails_env: fetch(:stage, :staging) do
          execute :rake, "db:seed"
        end
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        with rails_env: fetch(:stage,:staging) do
          execute :kill ," -9 $(cat #{current_path}/tmp/pids/thin.pid)" rescue nil
          execute :bundle, "exec thin -p 3259 -e staging -d start"
        end
      end
    end
  end

  before :restart, "rvmrc:trust"
  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  desc 'Create Symlink'
  task :create_symlink do
    on roles(:app) do
      begin
        execute "mkdir -p #{shared_path}/uploads"
        execute "mkdir -p #{shared_path}/upload_document"
      rescue
      end
      execute "ln -nfs #{shared_path}/uploads #{release_path}/uploads"
      execute "ln -nfs #{shared_path}/upload_document #{release_path}/upload_document"
    end
  end

  desc 'Message when deployment is completed'
  task :complete_deployed do
    system("Capistrano Deployment Completed")
  end

  after :finished, :complete_deployed
end

after :deploy, "deploy:create_symlink"
