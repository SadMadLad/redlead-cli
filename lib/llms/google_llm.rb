module LLMs
  class GoogleLLM < LLM
    provider "google"

    def find_leads(business_prompt)
      messages = prepare_subreddit_recommendation_messages business_prompt
      recommended_subreddits = fetch_recommendations messages, google_subreddit_recommendation_schema
      recommended_subreddits = parse_recommended_subreddits recommended_subreddits

      subreddits_posts = fetch_subreddits_posts recommended_subreddits
      leads_messages = prepare_leads_messages subreddits_posts, business_prompt
      recommended_leads = fetch_recommendations leads_messages, google_lead_finding_schema
      recommended_leads = parse_recommended_leads recommended_leads

      fetch_leads recommended_leads, subreddits_posts
    end

    protected
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

      def parse_recommended_subreddits(recommended_subreddits)
        recommended_subreddits = JSON.parse(recommended_subreddits)["resources"].map{ |resource| resource["display_name"] }
        recommended_subreddits.each_slice(recommended_subreddits.length / 4).to_a
      end

      def fetch_subreddits_posts(grouped_recommended_subreddits)
        grouped_recommended_subreddits.map do |recommended_subreddits|
          Clients::RedditClient[:subreddits_posts, recommended_subreddits]
        end.flatten
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

      def fetch_leads(recommended_leads, subreddits_posts)
        recommended_leads.map do |reddit_id, score|
          subreddits_posts.find { |subreddit_post| subreddit_post["id"] == reddit_id }.merge("score" => score)
        end
      end
  end
end
