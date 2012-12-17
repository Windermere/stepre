class CreateSteps < ActiveRecord::Migration
  def change
    create_table :steps do |t|
      t.integer :form_id
      t.string :name
      t.string :template
      t.boolean :layout, :default => true 
      t.integer :prev_step_id
      t.integer :next_step_id
      t.integer :position
      t.integer :attrs_count
      t.integer :nav_step
      t.string :nav_step_name
      t.boolean :signin_required, :default => false
      t.text :before_snippet
      t.text :after_snippet

      t.timestamps
    end
  end
end
