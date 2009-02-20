module Mime
  class Type
    def self.for(symbol)
      mime = EXTENSION_LOOKUP[symbol.to_s] && mime.to_s
    end
  end
end

unless Mime.const_defined?(:PDF) || Mime::Type.lookup('application/pdf')
  Mime::Type.register('application/pdf', :pdf)
end
