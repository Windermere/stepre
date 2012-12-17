class Validation < ActiveRecord::Base
  has_many :attr_validations
  has_many :attrs, :through => :attr_validations

  scope :without_attrs, includes(:attrs).merge(AttrValidation.where(:attr_id => nil))

  def self.attrs_except(attr_id)
    # should roll following two queries into one
    taken = Validation.joins(:attrs).where(["attr_validations.attr_id = ?", attr_id]).collect {|o| o.id}
    Validation.where("id not in (#{taken.join})")
  end
end
