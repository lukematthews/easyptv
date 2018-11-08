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

ActiveRecord::Schema.define(version: 20181001055514) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "departures", force: :cascade do |t|
    t.integer "stop_api_id"
    t.bigint "stop_id"
    t.integer "route_api_id"
    t.bigint "route_id"
    t.integer "run_api_id"
    t.bigint "run_id"
    t.integer "direction_api_id"
    t.bigint "direction_id"
    t.string "scheduled_departure_utc"
    t.string "estimated_departure_utc"
    t.boolean "at_platform"
    t.string "platform_number"
    t.string "flags"
    t.integer "departure_sequence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["direction_id"], name: "index_departures_on_direction_id"
    t.index ["route_id"], name: "index_departures_on_route_id"
    t.index ["run_id"], name: "index_departures_on_run_id"
    t.index ["stop_id"], name: "index_departures_on_stop_id"
  end

  create_table "directions", force: :cascade do |t|
    t.integer "direction_id"
    t.string "direction_name"
    t.bigint "route_id"
    t.integer "route_api_id"
    t.bigint "route_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["direction_id"], name: "index_directions_on_direction_id"
    t.index ["route_id"], name: "index_directions_on_route_id"
    t.index ["route_type_id"], name: "index_directions_on_route_type_id"
  end

  create_table "expresses", force: :cascade do |t|
    t.string "abbreviation"
    t.string "description"
    t.bigint "start_stop_id"
    t.bigint "end_stop_id"
    t.bigint "route_id"
    t.bigint "direction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["direction_id"], name: "index_expresses_on_direction_id"
    t.index ["end_stop_id"], name: "index_expresses_on_end_stop_id"
    t.index ["route_id"], name: "index_expresses_on_route_id"
    t.index ["start_stop_id"], name: "index_expresses_on_start_stop_id"
  end

  create_table "patterns", force: :cascade do |t|
    t.integer "stop_api_id"
    t.bigint "stop_id"
    t.integer "route_api_id"
    t.bigint "route_id"
    t.integer "run_api_id"
    t.bigint "run_id"
    t.string "scheduled_departure_utc"
    t.string "estimated_departure_utc"
    t.boolean "at_platform"
    t.string "platform_number"
    t.string "flags"
    t.integer "departure_sequence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_patterns_on_route_id"
    t.index ["run_id"], name: "index_patterns_on_run_id"
    t.index ["stop_id"], name: "index_patterns_on_stop_id"
  end

  create_table "route_types", force: :cascade do |t|
    t.integer "route_type"
    t.string "route_type_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "routes", force: :cascade do |t|
    t.bigint "route_type_id"
    t.integer "route_type_api_id"
    t.integer "route_id"
    t.string "route_name"
    t.string "route_number"
    t.string "route_gtfs_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "map_url"
    t.index ["route_type_id"], name: "index_routes_on_route_type_id"
  end

  create_table "run_days", force: :cascade do |t|
    t.bigint "route_id"
    t.bigint "stop_id"
    t.bigint "direction_id"
    t.string "day_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["direction_id"], name: "index_run_days_on_direction_id"
    t.index ["route_id"], name: "index_run_days_on_route_id"
    t.index ["stop_id"], name: "index_run_days_on_stop_id"
  end

  create_table "run_time_expresses", force: :cascade do |t|
    t.bigint "run_time_id"
    t.bigint "express_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["express_id"], name: "index_run_time_expresses_on_express_id"
    t.index ["run_time_id"], name: "index_run_time_expresses_on_run_time_id"
  end

  create_table "run_times", force: :cascade do |t|
    t.bigint "run_day_id"
    t.integer "hour"
    t.integer "minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["run_day_id"], name: "index_run_times_on_run_day_id"
  end

  create_table "runs", force: :cascade do |t|
    t.integer "run_id"
    t.integer "route_api_id"
    t.integer "route_type_api"
    t.integer "final_stop_id"
    t.string "destination_name"
    t.string "status"
    t.integer "direction_api_id"
    t.integer "run_sequence"
    t.integer "express_stop_count"
    t.bigint "route_id"
    t.bigint "route_type_id"
    t.bigint "direction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["direction_id"], name: "index_runs_on_direction_id"
    t.index ["route_id"], name: "index_runs_on_route_id"
    t.index ["route_type_id"], name: "index_runs_on_route_type_id"
  end

  create_table "stop_orders", force: :cascade do |t|
    t.bigint "route_id"
    t.bigint "direction_id"
    t.bigint "stop_id"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["direction_id"], name: "index_stop_orders_on_direction_id"
    t.index ["route_id"], name: "index_stop_orders_on_route_id"
    t.index ["stop_id"], name: "index_stop_orders_on_stop_id"
  end

  create_table "stops", force: :cascade do |t|
    t.integer "stop_id"
    t.string "stop_name"
    t.integer "route_type_api_id"
    t.bigint "route_type_id"
    t.bigint "route_id"
    t.string "stop_suburb"
    t.string "station_type"
    t.string "station_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_stops_on_route_id"
    t.index ["route_type_id"], name: "index_stops_on_route_type_id"
    t.index ["stop_id"], name: "index_stops_on_stop_id"
  end

  add_foreign_key "departures", "directions"
  add_foreign_key "departures", "routes"
  add_foreign_key "departures", "runs"
  add_foreign_key "departures", "stops"
  add_foreign_key "directions", "route_types"
  add_foreign_key "directions", "routes"
  add_foreign_key "expresses", "directions"
  add_foreign_key "expresses", "routes"
  add_foreign_key "expresses", "stops", column: "end_stop_id"
  add_foreign_key "expresses", "stops", column: "start_stop_id"
  add_foreign_key "patterns", "routes"
  add_foreign_key "patterns", "runs"
  add_foreign_key "patterns", "stops"
  add_foreign_key "routes", "route_types"
  add_foreign_key "run_days", "directions"
  add_foreign_key "run_days", "routes"
  add_foreign_key "run_days", "stops"
  add_foreign_key "run_time_expresses", "expresses"
  add_foreign_key "run_time_expresses", "run_times"
  add_foreign_key "run_times", "run_days"
  add_foreign_key "runs", "directions"
  add_foreign_key "runs", "route_types"
  add_foreign_key "runs", "routes"
  add_foreign_key "stop_orders", "directions"
  add_foreign_key "stop_orders", "routes"
  add_foreign_key "stop_orders", "stops"
  add_foreign_key "stops", "route_types"
  add_foreign_key "stops", "routes"
end
