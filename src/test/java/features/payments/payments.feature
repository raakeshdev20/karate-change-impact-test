@payments
Feature: Payments API

  Background:
    * url baseUrl

  @smoke
 Scenario: Verify Payment Processing
     Given path '/api/payments/submit'
     And request { vendorName: 'Amazon', amount: 100.0, currency: 'USD' }
     When method post
     Then status 200
     # Validating the JSON structure
     And match response.status == 'SUCCESS'
     And match response.transactionId == '#regex ^TXN-.*'
     And match response.message == 'Payment Successful'