class CreateAttrs < ActiveRecord::Migration
  def change
    create_table :attrs do |t|
      t.string :name
      t.string :display_name
      t.integer :step_id
      t.string :reck, :default => "false"
      t.integer :form_id
      t.string :element

      t.timestamps
    end
  end
end
