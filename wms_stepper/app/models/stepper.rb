require 'net/http'
require 'uri'
require 'ostruct'

module Stepre
  class Pundit < OpenStruct
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend  ActiveModel::Naming

    # tell ActiveModel object is not persisted.
    def persisted?; false; end
  end

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
        pundit = Stepper::Pundit.new(attr.name => hash.fetch(attr.name, nil))
        (attr.validations || []).each do |vld|
          pundit.instance_eval(vld.snippet.gsub("ATTR", attr.name))
        end

        (pundit.errors.delete(:base) || []).each {|o| self.errors[:base] << o}
        self.errors.add(attr.name, pundit.errors[attr.name]) if pundit.errors.any?
      end

      return nil
    end
  end

  class Step < Obj
  end

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

  class Form
    attr_accessor :config_hash, :obj
    def initialize(config_file, form_id)
      if !(config_file =~ URI::regexp).nil?
        @config_hash = YAML.load(Net::HTTP.get(URI.parse(config_file)))
      elsif File.exist?(config_file)
        @config_hash = YAML.load(File.read(config_file))
      else
        raise "config file not found"
      end
      #raise @config_hash[form_id].inspect
      @obj = Stepper.convert_hash(@config_hash[form_id])
    end

    def find(m, *args)
      begin
        @obj.send(m, *args)
      rescue => e
        arg = m.is_a?(Fixnum) ? m : m.to_s
        @obj[arg]
      end
    end

    def method_missing(m, *args, &block)
      find m, *args
    end

    def first_step
      self.steps.find(self.first_step_id)
    end

    def last_step
      self.steps.find(self.last_step_id)
    end

    def url
      "/forms/#{self.config_hash["id"]}/processor_api"
    end

    def process_form_data(params_hash, options_array=[])
      # create hash from submitted form data
      new_hash = Form.read_form_data(params_hash["form_data"])
      new_hash = Form.format_hash(self.element, new_hash)

      # create hash from current step 
      old_hash = Form.read_form_data(new_hash.delete("form_data"))
      old_hash = Form.format_hash(self.element, old_hash)

      # previous button pressed?
      prev_button = !!new_hash.delete("prev_button")

      # find current step
      step = self.steps.find(old_hash["step_id"])

      # merge in submitted form data 
      merged_hash = Form.merge_hash(old_hash, new_hash, prev_button, step.attrs.map {|o| o.name})

      # logic in eval can be moved to appropriate location later
      self.instance_eval(self.before_snippet) if self.before_snippet

      # run all validations on current step attrs
      step.custom_validate(merged_hash) unless prev_button

      # create form object--vehicle for processed form data
      obj = OpenStruct.new(:valid => true)

      case 
      when prev_button && !step.is_first_step?
        merged_hash["step_id"] = step.prev_step_id
      when step.errors.any?
        obj.json = step.errors.to_json
        obj.valid = false
      when step.is_last_step?
        merged_hash["redirect_to"] = self.redirect_to || "/"
      else
        merged_hash["step_id"] = step.next_step_id
      end

      # logic in eval can be moved to appropriate location later
      self.instance_eval(self.after_snippet) if self.after_snippet

      # add options to merged_hash
      options_array.each {|o| merged_hash[o] = params_hash[o] if params_hash.key? o}

      obj.json = {:form_data => Form.write_form_data(merged_hash)}.to_json if obj.valid

      return obj
    end

    class << self
      def format_hash(elem, hash)
        hash.keys.each {|k| x = (k =~ /(#{elem})\[([^\]]*)\]/); hash[$2] = hash.delete(k) if x}
        hash
      end

      def merge_hash(old_hash, new_hash, prev_button=false, delete_keys=[])
        if prev_button
          delete_keys.each {|k| old_hash.delete k}
        else
          old_hash.merge! new_hash
        end
        old_hash
      end

      # hash to string 
      def write_form_data(hash)
        begin
          return Base64.encode64(hash.to_json).delete("\n")
        rescue
          return Base64.encode64("{}")
        end
      end

      # string to hash
      def read_form_data(form_data_str) 
        begin
          return JSON.parse Base64.decode64(form_data_str)
        rescue
          return {}
        end
      end
    end
  end
end
