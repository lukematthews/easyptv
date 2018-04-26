Rails.application.routes.draw do
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
	root 'setup#index'

 	get '/timetable/:id', to: 'timetable#index'
	resources :timetable
	# get '/timetable/:id', to: 'timetable#index'

	resources :setup do
		member do
			get 'routes'
		end
	end

	get '/stops/:id', to: 'setup#stops'
	get '/directions/:id', to: 'setup#directions'
	get '/bus_operators', to: 'setup#bus_operators'

	resources :about
end