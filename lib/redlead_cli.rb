class RedleadCli < Thor
  class << self
    def llms = LLMS
    def available_llm_providers = llms.keys
    def available_llm_models = llms.values.flatten
    def exit_on_failure? = true
  end

  desc "leads", "Will start finding leads for you"
  option :provider,
    aliases: "-p",
    type: :string,
    default: "google",
    required: true,
    enum: available_llm_providers,
    desc: "The LLM Provider"
  option :model,
    aliases: "-m",
    type: :string,
    default: "gemini-2.0-flash",
    required: true,
    enum: available_llm_models,
    desc: "The LLM Model"
  options :subreddits,
    aliases: "-s",
    type: :array,
    desc: "Specific subreddits to find leads from"
  options :business_prompt,
    aliases: "-b",
    type: :string,
    desc: "Business prompt: What the business provides, its products and services."

  def leads
    prepare_options
    validate_llm_model
    validate_api_key
    initialize_llm
    fetch_leads
  end

  private
    def llms
      self.class.llms
    end

    def from_options(*args)
      return options[args.first] if args.one?

      options.values_at(*args)
    end

    def prepare_options
      %w[model provider subreddits business_prompt].each do |opt_arg|
        instance_variable_set :"@#{opt_arg}", from_options(opt_arg)
      end
    end

    def validate_llm_model
      raise Thor::Error, "Model not available for the provider, #{@provider}. Available models: #{llms[@provider].join(", ")}" unless model_in_provider?
    end

    def validate_api_key
      requested_api_key = {
        "google" => "GOOGLE_GEMINI_API_KEY"
      }
      provider_api_key = case @provider
      when "google" then GOOGLE_GEMINI_API_KEY
      end

      raise Thor::Error, "API Key not provded for the provider, #{@provider}. Requested API Key: #{requested_api_key[@provider]}" if provider_api_key.nil?
    end

    def model_in_provider?
      llms[@provider]["models"].include?(@model)
    end

    def initialize_llm
      @llm = case @provider
      when "google" then LLMs::GoogleLLM
      end
    end
end
