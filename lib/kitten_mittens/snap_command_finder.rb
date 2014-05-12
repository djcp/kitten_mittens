class KittenMittens
  class SnapCommandFinder
    COMMANDS = [
      {
        base: 'streamer',
        command: %w|streamer -s 1280x1024 -c /dev/video0 -b 128 -o|
      },
    ]

    def self.find
      best = COMMANDS.find do |command|
        puts command[:base]
        Cocaine::CommandLine.new(
          ['bash', '-c', 'command', '-v', command[:base]]
        ).run
      end
      best[:command]
    end
  end
end
