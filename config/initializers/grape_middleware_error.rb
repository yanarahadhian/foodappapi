# Override grape middleware to handle error
# We need to catch status code and send it to API user

require 'grape/middleware/base'

module Grape
  module Middleware
    class Error < Base
      def error!(message, status = options[:default_status], headers = {}, backtrace = [])
        headers = { Grape::Http::Headers::CONTENT_TYPE => content_type }.merge(headers)
        rack_response(format_message(status, message, backtrace), status, headers)
      end

      # TODO: This method is deprecated. Refactor out.
      def error_response(error = {})
        status = error[:status] || options[:default_status]
        message = error[:message] || options[:default_message]
        headers = { Grape::Http::Headers::CONTENT_TYPE => content_type }
        headers.merge!(error[:headers]) if error[:headers].is_a?(Hash)
        backtrace = error[:backtrace] || []
        rack_response(format_message(status, message, backtrace), status, headers)
      end

      def format_message(status, message, backtrace)
        format = env['api.format'] || options[:format]
        formatter = Grape::ErrorFormatter::Base.formatter_for(format, options)
        throw :error, status: 406, message: "The requested format '#{format}' is not supported." unless formatter
        formatter.call(status, message, backtrace, options, env)
      end
    end
  end
end
