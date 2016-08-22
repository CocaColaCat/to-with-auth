Rails.application.routes.draw do
  resources :todos

  # 配置 user 资源的路由，只支持 new 和 create
  resources :users, only: [:new, :create]

  # 配置登录路由
  get '/login', to: 'sessions#new'
end
