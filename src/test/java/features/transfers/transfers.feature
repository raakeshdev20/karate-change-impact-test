@transfers
  Feature: Funds Transfer API

    Background:
      * url baseUrl

    Scenario: Verify Internal Bank Transfer
      Given path '/api/transfers/execute'
      And request { fromAccount: 'ACC-1', toAccount: 'ACC-2', amount: 50.0 }
      When method post
      Then status 200
      And match response.status == 'SUCCESS'
      And match response.message == 'Transfer Successful'
      And match response.referenceId == '#notnull'