class RedleadCli < Thor
  class << self
    def llms = LLMS
    def available_llm_providers = llms.keys
    def available_llm_models = llms.values.map { |model_data| model_data["models"] }.flatten
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
  option :subreddits,
    aliases: "-s",
    type: :array,
    desc: "Specific subreddits to find leads from"
  option :business_prompt,
    aliases: "-b",
    type: :string,
    required:  true,
    desc: "Business prompt: What the business provides, its products and services."
  option :save,
    type: :boolean,
    default: true,
    desc: "Save the leads"
  def leads
    prepare_options
    validate_api_key
    validate_llm_model
    initialize_llm
    fetch_leads
    print_leads
    save if save?
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
      %w[model provider subreddits business_prompt save].each do |opt_arg|
        instance_variable_set :"@#{opt_arg}", from_options(opt_arg)
      end
    end

    def validate_llm_model
      raise Thor::Error, "Model not available for the provider, #{@provider}. Available models: #{llms[@provider].join(", ")}" unless model_in_provider?

      pretty_print "Model Setup: #{@model}", :violet, :bold
    end

    def validate_api_key
      requested_api_key = {
        "google" => "GOOGLE_GEMINI_API_KEY"
      }
      provider_api_key = case @provider
      when "google" then GOOGLE_GEMINI_API_KEY
      end

      raise Thor::Error, "API Key not provded for the provider, #{@provider}. Requested API Key: #{requested_api_key[@provider]}" if provider_api_key.nil?

      pretty_print "API Key found for provider: #{@provider}", :violet, :bold
    end

    def model_in_provider?
      llms[@provider]["models"].include?(@model)
    end

    def initialize_llm
      @llm = case @provider
      when "google" then LLMs::GoogleLLM
      end
    end

    def fetch_leads
      @leads = @llm.new(@model).find_leads(@business_prompt)
    end

    def save?
      @save
    end

    def print_leads
      pretty_print("• Potential Leads for you:", :blue, :bright, :bold, :underline)

      colors = [[:aqua, :cyan], [:magenta, :violet]]

      @leads.each_with_index do |lead, index|
        color, accent_color = colors[index % 2]

        pretty_print("\n\n\"#{lead["title"]}\" by #{lead["author"]}", :bold, color, :underline)
        pretty_print("Subreddit: #{lead["subreddit"]}\nComments Count: #{lead["num_comments"]}\nUpvotes: #{lead["ups"]}", :bold, accent_color)
        pretty_print(lead["selftext"].strip, color)
        puts
      end
    end

    def save
      saving_start = pretty_text("• Saving your leads", :blue, :bold)
      saving_end = pretty_text("✔ Your leads are saved at data/leads.yaml", :green, :bold, :underline)
      yield_print(saving_start, saving_end) { File.write("data/leads.yaml", @leads.to_yaml) }
    end
end
