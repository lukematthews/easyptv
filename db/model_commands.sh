
rails generate model RouteType route_type:integer route_type_name:string --force

rails generate model Route route_type:references route_type_api_id:integer route_id:integer route_name:string route_number:string route_gtfs_id:string --force

rails generate model Stop stop_id:integer:index stop_name:string  route_type_api_id:integer route_type:references route:references stop_suburb:string stop_suburb:string station_type:string station_description:string --force

rails generate model Direction direction_id:integer:index direction_name:string route:references route_api_id:integer route_type:references --force

rails generate model Run run_id:integer route_api_id:integer  route_type_api:integer final_stop_id:integer destination_name:string status:string direction_api_id:integer run_sequence:integer express_stop_count:integer route:references route_type:references direction:references --force

rails generate model Departure stop_api_id:integer stop:references route_api_id:integer route:references  run_api_id:integer run:references direction_api_id:integer direction:references scheduled_departure_utc:string estimated_departure_utc:string at_platform:boolean platform_number:string flags:string departure_sequence:integer --force

rails generate model Pattern stop_api_id:integer stop:references route_api_id:integer route:references run_api_id:integer run:references scheduled_departure_utc:string estimated_departure_utc:string at_platform:boolean platform_number:string flags:string departure_sequence:integer --force

rails generate model RunDay route:references stop:references direction:references day_name:string --force

rails generate model RunTime run_day:references hour:integer minutes:integer --force

rails generate model StopOrder route:references direction:references stop:references order:integer

rails generate model Express abbreviation:string description:string start_stop:references end_stop:references route:references direction:references

rails generate model RunTimeExpress run_time:references express:references

rake db:migrate

