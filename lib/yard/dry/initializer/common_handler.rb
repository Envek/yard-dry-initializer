# frozen_string_literal: true

module YARD
  module Dry
    module Initializer
      module CommonHandler
        def process
          return unless reader?

          # Define reader method
          object = YARD::CodeObjects::MethodObject.new(namespace, reader_name)
          register(object)
          object.visibility = reader_visibility
          object.dynamic = true
          doc = "Reader method for the +#{definition_name}+ initializer parameter."
          object.docstring = [comment, doc].compact.join("\n\n")

          # Register as attribute unless it is already registered
          return if namespace.attributes[:instance].key?(reader_name.to_sym)
          namespace.attributes[:instance][reader_name.to_sym] = { read: object }
        end

        protected

        def constructor
          @constructor ||= begin
            existing = namespace.meths.find(&:constructor?)
            return create_constructor unless existing
            return existing if existing.namespace == namespace
            copy_parent_constructor(existing)
          end
        end

        def create_constructor
          YARD::CodeObjects::MethodObject.new(namespace, :initialize)
        end

        def copy_parent_constructor(existing_constructor)
          YARD::CodeObjects::MethodObject.new(namespace, :initialize) do |new_constructor|
            existing_constructor.copy_to(new_constructor)

            # To allow replace arguments independent of parent
            new_constructor.parameters = existing_constructor.parameters.map(&:dup)
            # new_constructor.add_tag(*existing_constructor.tags.map(&:dup))
          end
        end

        def definition_name
          statement.parameters.first.jump(:tstring_content, :ident).source
        end

        def options
          raw_options = statement.parameters[2] || statement.parameters[1]
          return {} unless raw_options
          raw_options.map do |o|
            [o.first.jump(:tstring_content, :ident).source, o[1]]
          end.to_h
        end

        def reader?
          return true unless options.key?('reader:')
          options['reader:'].jump(:tstring_content, :ident).source != 'false'
        end

        def reader_name
          if options.key?('as:')
            options['as:'].jump(:tstring_content, :ident).source
          else
            definition_name
          end
        end

        def reader_visibility
          return :public unless options.key?('reader:')
          options['reader:'].jump(:tstring_content, :ident).source.to_sym
        end

        def comment
          return nil unless options.key?('comment:')
          options['comment:'].jump(:tstring_content, :ident).source
        end

        def default_string
          return options['default:'][1].source if options.key?('default:')
          'nil' if options.key?('optional:') && options['optional:'].jump(:tstring_content, :ident).source == 'true'
        end
      end
    end
  end
end
