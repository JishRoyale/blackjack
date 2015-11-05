# table.coffee
#
# @author Abe Fehr
#
Map = require "../src/map"
BlackJack = require "../src/blackjack"

# The Table module
class Table

  MIN_PLAYERS = 1

  blackjack = new BlackJack()
  players = new Map()   # A map of socketIDs -> players
  sockets = new Map()   # A map of socketIDs -> sockets

  # Returns a new instance of a Table
  #
  # @param [IO] io a Socket.IO server to listen with
  #
  constructor: (@io, GameType) ->
    if @io? then @io.on "connection", handlePackets
    listenToGame()

  listenToGame = ->
    blackjack.onThing "deal card dealer", (card) ->
      socket.emit "deal card dealer", card for socket in sockets.getValues()
      sendScores()
    blackjack.onThing "deal card player", (q) ->
      sockets.get(q.who.sid).emit "deal card player", q.what
      players.get(q.who.sid).hand.push q.what
      sendScores()
    blackjack.onThing "game over", (q) ->
      sockets.get(q.who.sid).emit q.what

  # Checks whether or not a particular uuid is registered
  #
  # @param [string] uuid the uuid to check for
  #
  registered = (uuid) ->
    for player in players.getValues()
      if player.uuid is uuid then return true
    return false

  # Checks whether or not all players are ready
  #
  ready = ->
    for player in players.getValues()
      unless player.status is "ready" then return false
    return true

  sendScores = ->
    allSockets "update dealer score", blackjack.getHandValue blackjack.dealer
    for player in players.getValues()
      score = blackjack.getHandValue player.hand
      sockets.get(player.sid).emit "update player score", score

  # Adds a player to the list
  #
  # @param [number] uuid the uuid of the player to add
  # @param [socket] socket the socket of the player to add
  #
  # @return [boolean] whether or not the player was added
  #
  addPlayer = (uuid, socket) ->
    # Adds the player to the list
    if not registered uuid
      player =
        uuid: uuid
        hand: []
        status: "idle"
        sid: socket.id
      players.set socket.id, player
      sockets.set socket.id, socket
      return true
    return false

  # Removes a player from the blackjack
  #
  # @param [socket] socket the socket of the player to remove
  #
  removePlayer = (socket) ->
    players.delete socket.id
    sockets.delete socket.id

  # Sends the list of players to each player at the table
  #
  sendStats = ->
    allSockets "stats", players.getValues()

  allSockets = (message, param) ->
    socket.emit message, param for socket in sockets.getValues()


  # Does all of the packet handling and management per BlackJack table
  #
  # @param [IO] io a Socket.IO server to listen with
  #
  handlePackets = (socket) ->
    console.log "Player connected"

    # disconnect
    #
    socket.on "disconnect", ->
      console.log "A player has disconnected"
      removePlayer socket
      socket.disconnect()

    # register
    #
    # @param [string] uuid the unique identifier for the player registering
    #
    socket.on "register", (uuid) ->
      # Try to register the player in the blackjack
      console.log "Trying to register player with uuid: #{uuid} and socket id:
      #{socket.id}"
      if not addPlayer uuid, socket
        socket.emit "display message", "Try again"
        socket.disconnect()
      else
        socket.emit "display message", "Welcome to 4004 BlackJack! Press start
        to play or wait for other players to join first"
        socket.emit "state", blackjack.state
      sendStats()

    # start game
    #
    # Starts a new round of BlackJack. Ends the OPEN state and starts PLAYING
    #
    socket.on "start game", ->
      players.get(socket.id).status = "ready"
      if players.size >= MIN_PLAYERS and ready()
        blackjack.start players.getValues()
        allSockets "state", blackjack.state
      else socket.emit "display message", "Not enough players yet!"
      sendStats()

    # hit
    #
    socket.on "hit", ->
      player = players.get socket.id
      blackjack.hit player

    # stand
    #
    socket.on "stand", -> blackjack.stand socket

    # error
    #
    # Logs the error message to the console
    #
    socket.on "error", (err) ->
      console.log "> Error! #{err}"
      #socket.emit "error", err

    # play again
    #
    socket.on "play again", ->
      # Create a new instance of the game
      blackjack = new BlackJack()
      # Clear the hand
      #players[sockets[socket.id].uuid].hand = []
      # Somehow transfer the players from here to there
      blackjack.start socket

    # reset server
    #
    # Clears the player list and starts a new instance of BlackJack
    #
    socket.on "reset server", ->
      blackjack = new BlackJack()
      players = new Map()
      sockets = new Map()
      listenToGame()

module.exports = Table