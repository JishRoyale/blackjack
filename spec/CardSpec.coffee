# card-spec.coffee
#
# @author Abe Fehr
#
Card = require "../src/card"

describe "A card", ->

  it "has a rank", ->
    card = Card.new 2, Card.suit.HEARTS
    expect(card.rank).toBe 2

  it "has a suit", ->
    card = Card.new 2, Card.suit.HEARTS
    expect(card.suit).toBe Card.suit.HEARTS

  it "is faceup by default", ->
    card = Card.new 2, Card.suit.HEARTS
    expect(card.face.down).toBeFalsy()

  it "can be flipped facedown", ->
    card = Card.new 2, Card.suit.HEARTS
    card.flip()
    expect(card.face.down).toBeTruthy()

  it "can return a string representation of itself", ->
    card = Card.new 2, Card.suit.HEARTS
    expect(card.string).toBe("2♥")

  it "returns string representations of itself for face cards too", ->
    card = Card.new Card.rank.ACE, Card.suit.SPADES
    expect(card.string).toBe("A♠")