# frozen_string_literal: true

require 'yard/dry/initializer/common_handler'

module YARD
  module Dry
    module Initializer
      class ParamHandler < ::YARD::Handlers::Ruby::Base
        include CommonHandler

        handles method_call(:param)
        namespace_only

        def process
          super

          add_constructor_param
          add_constructor_tag
        end

        protected

        def add_constructor_param
          existing_index = constructor.parameters.index do |name, _default|
            name == definition_name
          end
          if existing_index
            constructor.parameters[existing_index] = [definition_name, default_string]
          else
            constructor.parameters.insert(last_param_index, [definition_name, default_string])
          end
        end

        def last_param_index
          return -1 if constructor.parameters.empty?
          constructor.parameters.last.first.start_with?('**') ? -2 : -1
        end

        def add_constructor_tag
          if existing_tag
            existing_tag.text = comment
            existing_tag.instance_variable_set(:@defaults, default_string && [default_string])
          else
            param = YARD::Tags::DefaultTag.new(:param, comment, nil, definition_name, [default_string])
            constructor.add_tag(param)
          end
        end

        def existing_tag
          @existing_tag ||=
            constructor.tags.find do |tag|
              tag.name == definition_name && tag.tag_name == 'param'
            end
        end
      end
    end
  end
end
