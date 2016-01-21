require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 03_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    # ...
    define_method name do
      # debugger
      send(through_name).send(source_name)
    end
  end

  def has_many_through(name, through_name, source_name)
    
  end
end
