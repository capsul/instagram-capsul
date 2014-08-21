require './insta_fetcher'

if development?
  require 'dotenv'
  Dotenv.load
end

run Sinatra::Application