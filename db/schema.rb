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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160611051629) do

  create_table "annotations", force: :cascade do |t|
    t.integer  "userId"
    t.float    "dollarAmount"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "budgetposts", force: :cascade do |t|
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "picture"
    t.integer  "budgetId"
    t.string   "statecode"
    t.integer  "year"
    t.string   "subcategory"
    t.boolean  "isexpense"
    t.float    "dollarAmount"
    t.string   "supercategory"
    t.integer  "annotationId"
    t.boolean  "isbaseline"
    t.string   "author"
    t.string   "comments"
    t.string   "reference"
  end

  add_index "budgetposts", ["user_id", "created_at"], name: "index_budgetposts_on_user_id_and_created_at"
  add_index "budgetposts", ["user_id"], name: "index_budgetposts_on_user_id"

  create_table "budgets", force: :cascade do |t|
    t.string   "statecode"
    t.integer  "period"
    t.string   "author"
    t.string   "comments"
    t.boolean  "deficit_allowed"
    t.boolean  "surplus_allowed"
    t.integer  "user_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "budgets", ["user_id"], name: "index_budgets_on_user_id"

  create_table "comments", force: :cascade do |t|
    t.text     "content"
    t.integer  "user_id"
    t.integer  "budgetpost_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "comments", ["budgetpost_id"], name: "index_comments_on_budgetpost_id"
  add_index "comments", ["user_id", "budgetpost_id", "created_at"], name: "index_comments_on_user_id_and_budgetpost_id_and_created_at"
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "relationships", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id"

  create_table "tracks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.boolean  "admin",             default: false
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
