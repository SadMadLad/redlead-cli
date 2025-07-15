class Prompts
  PROMPTS = YAML.load File.read("data/prompts.yml")

  class << self
    def lead_finding_prompt = PROMPTS["lead_finding_prompt"].strip
    def google_subreddit_recommendation_schema = PROMPTS["google_subreddit_recommendation_schema"]
    def google_lead_finding_schema = PROMPTS["google_lead_finding_schema"]
  end
end
