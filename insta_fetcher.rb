require 'sinatra'
require 'json'
load './insta_helper.rb'

get '/photos' do
  tweets = Tweets.search(params)
  
  return {
    latitude:   params[:lat], 
    longitude:  params[:lng],
    time:       params[:time],
    photos:     photos
  }.to_json
end