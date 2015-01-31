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

ActiveRecord::Schema.define(version: 20141126184347) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bartjourneys", force: true do |t|
    t.integer  "start_station_id"
    t.integer  "end_station_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "direction",        default: "Normal"
  end

  create_table "bartroutes", force: true do |t|
    t.string   "bart_route_name"
    t.string   "bart_route_short_name"
    t.string   "bart_route_id"
    t.integer  "bart_route_number"
    t.string   "bart_route_color"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bartroutestations", force: true do |t|
    t.integer  "bartstation_id"
    t.integer  "bartroute_id"
    t.integer  "route_station_sequence"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bartroutestations", ["bartroute_id"], name: "index_bartroutestations_on_bartroute_id", using: :btree
  add_index "bartroutestations", ["bartstation_id"], name: "index_bartroutestations_on_bartstation_id", using: :btree

  create_table "bartstations", force: true do |t|
    t.string   "station_name"
    t.string   "short_name"
    t.float    "gtfs_latitude"
    t.float    "gtfs_longitude"
    t.string   "address"
    t.string   "string"
    t.string   "city"
    t.string   "county"
    t.string   "state"
    t.string   "zipcode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_type"
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["user_type"], name: "index_users_on_user_type", using: :btree

  create_table "usertypes", force: true do |t|
    t.string   "user_type"
    t.boolean  "is_admin",   default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
