@transactions @regression
Feature: Transaction History API

  Background:
    * url baseUrl

Scenario Outline: Verify Transaction Lifecycle - <scenario_name>
    Given path '/api/transactions/', '<path_suffix>'
    When method get
    Then status 200
    * print 'Executing Transaction Test: <scenario_name>'

    Examples:
      | scenario_name           | path_suffix   |
      | Full History Retrieval  | history       |
      | Specific ID - Completed | TXN-789       |
      | Specific ID - Pending   | TXN-101       |
      | Specific ID - Refunded  | TXN-202       |
      | Recent Activity Feed    | history       |