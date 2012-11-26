require "stepre/pundit"

module Stepre
  class Obj
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend  ActiveModel::Naming

    attr_accessor :hash
    def initialize(hash)
      @hash = hash
    end

    def find(id)
      @hash[id]
    end

    def each(&block)
      # returns key val
      #self.hash.each(&block)
      # need only val
      self.hash.values.each(&block)
    end

    def map(&block)
      # returns key val
      #self.hash.map(&block)
      # need only val
      self.hash.values.map(&block)
    end

    def method_missing(m, *args, &block)
      begin
        begin
          m.is_a?(Fixnum) ? find(m) : find(m.to_s)
        rescue => e 
          @hash.send m, *args 
        end
      rescue => e
        super
      end
    end

    # this goes in Stepre::Step
    def custom_validate(hash)
      self.attrs.each do |attr|
        #val = hash.fetch(attr.name, nil)
        ## do not allow empty strings by default and allow through validation args
        #val = nil if !val.nil? and val.to_s.strip.empty?
        pundit = Stepre::Pundit.new(attr.name => hash.fetch(attr.name, nil))
        (attr.validations || []).each do |vld|
          pundit.instance_eval(vld.snippet.gsub("ATTR", attr.name))
        end

        (pundit.errors.delete(:base) || []).each {|o| self.errors[:base] << o}
        self.errors.add(attr.name, pundit.errors[attr.name]) if pundit.errors.any?
      end

      return nil
    end
  end
end
