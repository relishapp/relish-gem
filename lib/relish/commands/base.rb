require 'yaml'
require 'relish/ui'
require 'relish/options_file'
require 'relish/commands/dsl'

module Relish
  module Command
    class Base
      extend Dsl
      
      attr_writer :args
      attr_reader :cli_options
            
      def initialize(args = [])
        @args = clean_args(args)
        @param = get_param
        @cli_options = Hash[*@args]
      end
      
      def url
        "http://#{host}/api"
      end
      
      def get_param
        @args.shift if @args.size.odd?
      end

    private
      
      option :organization
      option :project
      option :api_token, :default => lambda { get_and_store_api_token }
      option :host,      :default => lambda { Relish.default_host }
      
      def get_and_store_api_token
        api_token = get_api_token
        global_options_file.store('api_token' => api_token)
        api_token
      end
      
      def get_api_token
        email, password = ui.get_credentials
        
        raw_response = resource(:user => email, :password => password)['token'].get
        String.new(raw_response.to_s)
      end
      
      def resource(options = {})
        RestClient::Resource.new(url, options)
      end

      def clean_args(args)
        cleaned = []
        args.each do |arg|
          cleaned << arg.sub('--', '')
        end
        cleaned
      end
      
      def global_options_file
        @global_options ||= OptionsFile.new(Relish.global_options_file)
      end

      def local_options_file
        @local_options ||= OptionsFile.new(Relish.local_options_file)
      end
      
      def ui
        @ui ||= Ui.new
      end
      
    end
  end
end