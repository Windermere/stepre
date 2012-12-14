class CreateForms < ActiveRecord::Migration
  def change
    create_table :forms do |t|
      t.string :name
      t.string :cancel_url
      t.string  :element
      t.string  :redirect_to
      t.integer :steps_count, :default => 0
      t.integer :attrs_count, :default => 0
      t.boolean :nav, :default => false
      t.integer :first_step_id
      t.integer :last_step_id

      t.timestamps
    end
  end
end
