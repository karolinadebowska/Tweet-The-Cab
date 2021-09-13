require 'twitter'
require 'oauth'
require './database/database'
require 'sinatra'
require 'erb'
include ERB::Util
set :bind, '0.0.0.0' # Only needed if you're running from Codio

host = ARGV.first
if host.nil?
  host=ENV["CODIO_BOX_DOMAIN"][0..-10]
end
if not host[0..3]=="http"
 host = "http://" + host + "-4567.codio.io/"
end
puts(host)

enable :sessions
set :session_secret, 'key goes here'

shefconfig = {
    :consumer_key => 'mEgXqaidSyHKR3qCd94ABdCg4',
    :consumer_secret => 'OnNoGwjmrgsJQbxN5NRKA2GJaAvP7Kh2mLAURiPYNtENihalV8',
    :access_token => '1092448154547617792-6yRzxQv9BKs4MOkW3Ax06LkE5oFoqo',
    :access_token_secret => 'Sijah6AJ0CVudlpNVjCJAfnIArsN7DT3dwraLAGHUNBPq'
}
birmconfig = {
    :consumer_key => 'yZ8U1E1yyzZoKwJ68zOfAsmTp',
    :consumer_secret => 'RNdNDlkSaRxUZV6gaNzkXtJkACAvvIYBTMgcNrxwA6VPIoADuD',
    :access_token => '1125904330761101312-2KLTF4dhs5q2FpFr4l630LetRXF553',
    :access_token_secret => 'iBCzVmOV8KWpDGaPkNpy0l1PMq32hjU1kuuwC13Pir6T1'
}

client = Twitter::REST::Client.new(shefconfig)
clientb= Twitter::REST::Client.new(birmconfig)
oauth = OAuth::Consumer.new(shefconfig[:consumer_key], shefconfig[:consumer_secret],
                             { :site => "https://api.twitter.com/" })

database = Database.new
errorMessage=""

get '*' do
    @database=database
    @permission=Hash.new false
    @permission["user"]=session[:logged_in]
    @permission["driver"]=database.isDriver(session[:username])
    @permission["transcriber"]= (session[:username]=="ise19team19" or session[:username]=="ise19team19b")
    if @permission["transcriber"] then
      if session[:username]=="ise19team19"
        @permission["city"]="Sheffield"
      else
        @permission["city"]="Birmingham"
      end
    else
      @permission["city"]=nil
    end 
    pass
end

get '/' do
    erb :index
end

get '/signin' do
    begin
      tokenthing=oauth.get_request_token(:oauth_callback => (host + "auth/twitter/callback"))
    rescue
      puts()
      puts("======================")
      puts()
      puts("Twitter has refused the request token request.")
      puts("- Make sure that this program was started with the correct argument.")
      puts("- Ensure that the callback URL is authorised by adding it to the twitter developer app settings.")
      puts()
      puts("======================")
      puts()
      errorMessage="This website was not set up correctly. Please refer to the console for additional details."
      redirect '/403'
    end
    session[:request_token]=tokenthing
    redirect 'https://api.twitter.com/oauth/authenticate?oauth_token='+tokenthing.token;
end

get '/signout'do
    session[:logged_in]=false
    session[:username]=nil
    redirect '/'
end

get '/auth/twitter/callback' do
    session[:access_token]=session[:request_token].get_access_token oauth_verifier: params[:oauth_verifier];
    userAccess=Twitter::REST::Client.new({
      :access_token => session[:access_token].token,
      :access_token_secret =>session[:access_token].secret,
      :consumer_key => shefconfig[:consumer_key],
      :consumer_secret => shefconfig[:consumer_secret]
      })
    session[:logged_in]=true
    session[:username]=userAccess.user.screen_name
    session[:username]
    if !database.customerExists(session[:username]) then
      database.addCustomer(session[:username])
    end 
    redirect '/'
end

get '/add' do
    verify(@permission, "transcriber")
    erb :addAccounts
end

post '/add' do
    unless params.nil?
        database.newDriver(params[:firstName],params[:secondName],params[:phone].strip,params[:twitter].strip,params[:car], params[:city])
        database.addCar(params[:carMake],params[:carModel],params[:colour], params[:seats],params[:licence].strip)
        database.updateCarId(params[:licence].strip,params[:twitter].strip)
    end
    redirect '/add'
end

get '/driver' do
    verify(@permission, "driver")
    @driver=database.getDriversByTwitter(session[:username])[0]
    driver_id=@driver[0]
    #@cars = database.getCarByDriver(driver_id)
    @journeys=database.getJourneyByDriver(session[:username]) 
    erb :driver
end

post '/driver' do 
    database.updateDriver(params[:firstname],params[:lastname],params[:phone],session[:username],params[:city])
    carid=database.getDriversByTwitter(session[:username])[0][1]
    database.updateCar(carid, params[:cmake],params[:cmodel],params[:colour], params[:seats],params[:licence].strip)
  redirect '/driver'
end

get '/delete' do 
    database.deleteDriverByTwitter(params[:twitter])
    redirect '/driver'
end
get '/driverhistory' do
    verify(@permission, "driver")
    @driver=database.getDriversByTwitter(session[:username])[0]
    driver_id=@driver[0]
    @journeys=database.getJourneyByDriver(session[:username]) 
    erb :driverhistory
end

post '/driver/activate' do
    database.setActive(params["driverid"], params["active"])
    redirect '/driver'
end

get '/update' do 
   database.updateJourneyStartTime(params["start"], params["id"]) 
    database.setActive(session[:username], 0)
    database.setJourneyStatus(params["id"],"started")
end

get '/updatefinish' do 
    database.updateJourneyEndTime(params["stop"], params["id"])
    database.setActive(session[:username], 1)
    database.setJourneyStatus(params["id"],"finished")
end

get '/transcriber' do
    verify(@permission, "transcriber")
    syncTweets(database, client,clientb)
    @tweets=database.getTweets(0,5,@permission["city"]).reverse()
    @tweets.each() do |tweet|
      tweet[tweet.size]="unassigned"
      journeys=database.getJourneyByTweet(tweet[0])
      if journeys.size==1 then
        tweet[tweet.size-1]=journeys[0][10]
      elsif journeys.size>1 then
        tweet[tweet.size-1]="Error: multiple journeys assigned"
      end
    end
    erb :transcriber
end

get '/allocate' do
    verify(@permission, "transcriber")
    @drivers=database.getDrivers(@permission["city"])
    @tweetNumber=params[:tweet]
    erb :allocate
end

post '/allocate' do
    tweet=database.getTweetByPrimaryKey(params[:tweetid])
    database.addJourney(0, params[:assign],params[:pickup],params[:dropoff],params[:number],params[:tweetid],params[:extraInfo])
    database.retroactivelyAssignCustomerID(tweet[1])
    redirect '/transcriber'
end

get '/about' do
    erb :about
end

get '/cars' do
    erb :cars
end

get '/feedback' do
    erb :feedback
end

get '/thankyou' do 
    erb :thankyou
end

post '/feedback' do
    unless params.nil?
        database.addFeedbackByTwitter(session[:username].strip,params[:subject].strip,params[:feedback].strip)
        redirect 'thankyou'
    end
end

get '/displayfeedback' do
    verify(@permission, "transcriber")
    @feedback=database.getFeedback()
    erb :displayfeedback
end

get '/user' do
    verify(@permission, "user")
    database.retroactivelyAssignCustomerID(session[:username])
    @journeys=database.getJourneyByCustomer(database.getCustomerIdByTwitter(session[:username]))
    @journeys.each() do |journey|
      journeydriver=database.getDriverByID(journey[2])
      journey[journey.size]=journeydriver[3]+" "+journeydriver[4]
    end
    @userdetails=database.getCustomerByTwitter(session[:username])[0]
    erb :user
end

post '/user' do
    database.updateCustomer(params[:dob],params[:firstname],params[:surname],params[:phone],session[:username])
    redirect '/user'
end

get '/db' do
    verify(@permission, "transcriber")
    @drivers = database.executeQuery(%{SELECT * FROM driver},[])
    @tweets = database.getAllTweets()#0,10)
    @journeys = database.executeQuery(%{SELECT * FROM journey},[])
    erb :dbdebug
end

get '/respond' do
    verify(@permission, "transcriber")
    @tweet = database.getTweetByPrimaryKey(params[:tweet])
    erb :respond
end

post '/respond' do
    handle = params[:handle]
    targetTweet = params[:targetTweet]
    if params[:type]=="confirm"
      message="Your request for a taxi is being processed."
    elsif params[:type]=="deny"
      message="We're sorry, your request could not be processed."
    elsif params[:type]=="custom"
      message=params[:message]
    end
    if session[:username]=="ise19team19" then
      client.update("@"+params[:handle]+" "+message, in_reply_to_status_id: targetTweet)
    elsif session[:username]=="ise19team19b" then
      clientb.update("@"+params[:handle]+" "+message, in_reply_to_status_id: targetTweet)
    end
    redirect '/transcriber'
end

get '/401' do
    erb :unauthorised
end

get '/403' do
    @errorMessage=errorMessage
    erb :forbidden
end

def syncTweets(database, client, clientb)
  database.addTweets(mentions = client.mentions_timeline().take(10), "Sheffield")
  database.addTweets(mentions = clientb.mentions_timeline().take(10), "Birmingham")
end

def verify(permission,level)
    if level=="user"
      unless permission["user"]
        redirect '/401'
        return 0
      end
      return 1
    end
    if level=="driver"
      unless permission["driver"]
        return 0
        errorMessage="You must be an authorised driver to continue."
        redirect '/403'
      end 
      return 1
    end
    if level=="transcriber"
      unless permission["transcriber"]
        return 0
        errorMessage="You must be an authorised transcriber or admin to continue."
        redirect '/403'
      end
      return 1
    end
end