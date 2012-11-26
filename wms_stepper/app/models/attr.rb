class Attr < ActiveRecord::Base
  belongs_to :step, :counter_cache => true
  belongs_to :form, :counter_cache => true
  has_many :attr_validations
  has_many :validations, :through => :attr_validations
  after_save :set_form_id

  def set_form_id
    self.update_attributes(:form_id => self.step.form_id) unless self.form_id # and self.step.form_id
  end

  # handles the per item validation
  def custom_validate(val)
    self.required
  end

  class << self
    def element_options
      [
        ["input", "input"],
        ["select", "select"],
        ["textarea", "textarea"],
        ["password", "password"],
      ]
    
    end
  end
end
