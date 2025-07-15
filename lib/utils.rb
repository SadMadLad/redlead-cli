module Utils
  class FormattedMessage
    class << self
      def provider_message(provider, content)
        case provider
        when "google" then { parts: { text: content } }
        else { content: }
        end.merge(role: "user")
      end
    end
  end

  class Chunkifier
    def initialize(messages:, slice_size: 40, truncation_attrs: [], provider: "google")
      @messages = messages
      @slice_size = slice_size
      @truncation_attrs = truncation_attrs
      @provider = provider
    end

    def call
      @messages.each_slice(@slice_size).map do |messages_slice|
        next messages_slice.to_yaml if @truncation_attrs.empty?

        @truncation_attrs.each do |attr|
          messages_slice.each do |message|
            next unless message.key?(attr) || message[attr].length < 200

            message[attr] = message[attr].slice(..200) + "..."
          end
        end

        messages_slice.to_yaml
      end.map do |yaml_chunk|
        process_messages_chunk(yaml_chunk)
      end
    end

    class << self
      def call(...) = new(...).call
    end

    private
      def process_messages_chunk(chunk)
        processed_yaml = chunk.to_yaml.squeeze(" ").squeeze("\n")

        FormattedMessage.provider_message(@provider, processed_yaml)
      end
  end
end
