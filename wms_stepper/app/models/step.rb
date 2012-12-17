class Step < ActiveRecord::Base
  belongs_to :form, :counter_cache => true
  has_many :attrs

  #
  # after save callback
  #
  after_save :_after_save_callback

  def _after_save_callback
    self.set_position
  end

  def set_position
    self.update_attributes(:position => self.form.steps.size) unless self.position
  end


  #
  # validations
  #
  #validates :position, :uniqueness => true

  def custom_validate(hash)
    self.attrs.each do |attr|
      #val = hash.fetch(attr.name, nil)
      ## do not allow empty strings by default and allow through validation args
      #val = nil if !val.nil? and val.to_s.strip.empty?
      pundit = Pundit.new(attr.name => hash.fetch(attr.name, nil))
      attr.validations.each do |vld|
        pundit.instance_eval(vld.snippet.gsub("ATTR", attr.name))
      end

      (pundit.errors.delete(:base) || []).each {|o| self.errors[:base] << o}
      self.errors.add(attr.name, pundit.errors[attr.name]) if pundit.errors.any?
    end

    return nil
  end



  #
  # instance methods
  #
  def is_first_step?
    self.form.first_step_id == self.id
  end

  def is_last_step?
    self.form.last_step_id == self.id
  end

  def next_step
    Step.find_by_id(self.next_step_id) || self.form.steps.where("position > ?", self.position).order("position asc").limit(1).first
  end

  def prev_step
    Step.find_by_id(self.prev_step_id) || self.form.steps.where("position < ?", self.position).order("position desc").limit(1).first
  end


  #
  # class methods
  #
  class << self
    
  end
end
