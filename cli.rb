require "bundler/setup"

Bundler.require(:default, :development)
Dotenv.load

loader = Zeitwerk::Loader.new
loader.push_dir("lib/")
loader.inflector.inflect(
  "llms" => "LLMs",
  "llm" => "LLM",
  "google_llm" => "GoogleLLM",
)
loader.setup

include CliPrinter
include Constants

Langchain.logger.level = Logger::FATAL

RedleadCli.start(ARGV)
