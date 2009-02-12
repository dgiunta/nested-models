Dir[File.join(File.dirname(__FILE__), 'nested_models', '**', '*.rb')].each { |f| require f }

# Since the Reflection and Associations modules just needed a couple additional methods added to them, 
# rather than creating separate files for these and including them and whatnot, I'm just adding them in
# dynamically with a little module_eval here. It's quick and dirty, but works just the same.
# 
ActiveRecord::Reflection::ClassMethods.module_eval do
  # Returns an array of AssociationReflection objects for all associations which have <tt>:autosave</tt> enabled.
  def reflect_on_all_autosave_associations
    reflections.values.select { |reflection| reflection.options[:autosave] }
  end
end

ActiveRecord::Associations.module_eval do
  private
    # Gets the specified association instance if it responds to :loaded?, nil otherwise.
    def association_instance_get(name)
      association = instance_variable_get("@#{name}")
      association if association.respond_to?(:loaded?)
    end

    # Set the specified association instance.
    def association_instance_set(name, association)
      instance_variable_set("@#{name}", association)
    end
end

# Adding the additional AutosaveAssociation and NestedAttributes libraries to ActiveRecord::Base.
# These are straight out of Rails 2.3RC1 with only minor alterations 
# (currently lines 134-139 in autosave_association.rb)
# 
ActiveRecord::Base.class_eval do
  include ActiveRecord::AutosaveAssociation
  include ActiveRecord::NestedAttributes
end

# Rails 2.3RC1 adds a check to acts_like_string? when it's inspecting nested attributes hash.
# This will always fail unless a the following method is added to the String class.
# 
class String
  def acts_like_string?
    true
  end
end