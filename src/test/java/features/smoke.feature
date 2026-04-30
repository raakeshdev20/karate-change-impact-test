@smoke
Feature: Core Service Health Check

  Background:
    * url baseUrl

  Scenario: Verify Payment Service Liveness
    Given path '/api/payments/status'
    When method get
    Then status 200
    And match response == 'Payment Service is UP'

  Scenario: Verify Transaction Service Liveness
    Given path '/api/transactions/health'
    When method get
    Then status 200
    And match response == 'Transaction Service is UP'

  Scenario: Verify Transfer Service Liveness
    Given path '/api/transfers/ping'
    When method get
    Then status 200
    And match response == 'Transfer Service is UP'