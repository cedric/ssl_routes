Dummy::Application.routes.draw do
  match '/pages(/:action)', to: 'pages', action: :action, as: :page, ssl: true
end
