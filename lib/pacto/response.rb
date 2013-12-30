module Pacto
  class Response
    attr_reader :status, :headers, :schema

    def initialize(definition)
      @definition = definition
      @status = @definition['status']
      @headers = @definition['headers']
      @schema = @definition['body']
    end

    def instantiate
      Faraday::Response.new(default_env)
    end

    private

    def default_env
      {}.tap do | env |
        env[:status] = @definition['status']
        env[:response_headers] = @definition['headers']
        env[:body] = JSON::Generator.generate(@schema) if @schema && !@schema.empty?
      end
    end
  end
end
