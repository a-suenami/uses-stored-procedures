module UsesStoredProcedures
  ##
  # HashWithAttributes augments Hash with getters and setters on
  # an as needed basis.
  #
  # When ever an instance of HashWithAttributes is sent an accessor
  # message, or a respond_to? message that matches a hash key for
  # the first time, a setter and getter is created for that key which
  # may be either a symbol or a string.
  #
  # @example
  #
  #    h = HashWithAttributes.new
  #    h[:one] = 1
  #    h['two'] = 2
  #    h.one = 3
  #    h.two = 4
  #    puts "One is #{h.one} and Two is #{h.two}"
  #    # > One is 3 and Two is 4
  # 
  class HashWithAttributes < Hash
    
    
    def method_missing(name, *args, &block)
      if check_and_create_accessors(name)
        args.length > 0 ? send(name.to_s, args.first) : send(name.to_s)
      else
        super
      end
    end
    
    def respond_to?(symbol, include_private = false)
      super || check_and_create_accessors(symbol)
    end

    private
      def check_and_create_accessors(name)
        item_name = name.to_s.chomp '='

        if has_key? item_name.to_sym
          self.class.create_accessors(item_name, true)
          return true
        end

        if has_key? item_name
          self.class.create_accessors(item_name, false)
          return true
        end
        false
      end
      
      def self.create_accessors(accessor, is_sym)
        if is_sym
          # The key is a symbol
          define_method(accessor)       { fetch __method__ }
          define_method("#{accessor}=") { |v| store(__method__.to_s.chomp('=').to_sym, v) }
        else
          # The key is a string
          define_method(accessor)       { fetch __method__.to_s }
          define_method("#{accessor}=") { |v| store(__method__.to_s.chomp('='), v) }
        end
        true
      end
  end    
end