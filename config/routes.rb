Rails
  .application
  .routes
  .draw do
    scope '(:locale)', locale: /en|pt/ do
      resources :students, only: %i[index show create]
      resources :enrollments, only: %i[index show create]
    end

    match '*path', to: 'application#routing_error', via: %i[get post]
  end
