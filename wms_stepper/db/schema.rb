# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121120200253) do

  create_table "attr_validations", :force => true do |t|
    t.integer  "attr_id"
    t.integer  "validation_id"
    t.integer  "order"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "attrs", :force => true do |t|
    t.string   "name"
    t.string   "display_name"
    t.integer  "step_id"
    t.string   "reck",         :default => "false"
    t.integer  "form_id"
    t.string   "element"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  create_table "forms", :force => true do |t|
    t.string   "name"
    t.string   "cancel_url"
    t.string   "element"
    t.string   "redirect_to"
    t.integer  "steps_count",   :default => 0
    t.integer  "attrs_count",   :default => 0
    t.boolean  "nav",           :default => false
    t.integer  "first_step_id"
    t.integer  "last_step_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "steps", :force => true do |t|
    t.integer  "form_id"
    t.string   "name"
    t.string   "template"
    t.integer  "prev_step_id"
    t.integer  "next_step_id"
    t.integer  "position"
    t.integer  "attrs_count"
    t.integer  "nav_step"
    t.string   "nav_step_name"
    t.boolean  "signin_required", :default => false
    t.text     "before_snippet"
    t.text     "after_snippet"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "validations", :force => true do |t|
    t.string   "name"
    t.string   "desc"
    t.text     "snippet"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
