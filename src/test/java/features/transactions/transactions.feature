@transactions
Feature: Transaction History API

  Background:
    * url baseUrl

  @smoke
  Scenario: Fetch transaction history
    # Matches @RequestMapping("/api/transactions") + @GetMapping("/history")
    Given path '/api/transactions/history'
    When method get
    Then status 200
    # Update these keys to match what your TransactionResponse object actually has
    And match each response == { id: '#string', status: '#string', amount: '#number', description: '#string' }

  Scenario: Get transaction by specific ID
    # Matches @GetMapping("/{id}")
    Given path '/api/transactions/TXN-789'
    When method get
    Then status 200
    And match response.id == 'TXN-789'
    And match response.status == 'COMPLETED'