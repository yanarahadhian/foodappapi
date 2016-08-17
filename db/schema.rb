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

ActiveRecord::Schema.define(version: 20150819043441) do

  create_table "images", force: :cascade do |t|
    t.string   "storage",    limit: 255
    t.string   "flag",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "item_id",    limit: 4
    t.integer  "user_id",    limit: 4
  end

  add_index "images", ["item_id"], name: "index_images_on_item_id", using: :btree
  add_index "images", ["user_id"], name: "index_images_on_user_id", using: :btree

  create_table "item_categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "items", force: :cascade do |t|
    t.integer  "item_category_id", limit: 4
    t.string   "name",             limit: 255
    t.float    "delivery_fee",     limit: 24
    t.float    "price",            limit: 24
    t.text     "description",      limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "user_id",          limit: 4
  end

  add_index "items", ["item_category_id"], name: "index_items_on_item_category_id", using: :btree
  add_index "items", ["user_id"], name: "index_items_on_user_id", using: :btree

  create_table "items_stores", id: false, force: :cascade do |t|
    t.integer "item_id",  limit: 4
    t.integer "store_id", limit: 4
  end

  add_index "items_stores", ["item_id"], name: "index_items_stores_on_item_id", using: :btree
  add_index "items_stores", ["store_id"], name: "index_items_stores_on_store_id", using: :btree

  create_table "stores", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "country",    limit: 255
    t.string   "street",     limit: 255
    t.string   "latlong",    limit: 255
    t.string   "location",   limit: 255
    t.string   "phone",      limit: 255
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "city",       limit: 255
  end

  add_index "stores", ["user_id"], name: "index_stores_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",              limit: 255
    t.string   "password_digest",    limit: 255
    t.string   "access_token",       limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "full_name",          limit: 255,   default: ""
    t.datetime "token_generated_at"
    t.text     "settings",           limit: 65535
    t.string   "facebook_id",        limit: 255
    t.text     "verified_fb",        limit: 65535
    t.string   "country",            limit: 255
    t.string   "city",               limit: 255
    t.string   "website_url",        limit: 255
    t.text     "about_me",           limit: 65535
    t.string   "phone",              limit: 255
  end

  add_index "users", ["access_token"], name: "index_users_on_access_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  add_foreign_key "images", "items"
  add_foreign_key "images", "users"
  add_foreign_key "items", "item_categories"
  add_foreign_key "items", "users"
  add_foreign_key "items_stores", "items"
  add_foreign_key "items_stores", "stores"
  add_foreign_key "stores", "users"
end
