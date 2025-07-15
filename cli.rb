require "bundler/setup"

Bundler.require(:default, :development)
Dotenv.load

loader = Zeitwerk::Loader.new
loader.push_dir("lib/")
loader.inflector.inflect(
  "llms" => "LLMs",
  "llm" => "LLM",
  "google_llm" => "GoogleLLM"
)
loader.setup

include Constants

Langchain.logger.level = Logger::FATAL

leads = LLMs::GoogleLLM.new("gemini-2.0-flash").find_leads("We sell shoes, from heals to boots to sneakers and everything in-between!")

binding.pry

# RedleadCli.start(ARGV)
