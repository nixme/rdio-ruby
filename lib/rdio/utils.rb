module Rdio::Utils
  extend self

  def underscore_string(str)
    str.to_s.strip.
      gsub(' ', '_').
      gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      squeeze("_").
      downcase
  end
end
