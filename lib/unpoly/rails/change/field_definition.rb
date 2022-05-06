module Unpoly
  module Rails
    class Change
      module FieldDefinition

        def self.included(base)
          base.extend ClassMethods
        end

        # Rails 3.2 delegate generated invalid Ruby with `to: :class`.
        delegate :fields, to: :get_class

        private

        def get_class
          self.class
        end

        module ClassMethods

          def field(field, method: nil, response_header_name: nil)
            method ||= field.name

            define_method "#{method}_field" do
              field
            end

            define_method "#{method}_from_request_headers" do
              raw_value = request.headers[field.header_name]
              field.parse(raw_value)
            end

            define_method "#{method}_param_name" do
              field.param_name
            end

            define_method "serialized_#{method}" do
              value = send(method)
              field.stringify(value)
            end

            # define_method "#{name}_from_response_headers" do
            #   raw_value = response.headers[field.header_name]
            #   field.parse(raw_value)
            # end

            define_method "#{method}_from_params" do
              raw_value = params[field.param_name]
              field.parse(raw_value)
            end

            define_method "#{method}_from_request" do
              value = send("#{method}_from_request_headers")
              if value.nil?
                value = send("#{method}_from_params")
              end
              value
            end

            define_method "write_#{method}_to_response_headers" do
              value = send(method)
              stringified = field.stringify(value)
              if stringified.present? # app servers don't like blank header values
                header_name = response_header_name || field.header_name
                response.headers[header_name] = stringified
              end
            end
          end

        end
      end
    end
  end
end
