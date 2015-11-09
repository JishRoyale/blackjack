# [COMP4004 BlackJack](http://comp4004blackjack.herokuapp.com/)

My multiplayer, HTML5 [BlackJack](https://en.wikipedia.org/wiki/Blackjack) game for Assignments 2 and 3 in COMP4004.

# Open Issues

- Splitting is not implemented entirely
- Players are not yet notified when they win
- Players don't yet have the ability to start a new game. The best they can do is refresh the page
- When there is a game ongoing at the table and a player tries to join, they're notified that they weren't able to join, but there's no way at this time for them to be notified when the ongoing game ends. The onus is on the user to refresh the page
- Adding 2 or more AI players works, but there's an issue with iterating through the players for requesting actions during turns

# Requirements

# Selenium Acceptance Testcases

### GeneralUITest

Tests the general UI of the main screen in the game. Ensures that all elements exist, but not yet that they're functional.

- title is COMP4004 BlackJack
- button exists for adding AI players
- button exists for starting game
- place for dealer/player scores on the screen
- debug box exists for console output

### AddPlayersTest

Tests the adding players behaviour as well as related behaviour. Ensures that the minimum and maximum limits are met and that adding players really does increase the size of the player list in the list of players at the table.

- game can't be started without adding at least one player
- AI players can be added to the game
- added players show up in the list at the top left
- more than 3 additional players cannot be added to the game

### GameTest
- game can be started and deals 2 cards to dealer and 2 cards to player
- dealer's hole card is facedown
- one card shows in the list for each person(not two)
- for the player that started the game, stand and hit are for sure enabled after the cards are dealt, and split is only enabled if the ranks of both onscreen cards match
