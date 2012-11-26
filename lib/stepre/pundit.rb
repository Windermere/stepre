module Stepre
  class Pundit < OpenStruct
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend  ActiveModel::Naming

    # tell ActiveModel object is not persisted.
    def persisted?; false; end
  end
end
