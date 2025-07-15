module LLMs
  class LLM
    class << self
      def provider(provider_name = nil)
        @provider ||= provider_name
      end
    end

    def initialize(model, ...)
      setup(self.class.provider, model, ...)
    end

    protected
      def available_providers
        AVAILABLE_PROVIDERS
      end

      def available_models
        LLMS[@provider]["models"]
      end

      def set_model(model)
        raise ArgumentError, "Model not available for provider: #{@provider}. Available Models: #{available_models}" unless available_models.include?(model)

        @model = model
      end

      def set_provider(provider)
        raise ArgumentError, "Provider not available. Available Providers: #{available_providers}" unless available_providers.include?(provider)

        @provider = provider
      end

      def default_options(**options)
        options = options.merge(api_key:) if api_key?

        {
          default_options: {
            chat_model: @model,
            completion_model: @model
          }
        }.compact.merge(**options)
      end

      def api_key
        case @provider
        when "google" then GOOGLE_GEMINI_API_KEY
        end
      end

      def api_key?
        !api_key.nil?
      end

      def model_class
        LLMS[@provider]["class"]
      end

      def initialize_model(...)
        @llm = model_class.new(**default_options(...))
      end

      def setup(provider, model, ...)
        set_provider provider
        set_model model
        initialize_model(...)
      end
  end
end
