module LLMs
  class GoogleLLM < LLM
    provider "google"

    NOTIFICATION_TEXTS = {
      subreddits_start: pretty_text("\n• Getting your recommended subreddits", :blue, :bold),
      subreddits_end: pretty_text("✔ Fetched your recommended subreddits", :green, :bold, :underline),
      subreddits_posts_start: pretty_text("• Fetching subreddits posts from the recommended ones", :blue, :bold),
      subreddits_posts_end: pretty_text("✔ Posts fetched!", :green, :bold, :underline),
      leads_start: pretty_text("• Finding best leads for you!", :blue, :bold),
      leads_end: pretty_text("✔ Fetched the leads!", :green, :underline)
    }

    def find_leads(business_prompt)
      # Get recommended subreddits
      messages = prepare_subreddit_recommendation_messages business_prompt
      recommended_subreddits = fetch_recommended_subreddits messages
      recommended_subreddits = parse_recommended_subreddits recommended_subreddits
      print_recommended_subreddits recommended_subreddits

      # Get posts from the subreddits
      subreddits_posts = fetch_subreddits_posts recommended_subreddits

      # Find the ones that can be successful leads
      leads_messages = prepare_leads_messages subreddits_posts, business_prompt
      recommended_leads = fetch_leads leads_messages
      recommended_leads = parse_recommended_leads recommended_leads

      sort_leads recommended_leads, subreddits_posts
    end

    private
      def print_recommended_subreddits(subreddits)
        pretty_print "\nThese are the recommended subreddits: ", :cyan, :bold, :underline

        subreddits.flatten.each { |subreddit| pretty_print "\t • #{subreddit}", :cyan }

        puts
      end

      def google_subreddit_recommendation_schema
        Prompts.google_subreddit_recommendation_schema
      end

      def google_lead_finding_schema
        Prompts.google_lead_finding_schema
      end

      def prepare_subreddit_recommendation_messages(business_prompt)
        processed_chunks = Utils::Chunkifier.call(messages: Subreddit.all, truncation_attrs: %w[description])
        business_prompt = [Prompts.lead_finding_prompt, "Details of business you are helping:", business_prompt].join("\n")
        processed_chunks.unshift Utils::FormattedMessage.provider_message(@provider, business_prompt)
      end

      def fetch_recommendations(messages, generation_config = {})
        @llm.chat(messages:, **{ generation_config: }.compact).chat_completion
      end

      def fetch_recommended_subreddits(messages)
        yield_print(*NOTIFICATION_TEXTS.values_at(:subreddits_start, :subreddits_end)) do
          fetch_recommendations messages, google_subreddit_recommendation_schema
        end
      end

      def fetch_leads(messages)
        yield_print(*NOTIFICATION_TEXTS.values_at(:leads_start, :leads_end)) do
          fetch_recommendations messages, google_lead_finding_schema
        end
      end

      def parse_recommended_subreddits(recommended_subreddits)
        recommended_subreddits = JSON.parse(recommended_subreddits)["resources"].map{ |resource| resource["display_name"] }
        recommended_subreddits.each_slice(3).to_a
      end

      def fetch_subreddits_posts(grouped_recommended_subreddits)
        yield_print(*NOTIFICATION_TEXTS.values_at(:subreddits_posts_start, :subreddits_posts_end)) do
          grouped_recommended_subreddits.map do |recommended_subreddits|
            Clients::RedditClient[:subreddits_posts, recommended_subreddits]
          end.flatten
        end
      end

      def prepare_leads_messages(subreddits_posts, business_prompt)
        subreddits_posts = subreddits_posts.map { |subreddit_post| subreddit_post.slice("id", "title", "selftext") }
        processed_chunks = Utils::Chunkifier.call(messages: subreddits_posts, truncation_attrs: %w[title selftext])
        business_prompt = [Prompts.lead_finding_prompt, "Details of business you are helping:", business_prompt].join("\n")
        processed_chunks.unshift Utils::FormattedMessage.provider_message(@provider, business_prompt)
      end

      def parse_recommended_leads(recommended_leads)
        JSON.parse(recommended_leads)["resources"].map{ |resource| resource.values_at("reddit_id", "score") }
      end

      def sort_leads(recommended_leads, subreddits_posts)
        recommended_leads.map do |reddit_id, score|
          subreddit_post = subreddits_posts.find { |subreddit_post| subreddit_post["id"] == reddit_id }
          subreddit_post = subreddit_post.merge("score" => score) unless subreddit_post.nil?

          subreddit_post
        end.compact
      end
  end
end
