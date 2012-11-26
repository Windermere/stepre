class CreateAttrValidations < ActiveRecord::Migration
  def change
    create_table :attr_validations do |t|
      t.integer :attr_id
      t.integer :validation_id
      t.integer :order

      t.timestamps
    end
  end
end
