class Form < ActiveRecord::Base
  has_many :attrs
  has_many :steps

  validates :element, :presence => true

  def write_hash_to_db(hash)
    
  end

  def to_config_hash
    self.last_step
    self.first_step
    hash = {
      self.id => self.attributes,
    }
    # need this outside loop to simulate AR associations like form.steps => []
    hash[self.id]["steps"] ||= {}
    self.steps.each do |step|
      hash[self.id]["steps"][step.id] = step.attributes

      # need this outside loop to simulate AR associations like step.attrs => []
      hash[self.id]["steps"][step.id]["attrs"] ||= {}
      step.attrs.each do |attr|
        hash[self.id]["steps"][step.id]["attrs"][attr.id] = attr.attributes

        # need this outside loop to simulate AR associations like attr.validations => []
        hash[self.id]["steps"][step.id]["attrs"][attr.id]["validations"] ||= {}
        attr.validations.each do |vld|
          hash[self.id]["steps"][step.id]["attrs"][attr.id]["validations"][vld.id] = vld.attributes         
        end
      end
    end

    hash
  end

  def write_config_yaml!(file="#{Rails.root}/config/config_yaml.yaml")
    #File.exist?(file) ? (File.open(file, 'w') {|f| f.write(self.to_config_hash.to_yaml)}) : raise("invalid file")
    File.open(file, 'w') {|f| f.write(self.to_config_hash.to_yaml)}
  end

  def first_step
    unless self.first_step_id
      self.update_attributes(:first_step_id => self.steps.order("position asc").limit(1).first.id)
    else
      Step.find(self.first_step_id)
    end
  end

  def last_step
    unless self.last_step_id
      self.update_attributes(:last_step_id => self.steps.order("position desc").limit(1).first.id)
    else
      Step.find(self.last_step_id)
    end
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
    merged_hash = Form.merge_hash(old_hash, new_hash, prev_button, step.attrs.collect(&:name))

    # run all validations on current step attrs
    step.custom_validate(merged_hash) unless prev_button

    # create form object--vehicle for processed form data
    obj = OpenStruct.new(:valid => true)

    case 
    when prev_button && !step.is_first_step?
      merged_hash["step_id"] = step.prev_step.id
    when step.errors.any?
      obj.json = step.errors.to_json
      obj.valid = false
    when step.is_last_step?
      merged_hash["redirect_to"] = self.redirect_to || "/"
    else
      merged_hash["step_id"] = step.next_step.id
    end

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
