module Rdio
  module Utils
    extend self

    # Makes an underscored, lowercase form of the string.
    # Based on ActiveSupport's Infector#underscore
    def underscore_string(str)
      word = str.to_s.dup
      word.gsub!(' ', '_')
      word.gsub!(/::/, '/')
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!('-', '_')
      word.squeeze!('_')
      word.downcase!
      word
    end

    # Like Object#inspect for passed `object` but skips instance variables to
    # avoid bloating output when debugging.
    def custom_inspect(object, *ivars_to_skip)
      variables = (object.instance_variables - ivars_to_skip).
        map { |var| "#{var}=#{object.instance_variable_get(var).inspect}" }.
        join(', ')
      "<#{object.class}: #{variables}>"
    end
  end
end
