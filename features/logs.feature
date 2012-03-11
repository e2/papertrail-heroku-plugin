Feature: heroku integration
  In order to see logs for current heroku app
  As a heroku user
  I want to have a working heroku papertrail plugin

  Background: install plugin
    Given I have a rails app "test1" with git
    And I add "test1" to heroku
    And I install heroku-papertrail

  Scenario: Install and use
    Given I configure the papertrail addon within "test1"
    And the following events are logged:
    """
    start server
    crash
    restart

    """
    When I successfully `heroku pt:logs` within "test1"
    Then I should see these logs:
    """
    start server
    crash
    restart

    """

  Scenario: It should show info when no token
    When I `heroku pt:logs` within "test1"
    Then it should fail with:
    """
    Please add the Papertrail addon to this application

    """
