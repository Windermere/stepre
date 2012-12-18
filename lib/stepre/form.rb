require "stepre/form/snippets"

module Stepre
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
      #raise @config_hash.inspect
      @obj = Stepre.convert_hash(@config_hash[form_id])
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
      # create form object--vehicle for processed form data
      hsh = {
        :valid => true, 
        :merged_hash => merged_hash,
        :params_hash => params_hash,
        :step => nil,
        :new_hash => {},
        :old_hash => {},
        :before_button => false,
      }
      obj = OpenStruct.new(hsh)

      # create hash from submitted form data
      obj.new_hash = Stepre::Form.read_form_data(obj.params_hash["form_data"])
      obj.old_hash = Stepre::Form.read_form_data(obj.new_hash.delete("form_data"))

      # create hash from current step 
      obj.new_hash = Stepre::Form.format_hash(self.element, obj.new_hash)
      obj.old_hash = Stepre::Form.format_hash(self.element, obj.old_hash)

      # find current step
      raise "STEP NOT FOUND" unless obj.step = self.steps.find(obj.old_hash["step_id"])

      # previous button pressed?
      if obj.prev_button = !!obj.new_hash.delete("prev_button")
        # remove future step attrs
        obj.step.attrs.each {|o| obj.old_hash.delete(o.name)}
        obj.old_hash["step_id"] = obj.step.prev_step_id
        obj.json = {:form_data => Stepre::Form.write_form_data(obj.old_hash)}.to_json
        return obj
      end 

      # merge in submitted form data 
      #merged_hash = Stepre::Form.merge_hash(obj.old_hash, obj.new_hash, obj.prev_button, obj.step_attrs_array)
      obj.merged_hash = obj.old_hash.merge(obj.new_hash)

      # logic in eval can be moved to appropriate location later
      #self.instance_eval("raise self.inspect")
      self.instance_eval(obj.step.before_snippet) if obj.step.before_snippet

      before_method = "#{self.name}_#{obj.step.name}_before"
      if Stepre::Form::Snippets.respond_to?(before_method)
        Stepre::Form::Snippets.send(before_method, obj)
        return obj if obj.return
      end

      # run all validations on current step attrs
      obj.step.custom_validate(obj.merged_hash) unless obj.prev_button or obj.merged_hash["skip_validations"]

      case
      when obj.merged_hash.delete("skip_validations")
        # do nothing
      #when prev_button && !obj.step.is_first_step?
      #  merged_hash["step_id"] = obj.step.prev_step_id
      when obj.step.errors.any?
        obj.json = obj.step.errors.to_json
        obj.valid = false
      when obj.step.is_last_step?
        obj.merged_hash["redirect_to"] = self.redirect_to || "/"
      else
        obj.merged_hash["step_id"] = obj.step.next_step_id
      end

      # logic in eval can be moved to appropriate location later
      self.instance_eval(obj.step.after_snippet) if obj.step.after_snippet

      after_method = "#{self.name}_#{obj.step.name}_after"
      if Stepre::Form::Snippets.respond_to? after_method
        Stepre::Form::Snippets.send(after_method, obj)
        return obj if obj.return
      end

      # add options to merged_hash
      options_array.each {|o| obj.merged_hash[o] = obj.params_hash[o] if obj.params_hash.key? o}

      obj.json = {:form_data => Stepre::Form.write_form_data(obj.merged_hash)}.to_json if obj.valid

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
