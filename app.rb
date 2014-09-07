require 'sinatra'
require 'slim'

class App < Sinatra::Base
  register Sinatra::Reloader

  get '/' do
    slim :index
  end
end
