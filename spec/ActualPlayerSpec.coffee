# ActualPlayer.coffee
#
# @author Abe Fehr
#
ActualPlayer = require "../src/ActualPlayer"

describe "A real player", ->

  # Create a dummy socket for tests
  dummySocket =
    emit: (->)
    id: "123"

  it "has a unique identifier", ->
    somePlayer = new ActualPlayer "abc123", dummySocket
    expect(somePlayer.uuid?).toBeTruthy()

  it "has a socket", ->
    somePlayer = new ActualPlayer "abc123", dummySocket
    expect(somePlayer.socket?).toBeTruthy