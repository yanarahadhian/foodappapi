# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.


role :app, %w{foodapp@202.138.229.148}
role :web, %w{foodapp@202.138.229.148}
role :db,  %w{foodapp@202.138.229.148}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server '202.138.229.148', user: 'foodapp', roles: %w{web app}, my_property: :my_value

set :stage, :staging
set :deploy_to, '/home/foodapp/foodappapi'
set :rvm_ruby_version, "ruby-2.1.5@foodappapi"
set :user, "foodapp"

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
server '202.138.229.148',
  user: 'foodapp',
  roles: %w{web app},
  ssh_options: {
    user: 'foodapp', # overrides user setting above
    keys: %w(/home/foodapp/.ssh/id_rsa),
    forward_agent: false,
    auth_methods: %w(publickey)
    # password: 'please use keys'
  }


# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server 'example.com', user: 'deploy', roles: %w{app db web}, my_property: :my_value
# server 'example.com', user: 'deploy', roles: %w{app web}, other_property: :other_value
# server 'db.example.com', user: 'deploy', roles: %w{db}
