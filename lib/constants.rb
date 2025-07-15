module Constants
  LLMS = {
    "google" => {
     "models" => ["gemini-2.0-flash", "gemma-3-27b-it", "gemma-3n-e4b"],
     "class" => ::Langchain::LLM::GoogleGemini
    }
  }.freeze

  AVAILABLE_LLMS = LLMS.values.flatten.freeze
  AVAILABLE_PROVIDERS = LLMS.keys.freeze

  GOOGLE_GEMINI_API_KEY = ENV["GOOGLE_GEMINI_API_KEY"]
  REDDIT_USERNAME = ENV.fetch("REDDIT_USERNAME", "anonymous")
  USER_AGENT = "redlead-cli:1.0.0 (by /u/#{REDDIT_USERNAME})"
end
