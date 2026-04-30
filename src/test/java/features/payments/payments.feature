@payments @regression
Feature: Payments API

  Background:
    * url baseUrl

  Scenario Outline: Verify <vendor> Payment Processing
    Given path '/api/payments/submit'
    And request { vendorName: '<vendor>', amount: <amt>, currency: 'USD' }
    When method post
    Then status 200
    And match response.status == 'SUCCESS'
    And match response.transactionId == '#regex ^TXN-.*'
    * print 'Executing Payment Test for <vendor>'

    Examples:
      | vendor   | amt   |
      | Amazon   | 100.0 |
      | Netflix  | 15.99 |
      | Apple    | 999.0 |
      | Walmart  | 50.25 |
      | Target   | 12.00 |