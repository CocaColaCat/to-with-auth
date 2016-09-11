Rails.application.routes.draw do
  resources :todos

  # 配置 user 资源的路由，只支持 new 和 create
  resources :users, only: [:new, :create, :edit, :update]

  get '/login', to: 'sessions#new'           # 获取登录表路由
  post '/login', to: 'sessions#create'       # 登录路由
  delete '/logout', to: 'sessions#destroy'   # 登出路由
end
