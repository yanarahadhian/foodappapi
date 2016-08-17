# auto reload API changes each request under development environment
if Rails.env.development?
  ActiveSupport::Dependencies.explicitly_unloadable_constants << "Joeyfood"

  api_files = Dir[Rails.root.join('app', 'api', '**', '*.rb')]
  api_reloader = ActiveSupport::FileUpdateChecker.new(api_files) do
    Rails.application.reload_routes!
  end

  ActionDispatch::Callbacks.to_prepare do
    api_reloader.execute_if_updated
  end
end