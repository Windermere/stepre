# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

@form = Form.create(:name => "awesome", :element => "processor")
@step_1 = @form.steps.create(:name => "cool", :nav_step => 1, :nav_step_name => "Start")
@step_2 = @form.steps.create(:name => "rad", :nav_step => 2, :nav_step_name => "Next")
@step_3 = @form.steps.create(:name => "yeah_buddy", :nav_step => 3, :nav_step_name => "Next")
@step_4 = @form.steps.create(:name => "double_wide", :nav_step => 4, :nav_step_name => "Almost")
@step_1.attrs.create(:name => "beer", :display_name => "Beer", :element => "input")
@step_1.attrs.create(:name => "chips", :display_name => "Chips", :element => "input")
@step_1.attrs.create(:name => "trailer_park", :display_name => "Trailer Park", :element => "input")
@step_2.attrs.create(:name => "mullet", :display_name => "Mullet", :element => "input")
@step_2.attrs.create(:name => "jerry_springer", :display_name => "Jerry Springer", :element => "input")
@step_3.attrs.create(:name => "camaro", :display_name => "Camaro", :element => "input")
@step_3.attrs.create(:name => "iroc_z", :display_name => "Iroc Z", :element => "textarea")
