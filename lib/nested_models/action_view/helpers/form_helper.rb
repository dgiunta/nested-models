ActionView::Helpers::FormHelper.module_eval do
  # Creates a scope around a specific model object like form_for, but
  # doesn't create the form tags themselves. This makes fields_for suitable
  # for specifying additional model objects in the same form.
  #
  # === Generic Examples
  #
  #   <% form_for @person, :url => { :action => "update" } do |person_form| %>
  #     First name: <%= person_form.text_field :first_name %>
  #     Last name : <%= person_form.text_field :last_name %>
  #
  #     <% fields_for @person.permission do |permission_fields| %>
  #       Admin?  : <%= permission_fields.check_box :admin %>
  #     <% end %>
  #   <% end %>
  #
  # ...or if you have an object that needs to be represented as a different
  # parameter, like a Client that acts as a Person:
  #
  #   <% fields_for :person, @client do |permission_fields| %>
  #     Admin?: <%= permission_fields.check_box :admin %>
  #   <% end %>
  #
  # ...or if you don't have an object, just a name of the parameter:
  #
  #   <% fields_for :person do |permission_fields| %>
  #     Admin?: <%= permission_fields.check_box :admin %>
  #   <% end %>
  #
  # Note: This also works for the methods in FormOptionHelper and
  # DateHelper that are designed to work with an object as base, like
  # FormOptionHelper#collection_select and DateHelper#datetime_select.
  #
  # === Nested Attributes Examples
  #
  # When the object belonging to the current scope has a nested attribute
  # writer for a certain attribute, fields_for will yield a new scope
  # for that attribute. This allows you to create forms that set or change
  # the attributes of a parent object and its associations in one go.
  #
  # Nested attribute writers are normal setter methods named after an
  # association. The most common way of defining these writers is either
  # with +accepts_nested_attributes_for+ in a model definition or by
  # defining a method with the proper name. For example: the attribute
  # writer for the association <tt>:address</tt> is called
  # <tt>address_attributes=</tt>.
  #
  # Whether a one-to-one or one-to-many style form builder will be yielded
  # depends on whether the normal reader method returns a _single_ object
  # or an _array_ of objects.
  #
  # ==== One-to-one
  #
  # Consider a Person class which returns a _single_ Address from the
  # <tt>address</tt> reader method and responds to the
  # <tt>address_attributes=</tt> writer method:
  #
  #   class Person
  #     def address
  #       @address
  #     end
  #
  #     def address_attributes=(attributes)
  #       # Process the attributes hash
  #     end
  #   end
  #
  # This model can now be used with a nested fields_for, like so:
  #
  #   <% form_for @person, :url => { :action => "update" } do |person_form| %>
  #     ...
  #     <% person_form.fields_for :address do |address_fields| %>
  #       Street  : <%= address_fields.text_field :street %>
  #       Zip code: <%= address_fields.text_field :zip_code %>
  #     <% end %>
  #   <% end %>
  #
  # When address is already an association on a Person you can use
  # +accepts_nested_attributes_for+ to define the writer method for you:
  #
  #   class Person < ActiveRecord::Base
  #     has_one :address
  #     accepts_nested_attributes_for :address
  #   end
  #
  # If you want to destroy the associated model through the form, you have
  # to enable it first using the <tt>:allow_destroy</tt> option for
  # +accepts_nested_attributes_for+:
  #
  #   class Person < ActiveRecord::Base
  #     has_one :address
  #     accepts_nested_attributes_for :address, :allow_destroy => true
  #   end
  #
  # Now, when you use a form element with the <tt>_delete</tt> parameter,
  # with a value that evaluates to +true+, you will destroy the associated
  # model (eg. 1, '1', true, or 'true'):
  #
  #   <% form_for @person, :url => { :action => "update" } do |person_form| %>
  #     ...
  #     <% person_form.fields_for :address do |address_fields| %>
  #       ...
  #       Delete: <%= address_fields.check_box :_delete %>
  #     <% end %>
  #   <% end %>
  #
  # ==== One-to-many
  #
  # Consider a Person class which returns an _array_ of Project instances
  # from the <tt>projects</tt> reader method and responds to the
  # <tt>projects_attributes=</tt> writer method:
  #
  #   class Person
  #     def projects
  #       [@project1, @project2]
  #     end
  #
  #     def projects_attributes=(attributes)
  #       # Process the attributes hash
  #     end
  #   end
  #
  # This model can now be used with a nested fields_for. The block given to
  # the nested fields_for call will be repeated for each instance in the
  # collection:
  #
  #   <% form_for @person, :url => { :action => "update" } do |person_form| %>
  #     ...
  #     <% person_form.fields_for :projects do |project_fields| %>
  #       <% if project_fields.object.active? %>
  #         Name: <%= project_fields.text_field :name %>
  #       <% end %>
  #     <% end %>
  #   <% end %>
  #
  # It's also possible to specify the instance to be used:
  #
  #   <% form_for @person, :url => { :action => "update" } do |person_form| %>
  #     ...
  #     <% @person.projects.each do |project| %>
  #       <% if project.active? %>
  #         <% person_form.fields_for :projects, project do |project_fields| %>
  #           Name: <%= project_fields.text_field :name %>
  #         <% end %>
  #       <% end %>
  #     <% end %>
  #   <% end %>
  #
  # When projects is already an association on Person you can use
  # +accepts_nested_attributes_for+ to define the writer method for you:
  #
  #   class Person < ActiveRecord::Base
  #     has_many :projects
  #     accepts_nested_attributes_for :projects
  #   end
  #
  # If you want to destroy any of the associated models through the
  # form, you have to enable it first using the <tt>:allow_destroy</tt>
  # option for +accepts_nested_attributes_for+:
  #
  #   class Person < ActiveRecord::Base
  #     has_many :projects
  #     accepts_nested_attributes_for :projects, :allow_destroy => true
  #   end
  #
  # This will allow you to specify which models to destroy in the
  # attributes hash by adding a form element for the <tt>_delete</tt>
  # parameter with a value that evaluates to +true+
  # (eg. 1, '1', true, or 'true'):
  #
  #   <% form_for @person, :url => { :action => "update" } do |person_form| %>
  #     ...
  #     <% person_form.fields_for :projects do |project_fields| %>
  #       Delete: <%= project_fields.check_box :_delete %>
  #     <% end %>
  #   <% end %>
  def fields_for(record_or_name_or_array, *args, &block)
    raise ArgumentError, "Missing block" unless block_given?
    options = args.extract_options!

    case record_or_name_or_array
    when String, Symbol
      object_name = record_or_name_or_array
      object = args.first
    else
      object = record_or_name_or_array
      object_name = ActionController::RecordIdentifier.singular_class_name(object)
    end

    builder = options[:builder] || ActionView::Base.default_form_builder
    yield builder.new(object_name, object, self, options, block)
  end
end