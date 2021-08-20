require 'stackprof'

class App < Sinatra::Base
  use StackProf::Middleware, enalbed: true,
                             mode: :wall,
                             interval: 1000,
                             save_every: 5,
                             raw: true,
                             path: '/home/isucon/stackprof/'
end
