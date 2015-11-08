# AIPlayerSpec.coffee
#
# @author Abe Fehr
#
AIPlayer = require "../src/AIPlayer"

describe "A robot player", ->

  it "has a unique identifier", ->
    somePlayer = new AIPlayer "abc123"
    expect(somePlayer.uuid?).toBeTruthy()

  it "lets the game requestion a decision", ->
    somePlayer = new AIPlayer "abc123"
    expect(typeof somePlayer.requestAction).toBe "function"