set :application, 'blog.hoi.io'
set :repo_url, 'git@github.com:mejamiewilson/Ghost.git'

set :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/var/app/blog'
# set :scm, :git

# set :format, :pretty
# set :log_level, :debug
set :pty, true
set :npm_flags, '--silent --spin false'
# set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{log content/images}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:web) do
      execute "cd #{current_path} && grunt prod"
      #restart existing process
      pm2_restart_command = "cd #{current_path} && pm2 restart #{fetch(:application)}-web; true"
      puts pm2_restart_command
      execute pm2_restart_command

      #start new process
      pm2_start_command = "cd #{current_path} && NODE_ENV=#{fetch(:node_env,'production')} pm2 start #{current_path}/index.js -i 1 --merge-logs --name #{fetch(:application)}-web -- --production; true"
      puts pm2_start_command
      execute pm2_start_command
    end
  end

 after :published, :restart
end

desc "gather remote logs"
task :log do
  on roles(:all) do
    execute "tail -f ~/.pm2/logs/#{fetch(:application)}-web-out.log -f ~/.pm2/logs/#{fetch(:application)}-web-err.log"
  end
end


desc "gather remote process list"
task :list do
  on roles(:all) do
    execute "pm2 list"
  end
end
