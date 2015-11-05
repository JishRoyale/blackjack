# blackjack.coffee
#
# @author Abe Fehr
#

Deck = require "../src/deck"
Card = require "../src/card"

class BlackJack

  # Returns a new instance of the BlackJack game
  #
  constructor: ->
    @dealer = [] # Dealer's hand
    @state = states.OPEN
    @deck = Deck.new()
    @actions = {}

  # Starts a game
  #
  start: (players) ->
    # Set the state
    @state = states.PLAYING
    # Deal 2 cards to the dealer, one face down
    card = @deck.dealCard true
    @dealer.push card
    @fire "deal card dealer", card
    _this = @
    setTimeout ->
      card = _this.deck.dealCard false
      _this.fire "deal card dealer", card
      setTimeout ->
        # Deal a card to ALL players
        for player in players
          card = _this.deck.dealCard true
          _this.fire "deal card player", { what: card, who: player }
        setTimeout ->
          # Deal a card to ALL players
          for player in players
            card = _this.deck.dealCard true
            _this.fire "deal card player", { what: card, who: player }
            _this.checkForWin player
        , 800
      , 800
    , 800
        #    checkForWin iSocket

  fire: (action, parameter) ->
    cb(parameter) for cb in @actions[action]

  onThing: (action, callback) ->
    if not @actions[action]?
      @actions[action] = []
    @actions[action].push callback

  # Hits to the player by adding a card to their hand
  #
  hit: (player) ->
    card = @deck.dealCard true
    @fire "deal card player", { who: player, what: card }
    @checkForWin player

  # Stands a hand man
  #
  # @param [Socket] socket the player to stand
  #
  stand: (socket) ->
    # TODO: Only do this if all players are standing
    # Deal cards to the dealer until they have 17 or more
    if dealer[1].face.down
      socket.emit "flip dealer card"
      dealer[1].flip()
      broadcastScores socket
      setTimeout ->
        dealUntil 17, socket
      , 1500 # Waits until the card has been flipped on the player's side

  # Recursively deals cards until the dealer has 17 or more, unless they have
  # a BlackJack
  #
  # @param [Socket] socket the player whose score to update
  #
  dealUntil = (limit, socket) ->
    if getHandValue(dealer) is 21 or getHandValue(dealer, true) >= limit
      @checkForWin socket, true
    else
      dealFaceupCardTo "dealer", socket, ->
        dealUntil limit, socket

  # Decides who won
  #
  # @param [Socket] socket the player who is checking the win
  # @param [boolean] compare whether or not to compare values for a win. This
  #    is something that should only be done at the end, when there are no
  #    more steps to take
  #
  checkForWin: (player, compare) ->
    # Get the hand values for the dealer and the player
    dealerScore = @getHandValue @dealer
    playerScore = @getHandValue player.hand
    if compare and playerScore is dealerScore then @fire "game over", "push"
    else if dealerScore > 21 then @fire "game over", "dealer bust"
    else if playerScore > 21 then @fire "game over", "player bust"
    else if dealerScore is 21 then @fire "game over", "dealer blackjack"
    else if playerScore is 21 then @fire "game over", "player blackjack"
    else if compare
      if dealerScore > playerScore then @fire "game over", "dealer wins"
      else @fire "game over", { who: player, what: "player wins" }
      #if dealer[1].face.down
      #  socket.emit "flip dealer card"
      #  dealer[1].flip()
      #  broadcastScores socket

  # Returns a value for a passed in card
  #
  # @param [Card] card the card to get the value of
  #
  # @return [number] the value of a single card in the hand
  #
  getValueOf: (card) ->
    if card.face.down then 0 else if card.rank <= 10 then card.rank else 10

  # Gets the total value of the hand
  #
  # @param [array] hand a list of cards that represents the hand
  # @param [boolean] soft whether or not to keep the aces soft
  #
  # @return [number] the value of the hand
  #
  getHandValue: (hand, soft) ->
    total = 0
    ace = false
    # Count the cards in the hand, aces soft
    for card in hand
      total += @getValueOf card
      if card.rank is Card.rank.ACE and card.face.up then ace = true
    # If the hand contains at least one ace, one of them is high (if possible)
    if not soft and ace and total <= 11 then total += 10
    return total

  # An enumeration of the various game states
  #
  states =
    OPEN: 1
    PLAYING: 2

module.exports = BlackJack