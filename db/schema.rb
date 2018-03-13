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

ActiveRecord::Schema.define(version: 20180313122114) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "coordinates", force: :cascade do |t|
    t.float "latitude"
    t.float "longitude"
    t.bigint "route_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_coordinates_on_route_id"
  end

  create_table "favourites", force: :cascade do |t|
    t.bigint "route_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_favourites_on_route_id"
    t.index ["user_id"], name: "index_favourites_on_user_id"
  end

  create_table "interest_points", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.bigint "route_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "longitude"
    t.float "latitude"
    t.index ["route_id"], name: "index_interest_points_on_route_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.text "content"
    t.integer "rating"
    t.bigint "route_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_reviews_on_route_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "routes", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "difficulty"
    t.integer "duration"
    t.integer "ascent"
    t.integer "distance"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "hero_image", default: "https://images.unsplash.com/photo-1467294388771-b3e867a4d321?ixlib=rb-0.3.5&s=914592383364aed60abbfaf7b74d9ad4&auto=format&fit=crop&w=1050&q=80"
    t.string "image_gallery_1"
    t.string "image_gallery_2"
    t.string "coordinates"
    t.float "start_latitude"
    t.float "end_latitude"
    t.float "start_longitude"
    t.float "end_longitude"
    t.index ["user_id"], name: "index_routes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "photo", default: "http://res.cloudinary.com/dpu1qidv2/image/upload/v1520266484/default-profile.png"
    t.string "ability"
    t.text "bio"
    t.string "community_level", default: "Junior Oscaper"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "coordinates", "routes"
  add_foreign_key "favourites", "routes"
  add_foreign_key "favourites", "users"
  add_foreign_key "interest_points", "routes"
  add_foreign_key "reviews", "routes"
  add_foreign_key "reviews", "users"
  add_foreign_key "routes", "users"
end
