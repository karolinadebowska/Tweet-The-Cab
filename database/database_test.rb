require 'minitest/autorun'
require_relative 'database.rb'

class TestDataBase < MiniTest::Test
    $database = Database.new
    $driverId = 37
    $wrongId = 360
    $seats=2
    $driver = [1, 34, 37, "John", "Smith", 1234567890, "Karolin57569114", "Birmingham"]
    $correctTwitter = "Karolin57569114"
    $wrongTwitter = "Karolin575691141"
    $car = [34, "make", "model", "color", 2, "abc123"]
    $licence_plate="abc123"
    $journey = [9, 0, 37, "52°28'43.7\"N 1°53'57.6\"W", "52°28'47.0\"N 1°54'10.9\"W", "2019-05-10 14:13:20 ", "2019-05-10 14:13:45 ", 2, 19, "waiting outside of the coffee store", "finished"]
    $journeyId= 9

    #test driver methods
    def test_isDriver
        result_boolean = $database.isDriver($correctTwitter)
        assert_equal(true, result_boolean)
    end

    def test_isDriverFalse
        result_boolean = $database.isDriver($wrongTwitter)
        assert_equal(false, result_boolean)
    end

    def test_getDriverCity
        assert_equal ["Birmingham"], $database.getDriverCity($driverId)[0]
    end
    
    def test_getDriverCityWrong
        assert_equal nil, $database.getDriverCity($wrongId)[0]
    end

    def test_getDriversByTwitter
        assert_equal $driver, $database.getDriversByTwitter($correctTwitter)[0]
    end
    
    def test_getDriversByTwitterWrong
        assert_equal nil, $database.getDriversByTwitter($wrongTwitter)[0]
    end

    def test_getDriverById
        assert_equal $driver , $database.getDriverByID($driverId)
    end
    
    def test_getDriverByIdWrong
        assert_equal nil , $database.getDriverByID($wrongId)
    end

    def test_getDriversByCityBirmingham
        assert_equal $driver, $database.getDrivers("Birmingham")[0]
    end

    def test_getDriversByCitySheffield
        assert_equal [], $database.getDrivers("Sheffield")
    end

    #test tweet methods
    def test_getTweetsCorrect
        assert_equal [18, "_mattia5", "@ise19team19b this is a tweet test for birmingham", nil, "1126525692982775808", nil, "Birmingham"], $database.getTweetByPrimaryKey(18)  
    end
    
    def test_getTweetsWrong
        assert_equal nil, $database.getTweetByPrimaryKey(60)  
    end

    def test_tweetExistsFalse
        assert_equal false, $database.tweetExists(60)
    end

    def test_tweetExistsTrue
        assert_equal false, $database.tweetExists(17)
    end

    #test cars
    def test_getCars
        assert_equal $car, $database.getCars()[0]
    end

    def test_getCarIdByDriver
       assert_equal [34], $database.getCarIdByDriver($driverId)[0]
    end
    
    def test_getCarIdByDriverWrong
       assert_equal nil, $database.getCarIdByDriver($wrongId)[0]
    end

    def test_getCarByMake
        assert_equal $car,$database.getCarByMake("make")[0]
    end
    
    def test_getCarByMakeWrong
        assert_equal nil,$database.getCarByMake("make2")[0]
    end

    def test_getCarBySeats
        assert_equal $car, $database.getCarBySeats($seats)[0]
    end
    
    def test_getCarBySeatsWrong
        assert_equal nil, $database.getCarBySeats($seats+1)[0]
    end

    def test_getCarByLicence
        assert_equal $car, $database.getCarByLicence_Plate($licence_plate)[0]
    end
    
    def test_getCarByLicenceWrong
        assert_equal nil, $database.getCarByLicence_Plate("abc3")[0]
    end

    def test_getCarByDriver
        assert_equal $car, $database.getCarByDriver($driverId)[0]
    end
    
    def test_getCarByDriverWrong
        assert_equal nil, $database.getCarByDriver($wrongId)[0]
    end

    # test feedback methods    
    def test_getFeedbackId()
        assert_equal 6, $database.getFeedback()[0][0]
    end
    
    def test_getFeedbackTwitter()
        assert_equal $correctTwitter, $database.getFeedback()[0][1]
    end
    
    def test_getFeedbackTopis()
        assert_equal  "Awesome", $database.getFeedback()[0][2]
    end
    
    def test_getFeedbackMessage()
        assert_equal "I love working for you guys! I cannot wait to experience your system as a customer. Cheers!", $database.getFeedback()[0][3]
    end
    
    #test journey methods
    def test_getJourneyByDriver
       assert_equal $journey, $database.getJourneyByDriver($correctTwitter)[0]
    end
    
    def test_getJourneyByDriverWrong
       assert_equal nil, $database.getJourneyByDriver($wrongTwitter)[0]
    end
   
    def test_getJourneyByTweet
        assert_equal $journey, $database.getJourneyByTweet(19)[0]
    end
    
    def test_getJourneyByTweet
        assert_equal nil, $database.getJourneyByTweet($wrongId)[0]
    end
    
end