# frozen_string_literal: true

require 'bundler/setup'
require 'pry'
require 'yard'
require 'yard/dry/initializer'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def parse_file(file, ext: '.rb.txt')
  YARD::Registry.clear
  path = File.join(File.dirname(__FILE__), 'examples', file.to_s + ext)
  YARD::Parser::SourceParser.parse(path)
end

RSpec::Matchers.define :be_read_attribute do
  match do |method|
    expect(method).not_to eq nil
    expect(method).to be_reader
    expect(method).not_to be_writer
  end
end

RSpec::Matchers.define :have_option_tag do |name, **params|
  match do |method|
    expect(option_tags(method).size).to eq(1)
    expect(params).to eq(actual_params(method))
  end

  define_method :option_tags do |method|
    @option_tags ||= method.tags('option').select { |t| t.pair.name == name }
  end

  define_method :actual_params do |method|
    @actual_params ||=
      params.map { |k, _| [k, option_tags(method).first.pair.send(k)] }.to_h
  end

  failure_message do |method|
    specs = (option_tags(method).size == 1) && actual_params(method).inspect
    "expected that #{method} would have exactly 1 option tag for :#{name} " \
    "with attributes #{params.inspect}, but got #{option_tags(method).size} " \
    "#{specs && "with #{specs}"}"
  end
end
