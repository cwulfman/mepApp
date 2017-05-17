Feature: Browsing Lending Library Members (LLMs)
  As a User
  I want to be able to browse Shakespeare and Company's subscribers
  Because I want to select individuals for further study
  

  Users should be able to browse the set of subscribers to the lending
  library.  They should be able to sort and filter that set to make it
  easier for them to see patterns and select individuals for further
  study.

  Lending Library Members (LLMs) have the following properties:
  - LLMid
  - name +
  - gender ?
  - nationality +
  - residence *
  - subscription +
  - library_card ?

  Filters and Facets

  - by name
  - by known nationality (a subscriber may have had more than one)
  - by subscription dates (there may be multiple, discontinuous spans)
  - by known gender
  - do we have a card for this person?

  Who was an active subscriber between date A and date B?

  What subscribers had nationality N?

  Background:
    Given I am on the browse page

  Scenario: User sorts LLMs by name
    Given I order the LLM list by name
    Then the LLM list should be in alphabetical order


  Scenario: User sorts subscribers by number of books borrowed
    Given I order the the LLM list by number of borrowed books
    Then the first item on the LLM list should be the largest item in the LLM list
    And the last item on the LLM list should be the smallest item in the LLM list


  Scenario: User filters by facet
    Given I select the <Property> facet
    And I select the <Property_Value> in the facet
    Then the <Property> property of all subscribers on the subscriber list should include <Property_Value>

    Examples:
    | Property    | Property Value |
    | Nationality | fr             |
    | Nationality | us             |
    | Gender      | female         |


  Scenario: User filters by subscription date
    Given I set the subscribed_from point to <Earliest>
    And I set the subscribed_to point to <Latest>
    Then the subscribed_from point of all LLMs on the LLM list should be equal to or greater than <Earliest>
    And the subscribed_from point of all LLMs on the LLM list should be equal to or greater than <Latest>

    Examples:
    | Earliest   | Latest     |
    | 1919-11-01 | 1925-12-30 |


  Scenario: User adds a facet to her filter set
    Given I have faceted by <Property_1>
    And the <Property_Value> of
    And I select the <Facet_Value> in the <New_Facet>
    Then 
