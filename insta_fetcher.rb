require 'sinatra'
require 'json'
load './insta_helper.rb'

get '/media' do
  media = Media.search(params)
  
  return {
    latitude:   params[:lat], 
    longitude:  params[:lng],
    time:       params[:time],
    media:      media
  }.to_json
end