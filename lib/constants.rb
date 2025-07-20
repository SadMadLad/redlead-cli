module Constants
  # untested_models are those I haven't tested via the CLI yet.
  LLMS = {
    "google" => {
     "models" => ["gemini-2.5-flash-lite-preview-06-17", "gemini-2.0-flash", "gemini-2.0-flash-lite", "gemini-2.5-flash"],
     "untested_models" => ["gemini-1.5-flash-8b", "gemma-3-27b-it", "gemma-3n-e4b"],
     "class" => ::Langchain::LLM::GoogleGemini
    }
  }.freeze

  NOTIFICATION_TEXTS = {
    subreddits_start: pretty_text("\n• Getting your recommended subreddits", :blue, :bold),
    subreddits_end: pretty_text("✔ Fetched your recommended subreddits", :green, :bold, :underline),
    subreddits_posts_start: pretty_text("• Fetching subreddits posts from the recommended ones", :blue, :bold),
    subreddits_posts_end: pretty_text("✔ Posts fetched!", :green, :bold, :underline),
    leads_start: pretty_text("• Finding best leads for you!", :blue, :bold),
    leads_end: pretty_text("✔ Fetched the leads!", :green, :underline)
  }

  AVAILABLE_LLMS = LLMS.values.flatten.freeze
  AVAILABLE_PROVIDERS = LLMS.keys.freeze

  GOOGLE_GEMINI_API_KEY = ENV["GOOGLE_GEMINI_API_KEY"]
  REDDIT_USERNAME = ENV.fetch("REDDIT_USERNAME", "anonymous")
  USER_AGENT = "redlead-cli:1.0.0 (by /u/#{REDDIT_USERNAME})"
end
