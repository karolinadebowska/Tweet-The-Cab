 require 'sqlite3'

class Database
    
    def initialize
        @db = SQLite3::Database.open File.dirname(__FILE__) + '/team19.sqlite'
    end
    
    #DRIVER
    def newDriver(fname,sname,phone,twitter,car,city)
        query=%{INSERT INTO driver (firstname,surname,phone,twitter,car_ID,active,city) VALUES (?,?,?,?,?,1,?);}
        @db.execute(query,[fname,sname,phone,twitter,car,city])
    end
        
    def isDriver(twitter)
        query=%{SELECT COUNT(*) FROM driver WHERE twitter=?;}
        return @db.execute(query,[twitter])[0][0]>0
    end
  
    def getDriversByTwitter(twitter)
        query=%{SELECT * FROM driver WHERE twitter=?;}
        return @db.execute(query,[twitter])
    end

    def getDriverByID(drid)
        query=%{SELECT * FROM driver WHERE driver_id=?;}
        return @db.execute(query,[drid])[0]
    end

    def getDriverCity(driver_ID)
        query=%{SELECT driver.city FROM driver WHERE driver.driver_ID=?;}
        return @db.execute(query,[driver_ID])
    end
    
    def getDrivers(city)
        query=%{SELECT * FROM driver WHERE city=?;}
        return @db.execute(query,[city])
    end
     
    def setActive(driverId, active)
        query=%{UPDATE driver SET active=? WHERE driver_ID=?;}
        puts active
        puts driverId
        puts @db.execute(query,[active,driverId])
    end
      
     def updateDriver(fname,sname,phone,twitter,city)
         query=%{UPDATE driver SET firstname=?,surname=?,phone=?,city=? WHERE twitter=?;}
         @db.execute(query,[fname,sname,phone,city,twitter])
     end
        
    #TWEET
    def getAllTweets()
        query=%{SELECT * FROM tweet;}
        return @db.execute(query)
    end
        
    def getTweets(from, to, city)
        query=%{SELECT * FROM tweet WHERE city=?;}
        from+=1
        to+=1
        tweets = @db.execute(query,[city])
        if to-from>=tweets.size
          return tweets
        end
        return tweets[(-to)..(-from)]
    end
        
    def getTweetByPrimaryKey(tweet_id)
        query=%{SELECT * FROM tweet WHERE tweet_id=?;}
        return @db.execute(query,[tweet_id])[0]
    end
        
    def tweetExists(tweet_id)
        query=%{SELECT COUNT(*) FROM tweet WHERE twitter_tweet_id=?;}
        return @db.execute(query,[tweet_id])[0][0]>0
    end
        
    def addTweets(timeline, city)
        timeline.reverse_each do |tweet|
            if not tweetExists(tweet.id)
              query=%{INSERT INTO tweet (twitter,message,twitter_tweet_id,city) VALUES (?,?,?,?);}
              @db.execute(query,[tweet.user.screen_name,tweet.text,tweet.id,city])
            end
        end
    end
    
    #CAR         
     def updateCarId(lic,twit)
         id=getCarByLicence_Plate(lic)[0][0]
         query=%{UPDATE driver SET car_ID=? WHERE twitter=?;}
         @db.execute(query,[id,twit])
     end
        
    def getCars()
        query=%{SELECT * FROM car;}
        return @db.execute(query)
    end
        
    def addCar(make, model, colour, seats, licence_plate)
        query=%{INSERT INTO car (make,model,colour,seats,licence_plate) VALUES (?,?,?,?,?);}
        @db.execute(query,[make,model,colour,seats,licence_plate])
    end
        
    def updateCar(carid, make, model, colour, seats, licence_plate)
        query=%{UPDATE car SET make=?,model=?,colour=?,seats=?,licence_plate=? WHERE car_ID=?;}
        puts @db.execute(query,[make,model,colour,seats,licence_plate,carid])
        puts carid
        puts "=========================================="
    end
        
    def getCarByMake(make)
        query=%{SELECT * FROM car WHERE car.make=?;}
        return @db.execute(query,[make])
    end
        
    def getCarBySeats(seats)
        query=%{SELECT * FROM car WHERE car.seats=?;}
        return @db.execute(query,[seats])
    end
        
    def getCarByLicence_Plate(licence_plate)
        query=%{SELECT * FROM car WHERE car.licence_plate=?;}
        return @db.execute(query,[licence_plate])
    end
        
    def getCarByID(car_ID)
        query=%{SELECT * FROM car WHERE car_ID=?;}
        return @db.execute(query,[car_ID])
    end
        
    def getCarByDriver(driver_id)
        query=%{SELECT car.* FROM car,driver WHERE driver.car_ID=car.car_ID AND driver.driver_ID=?;}
        return @db.execute(query,[driver_id])
    end
      
    def getCarIdByDriver(driver_id)
        query=%{SELECT car_ID FROM driver WHERE driver_ID=?;}
        return @db.execute(query,[driver_id])
    end
     
    #CUSTOMER    
    def getCustomerByID(customer_ID)
        query=%{SELECT customer.customer_ID FROM customer WHERE customer.customer_ID=?;}
        return @db.execute(query,[customer_ID])
    end
    def getCustomerByTwitter(twitter)
        query=%{SELECT * FROM customer WHERE twitter=?;}
        return @db.execute(query,[twitter])
    end

    def getCustomerTwitter(id)
        query=%{SELECT twitter FROM customer WHERE customer_ID=?;}
        return @db.execute(query,[id])
    end
    
    def getCustomerIdByTwitter(twitter)
        query=%{SELECT customer_ID FROM customer WHERE twitter=?;}
        return @db.execute(query,[twitter])
    end
    
    def customerExists(twitter)
        query=%{SELECT COUNT(*) FROM customer WHERE twitter=?;}
        return @db.execute(query,[twitter])[0][0]>0
    end

    def updateCustomer(dob,firstname,surname,phone,twitter)
        query=%{UPDATE customer SET dob=?,firstname=?,surname=?,phone=? WHERE twitter=?;}
        @db.execute(query,[dob,firstname,surname,phone,twitter])
    end
        
    def addCustomer(twitter)
        query=%{INSERT INTO customer (twitter) VALUES (?);}
        @db.execute(query,[twitter])
    end    
    
    def retroactivelyAssignCustomerID(twitter)
        customer_id=getCustomerIdByTwitter(twitter)
        query=%{SELECT tweet_ID FROM tweet WHERE twitter=?}
        @db.execute(query,[twitter]).each do |this_id|
            query=%{UPDATE journey SET customer_ID=? WHERE tweet_ID=?;}
            @db.execute(query,[customer_id,this_id])
        end
    end
    
    #FEEDBACK
    def getFeedback()
        query=%{SELECT * FROM feedback;}
        return @db.execute(query)
    end

    def addFeedbackByTwitter(twitter,subject,message)
        query=%{INSERT INTO feedback (twitter,subject,message) VALUES (?,?,?)}
        @db.execute(query,[twitter,subject,message])
    end    
    
    #JOURNEY
    def addJourney(customer_id,driver_id,startLoc, endLoc, num_people, tweet_id, comments)
        query=%{INSERT INTO journey (customer_id,driver_id,pickup_id,dropoff_id,num_people,tweet_id, comments, status) VALUES (?,?,?,?,?,?,?,"assigned");}
        @db.execute(query,[customer_id,driver_id,startLoc,endLoc,num_people,tweet_id, comments])
    end

    def getJourneyByDriver(twitter)
        query=%{SELECT journey.* FROM journey, driver WHERE journey.driver_id=driver.driver_id AND driver.twitter=?;}
        return @db.execute(query,[twitter])
    end
        
    def getJourneyByTweet(tweet_id)
        query=%{SELECT * FROM journey WHERE tweet_id=?;}
        return @db.execute(query,[tweet_id])
    end
      
    def getJourneyByCustomer(customer_id)
        query=%{SELECT * FROM journey WHERE customer_id=?;}
        return @db.execute(query,[customer_id])
    end

    def updateJourneyStartTime(time,journey_ID)
        query=%{UPDATE journey SET startTime=? WHERE journey_ID=?;}
        @db.execute(query,[time,journey_ID])
    end
    
    def updateJourneyEndTime(time,journey_ID)
        query=%{UPDATE journey SET endTime=? WHERE journey_ID=?;}
        @db.execute(query,[time,journey_ID])
    end
        
    def setJourneyStatus(journey_ID,status)    
        query=%{UPDATE journey SET status=? WHERE journey_ID=?;}
        @db.execute(query,[status,journey_ID])
    end
      
end
    