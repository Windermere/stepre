require 'net/http'
require 'uri'
require 'ostruct'
#require 'active_model/deprecated_error_methods'
require 'active_model'
require 'active_model/validator'
require 'active_model/naming'
require 'active_model/translation'
require 'active_model/validations'
require 'active_model/conversion'

module Stepre
  def self.flat_hash(arg, keys=[])
    new_hash = {}
    case
    when arg.is_a?(Hash) then arg.each {|k,v| new_hash.merge!(self.flat_hash(v, keys + [k]))}
    when arg.is_a?(Array) then arg.each_with_index {|v,i| new_hash.merge!(self.flat_hash(v, keys + [i]))}
    else; new_hash[keys] = arg
    end
    new_hash
  end

  def self.convert_hash(hash)
    obj = Obj.new(hash)
    hash.each do |k,v| 
      # do this later
      #case
      #when k == "steps"
      #end
      obj.hash[k] = v.is_a?(Hash) ? self.convert_hash(v) : v
    end
    obj
  end
end

require "stepre/version"
require "stepre/obj"
require "stepre/step"
require "stepre/pundit"
require "stepre/form"
