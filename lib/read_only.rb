require "read_only/version"

module ReadOnly

  module FormHelper
    def read_only object_name, method, options={}
      options[:value] = Rails.application.message_verifier(method).generate(options[:value]) if options.key?(:value)
      label = label(object_name, "_#{method}")
      input = text_field(object_name, "_#{method}", options)
      content_tag(:div, label + tag(:br) + input, style: 'margin: 5px 0; display: none')
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

        # validates "_#{attr_name}", presence: true

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
      ActionView::Base.send(:include, ReadOnly::FormHelper)
      ActionView::Helpers::FormBuilder.send(:include, ReadOnly::FormBuilder)
      ActiveRecord::Base.send(:include, ReadOnlyConcern)
    end
  end
end
