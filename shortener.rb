require 'sinatra'
require 'active_record'
require 'pry'
require 'json'

###########################################################
# Configuration
###########################################################

set :public_folder, File.dirname(__FILE__) + '/public'

configure :development, :production do
    ActiveRecord::Base.establish_connection(
       :adapter => 'sqlite3',
       :database =>  'db/dev.sqlite3.db'
     )
end

# Handle potential connection pool timeout issues
after do
    ActiveRecord::Base.connection.close
end

###########################################################
# Models
###########################################################
# Models to Access the database through ActiveRecord.
# Define associations here if need be
# http://guides.rubyonrails.org/association_basics.html

class Link < ActiveRecord::Base
end

###########################################################
# Routes
###########################################################

get '/' do
    @links = Link.all # FIXME
    erb :index
end

get '/new' do
    erb :form
end

get '/:shortURL' do
  rowData = Link.find_by_shortLink(params[:shortURL])
  if rowData
    redirect "http://#{rowData.realLink}"
  else
    @links = Link.all
    erb :index
  end
end

post '/new' do
    # PUT CODE HERE TO CREATE NEW SHORTENED LINKS
    userInput = params[:url]
    rowData = Link.find_by_realLink(userInput)
    if rowData
      return shortenedLink = rowData.shortLink
    else
      shortenedLink = convertLink(userInput)
      @newLink = Link.new(shortLink: shortenedLink, realLink: userInput)
      @newLink.save
      return shortenedLink
    end
end

# MORE ROUTES GO HERE

###########################################################
# Helpers
###########################################################

def convertLink originalLink
  begin
    result = SecureRandom.urlsafe_base64[0..4]
  end while Link.find_by_shortLink(result)
  result
end