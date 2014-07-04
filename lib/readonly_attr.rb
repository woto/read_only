require "readonly_attr/version"

module ReadOnly

  module FormHelper
    def read_only object_name, method, options={}
      text_field object_name, "_#{method}", options
    end
  end

  module FormBuilder
    def read_only(method, options = {}, &block)
      @template.read_only(@object_name, method, objectify_options(options), &block)
    end
  end


  module ReadOnlyConcern
    extend ActiveSupport::Concern
    included do

      def self.read_only attr_name

        define_method "#{attr_name}_before_type_cast" do
          var = instance_variable_get("@_#{attr_name}")
          if var.present?
            Rails.application.message_verifier(attr_name).verify(var)
          end
        end

        define_method("#{attr_name}=") do |val|
          var = Rails.application.message_verifier(attr_name).generate(val)
          send("_#{attr_name}=", var)
        end

        define_method "_#{attr_name}" do
          instance_variable_get("@_#{attr_name}")
        end

        define_method "_#{attr_name}=" do |val|
          instance_variable_set("@_#{attr_name}", val)

          var = Rails.application.message_verifier(attr_name).verify(val)

          if self.class.column_names.include? "#{attr_name}"
            # active_record attributes
            write_attribute("#{attr_name}", var)
          end

          # attr_accessor attributes
          instance_variable_set("@#{attr_name}", var)
        end

      end
    end
  end



  class Railtie < Rails::Railtie
    initializer "ReadOnly" do
      #ActionController::Base.helper(ReadOnly::ViewHelper)
      ActionView::Helpers::FormHelper.send(:include, ReadOnly::FormHelper)
      #ActionView::Base.send(:include, ReadOnly::FormHelper)
      ActionView::Helpers::FormBuilder.send(:include, ReadOnly::FormBuilder)
      ActiveRecord::Base.send(:include, ReadOnlyConcern)
    end
  end
end
