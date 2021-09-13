Feature: add driver
    Scenario: admin adds a new driver
        Given I am on the correct page
        When I fill "First Name" with "Robert"
        When I fill "Last Name" with "de Niro"
        When I fill "Phone Number" with "152878393"
        When I fill "Car ID" with "1"
        When I fill "Twitter" with "a valid twitter id"
        When I press "submit" within "add a driver"
        Then I should see "driver added successfully"
        
Feature: add car
    Scenario: admin adds a new Car
        Given I am on the correct page
        When I fill "make" with "VolkWagen"
        When I fill "model" with "Passat"
        When I fill "colour" with "red"
        When I fill "seats" with "4"
        When I fill "lisenseplate" with "ABC123"
        When I press "submit" within "add a car"
        Then I should see "car added successfully"