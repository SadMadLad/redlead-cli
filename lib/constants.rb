module Constants
  # untested_models are those I haven't tested via the CLI yet.
  LLMS = {
    "google" => {
     "models" => ["gemini-2.5-flash-lite-preview-06-17", "gemini-2.0-flash", "gemini-2.0-flash-lite"],
     "untested_models" => ["gemini-2.5-flash", "gemini-1.5-flash-8b", "gemma-3-27b-it", "gemma-3n-e4b"],
     "class" => ::Langchain::LLM::GoogleGemini
    }
  }.freeze

  AVAILABLE_LLMS = LLMS.values.flatten.freeze
  AVAILABLE_PROVIDERS = LLMS.keys.freeze

  GOOGLE_GEMINI_API_KEY = ENV["GOOGLE_GEMINI_API_KEY"]
  REDDIT_USERNAME = ENV.fetch("REDDIT_USERNAME", "anonymous")
  USER_AGENT = "redlead-cli:1.0.0 (by /u/#{REDDIT_USERNAME})"
end
