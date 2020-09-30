require 'minitest'

module Minitest
  DEFAULT_TEST_COUNT = 25

  def self.plugin_profile_options(opts, options)
    opts.on("--profile", "Display list of slowest tests") do |p|
      options[:profile] = true
      options[:count] ||= DEFAULT_TEST_COUNT
    end
  end

  def self.plugin_profile_init(options)
    self.reporter << ProfileReporter.new(options) if options[:profile]
  end

  class ProfileReporter < AbstractReporter
    VERSION = "0.0.3"

    attr_accessor :io, :results, :count

    def initialize(options)
      @io = options[:io]
      @count = options[:count]
      @results = []
    end

    def record(result)
      @results << [result.time, result.location]
    end

    def report
      return unless passed?

      puts "\n#{'=' * 80}"
      puts "Your #{@count} Slowest Tests"
      puts "#{'=' * 80}\n"

      sorted_results[0, @count].each do |time, test_name|
        puts "#{sprintf("%7.4f",time)}ms - #{test_name}"
      end
    end

    def sorted_results
      results.sort { |a, b| b[0] <=> a[0] }
    end
  end
end
