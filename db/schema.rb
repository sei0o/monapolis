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

ActiveRecord::Schema.define(version: 20151206154614) do

  create_table "cities", force: :cascade do |t|
    t.string   "name",        limit: 255,   null: false
    t.string   "code",        limit: 255,   null: false
    t.text     "description", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "cities", ["code"], name: "index_cities_on_code", unique: true, using: :btree
  add_index "cities", ["name"], name: "index_cities_on_name", unique: true, using: :btree

  create_table "receipts", force: :cascade do |t|
    t.integer  "sender_user_id",       limit: 4
    t.integer  "receiver_user_id",     limit: 4
    t.integer  "receiver_response_id", limit: 4
    t.decimal  "amount",                         precision: 15, scale: 8, default: 0.0, null: false
    t.integer  "kind",                 limit: 4,                                        null: false
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
  end

  create_table "responses", force: :cascade do |t|
    t.text     "body",       limit: 65535, null: false
    t.integer  "user_id",    limit: 4,     null: false
    t.integer  "topic_id",   limit: 4,     null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "topics", force: :cascade do |t|
    t.string   "title",      limit: 255, null: false
    t.integer  "city_id",    limit: 4,   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "topics", ["title"], name: "index_topics_on_title", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",           limit: 255,   null: false
    t.text     "description",    limit: 65535
    t.string   "password",       limit: 255,   null: false
    t.string   "password_salt",  limit: 255,   null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "github_name",    limit: 255
    t.string   "wallet_address", limit: 255,   null: false
  end

  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree
  add_index "users", ["wallet_address"], name: "index_users_on_wallet_address", unique: true, using: :btree

end
