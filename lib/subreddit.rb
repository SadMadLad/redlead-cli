class Subreddit
  SUBREDDITS = JSON.parse File.read("data/subreddits.json")

  class << self
    def find_by_display_names(*display_names)
      all.filter { |subreddit| display_names.include?(subreddit["display_name"]) }
    end

    def find_by_display_name(display_name)
      all.find{ |subreddit| subreddit["display_name"] == display_name }
    end

    def all
      SUBREDDITS
    end
  end
end
