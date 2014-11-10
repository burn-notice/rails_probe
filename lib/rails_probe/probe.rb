require 'fileutils'

module RailsProbe
  class Probe

    attr_accessor :name, :identifiers, :stack

    def initialize(name, identifiers, stack, path)
      @name = name
      @identifiers = identifiers
      @stack = stack
      @path = path
      @file_name = File.join(@path, "#{@name}.yml")
    end

    def run(&block)
      ActiveSupport::Notifications.subscribed(method(:record), @identifiers, &block)
    ensure
      finalize
    end

    def record(name, start, finish, id, payload)
      backtrace = caller.dup
      backtrace.shift while backtrace.present? && backtrace.first =~ /active_support\/notifications/
      backtrace.pop   while backtrace.present? && backtrace.last !~ /rails_probe/
      @stack << {
        id:         id,
        name:       name,
        start:      start,
        finish:     finish,
        payload:    payload,
        backtrace:  backtrace,
      }
    end

    def finalize
      FileUtils.mkdir_p(File.dirname(@file_name))
      File.open(@file_name, 'w') { |file| file.write(YAML.dump(@stack)) }
    end
  end
end
