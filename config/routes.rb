Rails.application.routes.draw do
  # API routes
  namespace :api do
    namespace :v1 do
      resources :recipes do
        collection do
          get :search
        end
        member do
          patch 'image', to: 'recipes#update_image', as: 'update_image'
        end
      end
      resources :categories
      
      # Shopping list generation
      post 'shopping_lists/generate', to: 'shopping_lists#generate'
    end
  end
  
  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA routes
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  
  # Root route for Vue.js frontend
  root 'home#index'
  
  # This route will catch all other routes and direct them to the Vue.js router
  get '*path', to: 'home#index', constraints: ->(request) do
    !request.xhr? && request.format.html?
  end
end
