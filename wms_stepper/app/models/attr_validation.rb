class AttrValidation < ActiveRecord::Base
  belongs_to :attr
  belongs_to :validation
  validates_presence_of :attr, :validation
end
