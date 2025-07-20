# `redlead-cli`

`redlead-cli` is a powerful command-line tool designed to help businesses and professionals discover high-quality leads effortlessly. Powered by advanced Large Language Models (LLMs), it analyzes your business prompt and retrieves targeted leads from popular online communities (like Reddit).

Whether you're in marketing, sales, or research, `redlead-cli` streamlines your lead generation process with just a single command.

## Demo
![Demo](docs/demo.GIF)

## Quick Start

### Prerequisites

- Ruby 3.4.2
- Google Gemini API Key
- Bundler 2.6.2
- Your Reddit username (optional but recommended)

### Installation

```bash
# Clone the repository
git clone https://github.com/SadMadLad/redlead-cli
cd redlead-cli

# Install gems
bundle install

# Set up your API Keys

## Either declare your keys in a .env file (see .env.example)
echo GOOGLE_GEMINI_API_KEY=xxxxxxxxx > .env

## Or export them in terminal
export GOOGLE_GEMINI_API_KEY=xxxxxxxxxxx
```

### Basic Usage
```bash
# Getting leads for your business
ruby cli.rb leads -b "<Your Business/Service Description>"

# Using a specific model
ruby cli.rb leads -b "<Your Business/Service Description>" -m gemini-2.5-flash-lite-preview-06-17
```

### Command Line Options

| Option          | Alias | Required | Default            | Description                                                                                     |
|-----------------|-------|----------|--------------------|-------------------------------------------------------------------------------------------------|
| `--provider`    | `-p`  | Yes      | `google`           | The LLM Provider. Must be one of the available providers (`google`).                            |
| `--model`       | `-m`  | Yes      | `gemini-2.0-flash` | The LLM Model. Must be one of the models available under the specified provider.                |
| `--business_prompt` | `-b` | Yes   | *None*             | Business prompt: What the business provides, its products, and services.                        |
| `--save`        | `-s`  | No       | `true`             | Save the leads to a file (`data/leads.yaml`).                                                   |

## TODOs

- [ ] Integrate Other providers (OpenAI, Claude, Deepseek) and their models
