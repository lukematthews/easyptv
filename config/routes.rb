Rails.application.routes.draw do
	root 'home#index'
	 # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

 	get '/timetable/:id', to: 'timetable#index'
	resources :timetable 	
end
