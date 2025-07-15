module Clients
  class RedditClient
    BASE_URL = "https://www.reddit.com"
    SUBREDDIT_POST_FIELDS = %w[num_comments score ups upvote_ratio author author_fullname id domain name
    permalink url subreddit_name_prefixed subreddit subreddit_id subreddit_title selftext selftext_html title created_utc].freeze

    def initialize
      @client = Faraday.new(
        url: BASE_URL,
        headers: {
          "Content-Type" => "application/json",
          "User-Agent" => USER_AGENT
        }
      )
    end

    def subreddits_posts(subreddits, listing_type: "new", limit: 100, **params)
      concatenated_subreddits = subreddits.join("+")
      concatenated_subreddits = URI::DEFAULT_PARSER.escape(concatenated_subreddits)

      params = params.merge(limit:)

      response = @client.get("r/#{concatenated_subreddits}/#{listing_type}.json") do |req|
        req.params = req.params.merge(params)
      end

      parse_subreddits_posts response.body, response.status
    end

    class << self
      def [](method_name, ...)
        new.public_send(method_name, ...)
      end
    end

    private
      def parse_subreddits_posts(response, code)
        case code
        when 429
          :too_many_requests
        when 451
          :unavailable
        when 404
          :not_found
        else
          parsed_response = JSON.parse(response)

          parsed_response.dig("data", "children").map { |child| child["data"].slice(*SUBREDDIT_POST_FIELDS) }
        end
      end
  end
end
