# frozen_string_literal: true

require 'yard/dry/initializer/common_handler'

module YARD
  module Dry
    module Initializer
      class OptionHandler < ::YARD::Handlers::Ruby::Base
        include CommonHandler

        handles method_call(:option)
        namespace_only

        def process
          super

          unless constructor.tags('param').find { |t| t.name == 'options' }
            constructor.parameters << ['**options', nil]
            constructor.add_tag(YARD::Tags::Tag.new(:param, nil, ['Hash'], 'options'))
          end

          existing_tag = constructor.tags('option').find { |t| t.pair.name == definition_name }
          comment = self.comment || existing_tag&.pair&.text
          default = default_string && [default_string] || existing_tag&.pair&.defaults
          option = YARD::Tags::DefaultTag.new(:option, comment, nil, definition_name, default)
          if existing_tag
            existing_tag.pair = option
          else
            constructor.add_tag(YARD::Tags::OptionTag.new(:option, 'options', option))
          end
        end
      end
    end
  end
end
