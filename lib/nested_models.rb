require 'active_record/autosave_association'
require 'active_record/nested_attributes'

ActiveRecord::Base.class_eval do
  include ActiveRecord::AutosaveAssociation
  include ActiveRecord::NestedAttributes
end

class String
  def acts_like_string?
    true
  end
end