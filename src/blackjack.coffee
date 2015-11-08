# BlackJack.coffee
#
# @author Abe Fehr
#

Deck = require "../src/Deck"
Card = require "../src/Card"

class BlackJack

  self = undefined # used to store "this" or "@", because scope sucks in CS
  currentPlayer = undefined # will be initialized later

  # Returns a new instance of the BlackJack game
  #
  constructor: (@table) ->
    @MIN_PLAYERS = 2
    @MAX_PLAYERS = 4
    @dealer = []
    @deck = Deck.new()
    @started = false
    @events = []
    self = @

  # Starts a game. Sets the started flag to true and begins by dealing the
  # initial cards to the dealer as well as each player. Starting the game also
  # changes each player's status to "playing"
  #
  start: (callback) ->
    @started = true
    player.status = "waiting" for player in @table.players.getValues()
    @deal2ToDealer ->
      self.deal2ToAllPlayers ->
        # Begin the turns!
        currentPlayer = 0
        self.table.players.getValues()[currentPlayer].status = "playing"
        self.table.players.getValues()[currentPlayer].requestAction self.dealer
        callback()

  # Deals 2 cards to the dealer: the face-up card and the hole card
  deal2ToDealer: (callback) ->
    card = @deck.dealCard true
    @dealer.push card
    @fire "deal card to dealer", card
    setTimeout ->
      card = self.deck.dealCard false
      self.dealer.push card
      self.fire "deal card to dealer", card
      setTimeout ->
        callback()
      , 800
    , 800

  # Deals 2 cards to each player: one of which is visible by other players. Also
  # checks if the two cards dealt are equal and if so, allows the player to
  # split them
  #
  # @param [function] callback the function to call once all hands have been
  #   dealt
  #
  deal2ToAllPlayers: (callback) ->
    beenFired = false
    for player in @table.players.getValues()
      card = @deck.dealCard true
      @fire "deal card to player", player, card
    setTimeout ->
      for player in self.table.players.getValues()
        card = self.deck.dealCard true
        self.fire "deal card to player", player, card
      callback()
    , 800

  # Fires an event with up to 3 given parameters
  #
  # @param [string] event the name of the event to fire. All registered users
  #   will have their callback called if they previously registered with the
  #   `on` function
  # @param [object] p1 the first parameter to give to the callback (optional)
  # @param [object] p2 the second parameter to give to the callback (optional)
  # @param [object] p3 the third parameter to give to the callback (optional)
  #
  fire: (event, p1, p2, p3) ->
    if @events[event]? then cb p1, p2, p3 for cb in @events[event]

  # Registers a given function to an event. In the future when this instance of
  # the class calls `fire` with that event name, the callback given here will be
  # called.
  #
  # @param [string] event the name of the given event to fire
  # @param [function] callback the function to call once the event has been
  #   fired
  #
  on: (event, callback) ->
    if not @events[event]? then @events[event] = []
    @events[event].push callback

  # Advances the turn by one. If player 0 was playing, it's now player 2's turn.
  # The turns only advance by one each time and wrap around the end modularly.
  # If the next player is standing they cannot make action so he is skipped. If
  # no player is not standing, then the dealer will flip his card and deal until
  # 17
  #
  nextTurn: () ->
    currentPlayer = ++currentPlayer % @table.players.size
    guy = @table.players.getValues()[currentPlayer]
    counter = 0
    while guy.status is "standing" and ++counter < @table.players.size
      currentPlayer = ++currentPlayer % @table.players.size
      guy = @table.players.getValues()[currentPlayer]

    # Do the turn
    unless counter is @table.players.size - 1
      guy.status = "playing"
      console.log "Just changed some player's status to playing"
      guy.requestAction @dealer
    else
      console.log "Everyone is standing"
      # Deal cards to the dealer until they have 17 or more
      console.log "#{JSON.stringify @dealer}"
      if @dealer[1].face.down
        @fire "flip hole card"
        @dealer[1].flip()
        setTimeout ->
          self.dealUntil 17
        , 1500 # Waits until the card has been flipped on the player's side

  # Hits to the player by adding a card to their hand. Executes a callback once
  # the deal is complete
  #
  # @param [Player] player who to deal the card to
  # @param [function] callback the callback to execute after the card is dealt
  #
  hit: (player, callback) ->
    card = @deck.dealCard true
    @fire "deal card to player", player, card
    setTimeout ->
      callback()
    , 800
    #@checkForWin player

  # Recursively deals cards until the dealer has 17 or more
  #
  # @param [number] limit the soft value to count until
  #
  dealUntil: (limit) ->
    if self.getHandValue(self.dealer) is 21 or
    self.getHandValue(self.dealer, true) >= limit
      #@checkForWin socket, true
    else
      card = self.deck.dealCard true
      self.dealer.push card
      self.fire "deal card to dealer", card
      setTimeout ->
        self.dealUntil limit

  ###
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

  ###
  # Returns a value for a passed in card. Aces always get returned low(1).
  # Counting Aces high involves another calculation elsewhere
  #
  # @param [Card] card the card to get the value of
  #
  # @return [number] the value of a single card in the hand
  #
  getValueOf: (card) ->
    if card.face.down then 0 else if card.rank <= 10 then card.rank else 10

  # Gets the total value of the hand, with Aces optionally soft or hard(default)
  #
  # @param [array] hand a list of cards that represents the hand
  # @param [boolean] soft whether or not to keep the aces soft. The default
  #   value if unset is false, so Aces will be counted as hard unless otherwise
  #   specified
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

module.exports = BlackJack