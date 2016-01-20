require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    @class_name.underscore + "s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {    foreign_key: "#{name}_id".to_sym,
                    primary_key: :id,
                    class_name: "#{name}".camelize.singularize,
                }
    defaults = defaults.merge(options)
    @foreign_key = defaults[:foreign_key]
    @primary_key = defaults[:primary_key]
    @class_name = defaults[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {    foreign_key: "#{self_class_name.underscore}_id".to_sym,
                    primary_key: :id,
                    class_name: "#{name}".camelize.singularize,
                }
    defaults = defaults.merge(options)
    @foreign_key = defaults[:foreign_key]
    @primary_key = defaults[:primary_key]
    @class_name = defaults[:class_name]
  end
end

module Associatable
  # Phase IIIb

  def belongs_to(name, options = {})
    options = BelongsToOptions(name, options)
    define_method :name do |options|
      options.send(:foreign_key)
      options.model_class
      DBConnection.execute(<<-SQL)

      SQL
    end

    end

  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
