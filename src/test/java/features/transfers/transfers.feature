@transfers @regression
  Feature: Funds Transfer API

    Background:
      * url baseUrl

    Scenario Outline: Verify <type> Bank Transfer
        Given path '/api/transfers/execute'
        And request { fromAccount: '<from>', toAccount: '<to>', amount: <amt> }
        When method post
        Then status 200
        And match response.status == 'SUCCESS'
        And match response.message == 'Transfer Successful'
        And match response.referenceId == '#notnull'
        # This print is for the shell script to count the execution
        * print 'Executing Transfer Test for <type>'

        Examples:
          | type     | from  | to    | amt   |
          | Internal | ACC-1 | ACC-2 | 50.0  |
          | External | ACC-3 | ACC-4 | 150.0 |
          | Savings  | ACC-1 | SAV-1 | 500.0 |
          | Business | BUS-1 | ACC-2 | 1000.0|
          | Instant  | ACC-2 | ACC-3 | 25.0  |