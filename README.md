# BlackJack

My multiplayer, HTML5 BlackJack game

# Things left to do

- splitting
- fix the issue where more than 1 additional AI player can't stand
- show the cards under the players in the list more beautifully
- re-add the score bit so the scores show up properly
- dealer should deal until 17
- multiple real players
- detect who wins
- bold whose turn it is
- remove the player when they disconnect but only reset the table when there are no players
- do something when the game is ongoing and we try to join
- show who you are in the player list
- detect 7-card-charlie
- remove the thing where it says "I heard the state was X"

# Selenium Acceptance Testcases(possibly Cucumber as well?)

### GeneralUITest
- title is COMP4004 BlackJack
- button exists for adding AI players
- button exists for starting game
- place for dealer/player scores on the screen
- debug box exists for console output

### AddPlayersTest
- game can't be started without adding at least one player
- AI players can be added to the game
- added players show up in the list at the top left
- more than 3 additional players cannot be added to the game

### GameTest
- game can be started and deals 2 cards to dealer and 2 cards to player
- dealer's hole card is facedown
- one card shows in the list for each person(not two)
- for the player that started the game, stand and hit are for sure enabled after the cards are dealt, and split is only enabled if the ranks of both onscreen cards match

# Assignment Outline

This assignment is worth 15 out of the 60 marks allocated to assignments in this course.

You are to develop a Web application and test it at the system and acceptance levels using Selenium.

More precisely, you are to write Java classes that will implement your Selenium test suite.

Implementing the JUnit green/red approach is OPTIONAL.

The results of running this test suite must be directed to a text log file named ResultBJ.txt.

Instructions about what and how to submit will be posted later.

Any questions must be emailed to Howard.

We consider a simplistic version of BlackJack.

Our version of the Blackjack supports an automated (i.e., non human) dealer plus 1 to 3 other potential players.

Beyond the dealer, some of these players may be AI players as explained below.

We do NOT address betting and use only 1 deck (i.e., 52 cards shuffled at the beginning of each game).

An overview of the game is available at: https://en.wikipedia.org/wiki/Blackjack

Your app must support playing several games one after the other, NOT concurrently.

That is, we do not worry about someone being simultaneously in multiple games with (the same or different groups of) other players.

Each game consists of several rounds.

In the first round, each player first gets two cards, one hidden, one visible to other players.

Then in each round, each player has 2 options:

1) Stay: the player takes no additional card and just waits for the game to be resolved (i.e., a winner declared).

2) Hit: the player gets one more card. If this card causes the hand’s value to go over 21, the player must immediately declare ‘bust’

Additionally, in the first round each player except the dealer may split:

3) split: If the first two cards of a hand have the same rank (not just the same value), the player can split them into two hands by making both visible. In this case, each of these hands immediately gets a new hidden card and then play for a normal round resumes for this player who is now playing with two separate hands instead of just one! This means this player has to hit or stay for each of these two hands from this point on for the rest of that game.

The players play in a specific order (namely the order in which they join the game), with the dealer playing last.

The dealer is an automated player. That is, the dealer’s behavior is fixed: if his hand’s value is less than 17, he must hit. If the dealer’s hand value is exactly 17, but the hand does not have an ace, the dealer must stay. Finally, if the dealer’s hand value is 17 and the hand contains an ace (which is called soft 17), the dealer must hit.

Winning:

-       a 7-card Charlie (i.e., a hand of 7 cards whose value does not exceed 21) must be declared immediately and wins over all other hands

-       a busted hand must be declared immediately and always loses

-       among hands that have not busted nor are 7-card Charlies:

o   a hand with the highest value (up to 21) wins over hands of lesser value.

o   If two or more hands have the highest value obtained in this game, the winner/s is/are the hand with the fewest cards.

Note: hands that reach 21 do NOT have to be declared immediately.

Finally, beyond the behavior of the dealer, you must support zero or more players being AI players that obey the following strategy in each round:

-       if you have your two initial cards to be of the same rank, then split

-       if your current value is 21, then stay

-       else: if at least one other player has stayed with two cards with the visible card being an ace or a card of value 10, then hit

-       else: if your value is between 18 and 20

o   then if any other player has his visible cards add up to strictly more than your hand’s value minus 10, then hit

o   else stay

-       else: hit

Just to be sure about terminology: tens, jacks, queens and kings have a value of 10 but are of different rank.

In our version, the suit of a card does not matter.