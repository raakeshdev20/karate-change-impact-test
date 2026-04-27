@smoke
Feature: Service Health Check

  Scenario: Verify the Dev Repo is responding
    Given url baseUrl
    And path '/api/dev-ops/test-selector'
    And param targetBranch = 'main'
    When method get
    Then status 200