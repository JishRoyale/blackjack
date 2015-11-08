# TableSpec.coffee
#
# @author Abe Fehr
#
ActualPlayer = require "../src/ActualPlayer"
AIPlayer = require "../src/AIPlayer"
BlackJack = require "../src/BlackJack"
Table = require "../src/Table"

describe "A table", ->

  table = new Table undefined, BlackJack

  # Create a dummy socket for tests
  dummySocket =
    events: {}
    fire: (event, arg) ->
      dummySocket.events[event](arg)
    on: (arg, callback) ->
      dummySocket.events[arg] = callback
    emit: (->)
    disconnect: (->)
    id: "123"

  # Create a dummy IO
  dummyIO =
    socket: dummySocket
    fire: (event, arg) -> dummySocket.fire event, arg
    on: (arg, callback) ->
      if arg is "connection"
        callback dummySocket

  it "contains a game", ->
    expect(table.game?).toBeTruthy()

  it "has a state", ->
    expect(table.state?).toBeTruthy()

  it "defaults to an open state", ->
    expect(table.state).toBe Table.states.OPEN

  it "lets players join the table", ->
    somePlayer = new ActualPlayer "abc123", dummySocket
    someTable = new Table undefined, BlackJack
    expect(someTable.register somePlayer).toBeTruthy()

  it "lets AI players join the table", ->
    robot = new AIPlayer()
    someTable = new Table undefined, BlackJack
    expect(someTable.register robot).toBeTruthy()
    expect(someTable.players.size).toBe 1

  it "lets more than one AI player join the table", ->
    robot = new AIPlayer()
    anotherRobot = new AIPlayer()
    someTable = new Table undefined, BlackJack
    expect(someTable.register robot).toBeTruthy()
    expect(someTable.players.size).toBe 1
    expect(someTable.register anotherRobot).toBeTruthy()
    expect(someTable.players.size).toBe 2

  it "doesn't let more than 4 players join the game", ->
    # Make the players
    somePlayer = new ActualPlayer "abc123", dummySocket
    robot = new AIPlayer()
    secondRobot = new AIPlayer()
    thirdRobot = new AIPlayer()
    fourthRobot = new AIPlayer()
    # Make the table
    someTable = new Table undefined, BlackJack
    # Add everyone and check in on the values
    expect(someTable.register somePlayer).toBeTruthy()
    expect(someTable.players.size).toBe 1
    expect(someTable.register robot).toBeTruthy()
    expect(someTable.players.size).toBe 2
    expect(someTable.register secondRobot).toBeTruthy()
    expect(someTable.players.size).toBe 3
    expect(someTable.register thirdRobot).toBeTruthy()
    expect(someTable.players.size).toBe 4
    expect(someTable.register fourthRobot).toBeFalsy()
    expect(someTable.players.size).toBe 4

  it "doesn't let players join the table when it's not open", ->
    somePlayer = new ActualPlayer "abc123", dummySocket
    someTable = new Table undefined, BlackJack
    someTable.state = Table.states.PLAYING
    expect(someTable.register somePlayer).toBeFalsy()

  it "registers players when the 'register' event fired", ->
    someTable = new Table dummyIO, BlackJack
    dummyIO.fire "register", "abc123"
    expect(someTable.registered "abc123").toBeTruthy()

  it "starts the game when 'start game' event is fired", ->
    someTable = new Table dummyIO, BlackJack
    dummyIO.fire "register", "abc123"
    dummyIO.fire "start game"
    expect(someTable.game.started).toBeTruthy