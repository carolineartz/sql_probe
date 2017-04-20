SqlProbe::Engine.routes.draw do
  root to: 'main#index'

  post 'start', to: 'main#start'
  post 'stop', to: 'main#stop'
  post 'reset', to: 'main#reset'

  get 'event', to: 'events#show'
  get 'event/code', to: 'events#code'
  get 'event/raw', to: 'events#raw', as: :download_raw
  get 'event/view', to: 'events#view', as: :view_raw

  get 'live/feed', to: 'live#feed'
  get 'live', to: 'live#index', as: :live
end
