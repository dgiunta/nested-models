module ActionView
  module Helpers
    
    # This is a bit different than the way Rails 2.3 actually loads these form builder methods.
    # Obviously, because they just have the complete Rails 2.3 FormBuilder class to work with
    # they don't need to try to override any existing methods. This new "NestedFormBuilder" 
    # accomplishes this with simple inheritance, and follows it up with resetting the default 
    # form builder to use the NestedFormBuilder instead of the normal form builder.
    # In some ways, this is really nice in that now you can change your mind and not use the 
    # NestedFormBuilder functionality in some forms simply by specifying a :builder => FormBuilder option 
    # in your form_for or fields_for call.
    # 
    class NestedFormBuilder < ActionView::Helpers::FormBuilder
      def fields_for(record_or_name_or_array, *args, &block)
        if options.has_key?(:index)
          index = "[#{options[:index]}]"
        elsif defined?(@auto_index)
          self.object_name = @object_name.to_s.sub(/\[\]$/,"")
          index = "[#{@auto_index}]"
        else
          index = ""
        end

        case record_or_name_or_array
        when String, Symbol
          if nested_attributes_association?(record_or_name_or_array)
            return fields_for_with_nested_attributes(record_or_name_or_array, args, block)
          else
            name = "#{object_name}#{index}[#{record_or_name_or_array}]"
          end
        when Array
          object = record_or_name_or_array.last
          name = "#{object_name}#{index}[#{ActionController::RecordIdentifier.singular_class_name(object)}]"
          args.unshift(object)
        else
          object = record_or_name_or_array
          name = "#{object_name}#{index}[#{ActionController::RecordIdentifier.singular_class_name(object)}]"
          args.unshift(object)
        end

        @template.fields_for(name, *args, &block)
      end
  
      private
  
      def nested_attributes_association?(association_name)
        @object.respond_to?("#{association_name}_attributes=")
      end

      def fields_for_with_nested_attributes(association_name, args, block)
        name = "#{object_name}[#{association_name}_attributes]"
        association = @object.send(association_name)

        if association.is_a?(Array)
          children = args.first.respond_to?(:new_record?) ? [args.first] : association

          children.map do |child|
            child_name = "#{name}[#{ child.new_record? ? new_child_id : child.id }]"
            @template.fields_for(child_name, child, *args, &block)
          end.join
        else
          @template.fields_for(name, association, *args, &block)
        end
      end

      def new_child_id
        value = (@child_counter ||= 1)
        @child_counter += 1
        "new_#{value}"
      end
    end
  end
  
  # Sets the default form builder to use NestedFormBuilder instead of the normal FormBuilder.
  class Base
    self.default_form_builder = ::ActionView::Helpers::NestedFormBuilder
  end
end