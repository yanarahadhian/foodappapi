# replace grape error response
class Joeyfood::GrapeErrorFormatter
  extend Joeyfood::GlobalHelpers

  def self.call(status, message, backtrace, options, env)
    respond_json(message, status, message).to_json
  end
end
