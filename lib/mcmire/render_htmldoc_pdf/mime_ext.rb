# Convenience method to get the MIME type for an extension
module Mime
  class Type
    def self.for(symbol)
      mime = EXTENSION_LOOKUP[symbol.to_s] && mime.to_s
    end
  end
end