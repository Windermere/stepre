class CreateValidations < ActiveRecord::Migration
  def change
    create_table :validations do |t|
      t.string :name
      t.string :desc
      t.text :snippet

      t.timestamps
    end
  end
end
