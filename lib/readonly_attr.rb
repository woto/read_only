require "readonly_attr/version"

module ReadonlyAttr

  module FormHelper
    def readonly_field object_name, method, options={}
      text_field object_name, "_#{method}", options
    end
  end

  module FormBuilder
    def readonly_field(method, options = {}, &block)
      @template.readonly_field(@object_name, method, objectify_options(options), &block)
    end
  end


  module ReadonlyConcern
    extend ActiveSupport::Concern
    included do

      def self.readonly_accessor name
        define_method name do
          var = instance_variable_get("@#{name}")
          Rails.application.message_verifier(name).verify(var)
        end

        define_method("#{name}=") do |val|
          var = Rails.application.message_verifier(name).generate(val)
          instance_variable_set("@#{name}", var)
        end

        #define_method "#{name}_before_type_cast" do
        #  var = instance_variable_get("@#{name}")
        #  #var = Rails.application.message_verifier(name).verify(name)
        #end

        define_method "_#{name}" do
          instance_variable_get("@#{name}")
        end

        define_method "_#{name}=" do |val|
          instance_variable_set("@#{name}", val)
        end

      end
    end
  end



  class Railtie < Rails::Railtie
    initializer "ReadonlyAttr" do
      #ActionController::Base.helper(ReadonlyAttr::ViewHelper)
      ActionView::Helpers::FormHelper.send(:include, ReadonlyAttr::FormHelper)
      #ActionView::Base.send(:include, ReadonlyAttr::FormHelper)
      ActionView::Helpers::FormBuilder.send(:include, ReadonlyAttr::FormBuilder)
      ActiveRecord::Base.send(:include, ReadonlyConcern)
    end
  end
end
