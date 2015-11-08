# Table.coffee
#
# Represents a table in the game. A table is almost like a "room" for a
# particular set of players, and has been designed in a generic way so that
# multiple games could be played on it. Multiple tables can also be contained by
# some instance and, when coupled with some form of load balancing system, could
# handle many, many requests, putting new players at different tables.
#
# @author Abe Fehr
#
ActualPlayer = require "../src/ActualPlayer"
AIPlayer = require "../src/AIPlayer"
Map = require "../src/Map"

class Table

  self = undefined # Set to "this". Done so callbacks can still access this or @

  # Returns a new instance of a Table
  #
  # @param [IO] io a Socket.IO server to listen with
  # @param [Class] GameType the type of game to play at this table
  #
  constructor: (@io, @GameType) ->
    @players = new Map()
    @game = new @GameType this
    @registerGameEvents()
    if @io? then @io.on "connection", @registerSocketEvents
    @state = Table.states.OPEN
    self = @

  # A list of all the possible table states
  #
  # OPEN: Before the game starts, when registration is still allowed, the table
  # is open. Despite this, the table won't accept new players for registration
  # in an open state if there are more than MAX_PLAYER players
  #
  @states:
    OPEN: 1
    PLAYING: 2

  # Checks whether or not a particular uuid is registered to the table
  #
  # @param [string] uuid the uuid to check for
  #
  registered: (uuid) ->
    for player in @players.getValues()
      if player.uuid is uuid then return true
    return false

  # Registers a player to the table. Does not register the player successfully
  # when the state is not OPEN or if the player is already registered
  #
  # @param [Player] player the player to register
  #
  # @return [boolean] whether or not the player was added
  #
  register: (player) ->
    if not @registered player.uuid
      if @players.size < @game.MAX_PLAYERS and @state is Table.states.OPEN
        @players.set player.socket.id, player
        return true
    return false

  # Sends a message to every single player at the table
  #
  # @param [string] message the message to send to each player
  # @param [Object] arg the argument to pass along with the message
  #
  sendToAll = (message, arg) ->
    player.socket.emit message, arg for player in self.players.getValues()


  # Sends all of the game information to the client. This includes player
  # information
  #
  sendPlayerInfo = ->
    players = []
    for player in self.players.getValues()
      players.push
        uuid: player.uuid
        sid: player.socket.id
        hands: player.hands
        status: player.status
    sendToAll "stats", players


  # Registers to all events in the game
  #
  registerGameEvents: ->

    # Deals a card to the dealer
    #
    # @param [Card] card the card to deal to the dealer. This signal gets sent
    #   to all the players at the table, just as real players around a table
    #   could observe that a dealer gets dealt cards.
    #
    @game.on "deal card to dealer", (card) ->
      for player in self.players.getValues()
        player.socket.emit "deal card to dealer", card
      sendPlayerInfo()
      #sendScores()

    # Deals a card to a particular player
    #
    # @param [Player] who which player to deal the card to
    # @param [Card] what the card to deal to that particular player
    #
    @game.on "deal card to player", (who, what) ->
      who.socket.emit "deal card to player", what
      for hand in who.hands
        hand.push what
      sendPlayerInfo()
      #sendScores()

    @game.on "flip hole card", ->
      sendToAll "flip hole card"
      sendPlayerInfo()

    # Notifies the user that the game is complete
    #
    @game.on "game over", (who, what) ->
      #sockets.get(who.socket.id).emit what

  # Registers all events to a Socket.IO socket
  #
  # @param [Socket] socket a Socket.IO socket to listen to events from
  #
  registerSocketEvents: (socket) ->

    # Checks whether or not all players are ready to begin the game
    #
    ready = ->
      for player in self.players.getValues()
        unless player.status is "ready" then return false
      return true

    # Creates a new player and registers them to the game
    #
    # @param [string] uuid the unique identifier of the player to register
    #
    socket.on "register", (uuid) ->
      console.log "Trying to register player with uuid: #{uuid}."
      player = new ActualPlayer uuid, socket
      if not self.register player
        socket.emit "display message", "Oops! There is already a game ongoing.
        Please refresh the window after a while to see if the tables have become
        available"
        socket.disconnect()
      else
        socket.emit "display message", "Welcome to 4004 BlackJack! Press start
        to play once there are enough other players"
        socket.emit "state", self.state
      sendPlayerInfo()

    # Sets the player's status to ready and starts the game if every other
    # player is also ready to begin.
    #
    socket.on "start game", ->
      self.players.get(socket.id).status = "ready"
      if self.players.size >= self.game.MIN_PLAYERS and ready()
        self.game.start ->
          sendPlayerInfo()
        sendToAll "state", self.state = Table.states.PLAYING
      else socket.emit "display message", "Not enough players yet!"
      sendPlayerInfo()

    # Relays a request for some type of action from the player to the game
    socket.on "perform action", (action) ->
      switch action
        when "stand"
          console.log "A request was (by a man) made to stand."
          self.players.get(socket.id).status = "standing"
          self.game.nextTurn()
          sendPlayerInfo()
        when "hit"
          self.players.get(socket.id).status = "hitting"
          self.game.hit self.players.get socket.id, ->
            self.game.nextTurn()
            sendPlayerInfo()

    # disconnect
    #
    # What to do when a player disconnects from the game
    socket.on "disconnect", ->
      console.log "A player has disconnected"
      #removePlayer socket
      #socket.disconnect()
      self.players = new Map()
      self.game = new self.GameType self
      self.registerGameEvents()
      self.state = Table.states.OPEN

    # Adds an AI Player to the game as well as sets all of its handlers.
    #
    socket.on "add AI player", ->
      handlers =
        hit: (->)
        stand: ->
          console.log "A request was (by a robot) made to stand."
          self.players.get(socket.id).status = "standing"
          console.log "Just changed this robot's status to standing"
          self.game.nextTurn()
          sendPlayerInfo()
          console.log "Information was just sent to everyone on all the status'"
          console.log "Status: #{self.players.get(socket.id).status}"
        split: (->)
      unless self.register new AIPlayer handlers
        socket.emit "display message", "There's no room left in the table!"
      sendPlayerInfo()
      console.log "A robot was added to the game"

  ###

  sendScores = ->
    allSockets "update dealer score", blackjack.getHandValue blackjack.dealer
    for player in players.getValues()
      score = blackjack.getHandValue player.hand
      sockets.get(player.sid).emit "update player score", score
  ###

  #
  # Removes a player from the game
  #
  # @param [socket] socket the socket of the player to remove
  ###
  removePlayer = (socket) ->
    players.delete socket.id
    sockets.delete socket.id

  ###


    # error
    #
    # Logs the error message to the console
  ###
    socket.on "error", (err) ->
      console.log "> Error! #{err}"
      #socket.emit "error", err
  ###
    # play again
  ###
    socket.on "play again", ->
      blackjack = new BlackJack()
      blackjack.start socket
  ###

module.exports = Table
