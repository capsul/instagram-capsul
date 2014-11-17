require 'sinatra'
require 'json'
load './insta_query.rb'

get '/media' do

  instagrams = InstaQuery.search(params)
  
  return {
    latitude:   params[:lat], 
    longitude:  params[:lng],
    time:       params[:time],
    media:      instagrams
  }.to_json
  
end