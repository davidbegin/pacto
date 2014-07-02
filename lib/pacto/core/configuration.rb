module Pacto
  class Configuration
    attr_accessor :adapter, :strict_matchers,
                  :contracts_path, :logger, :generator_options,
                  :hide_deprecations, :default_consumer, :default_provider, :default_validators
    attr_reader :hook

    def initialize
      @middleware = Pacto::Core::HTTPMiddleware.new
      @middleware.add_observer Pacto::ValidatorStack, :validate
      @generator = Pacto::Generator.new
      @middleware.add_observer @generator, :generate
      @default_validators = _default_validators
      @default_consumer = Pacto::Consumer
      @default_provider = Pacto::Provider
      @adapter = Stubs::WebMockAdapter.new(@middleware)
      @strict_matchers = true
      @contracts_path = nil
      @logger = Logger::SimpleLogger.instance
      define_logger_level
      @hook = Hook.new {}
      @generator_options = { schema_version: 'draft3' }
    end

    def register_hook(hook = nil, &block)
      if block_given?
        @hook = Hook.new(&block)
      else
        fail 'Expected a Pacto::Hook' unless hook.is_a? Hook
        @hook = hook
      end
    end

    private

    def define_logger_level
      if ENV['PACTO_DEBUG']
        @logger.level = :debug
      else
        @logger.level = :default
      end
    end

    def _default_validators
      [
        Pacto::Validators::RequestBodyValidator,
        Pacto::Validators::ResponseStatusValidator,
        Pacto::Validators::ResponseHeaderValidator,
        Pacto::Validators::ResponseBodyValidator
      ]
    end
  end
end
