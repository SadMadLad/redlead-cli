module CliPrinter
  SPINNER_FRAMES = %w[⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏]
  SPIN_INTERVAL = 0.1

  def pretty_print(...)
    puts pretty_text(...)
  end

  def pretty_text(text, *format_args)
    return text if format_args.empty?

    format_args.reduce(Rainbow(text)) { |text, format| text.public_send(format) }
  end

  def yield_print(starting_text, ending_text, working_text = nil, &block)
    puts starting_text

    spinner_thread = Thread.new do
      frame_index = 0
      loop do
        print "\r#{SPINNER_FRAMES[frame_index % SPINNER_FRAMES.length]} #{working_text}"
        $stdout.flush
        sleep(SPIN_INTERVAL)
        frame_index += 1
      end
    end

    block.call
  ensure
    Thread.kill(spinner_thread)
    print "\r#{ending_text}#{' ' * 20}\n\n"
    $stdout.flush
  end
end
