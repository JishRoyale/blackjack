# deck-spec.coffee
#
# @author Abe Fehr
#
Deck = require "../src/deck"
Card = require "../src/card"

deck = Deck.new()

describe "The deck", ->

  it "is contains an array of cards", ->
    expect(deck.cards.length).toBeGreaterThan -1

  it "contains 52 cards, to be exact", ->
    expect(deck.cards.length).toBe 52

  it "can deal out a card from the shuffled deck", ->
    dealtCard = deck.dealCard()
    expect(dealtCard.rank?).toBeTruthy()
    expect(dealtCard.suit?).toBeTruthy()

  it "can deal a facedown card if requested", ->
    dealtCard = deck.dealCard false
    expect(dealtCard.face.down).toBeTruthy()

  it "is shuffled to begin with", ->
    dealtCard1 = deck.dealCard()
    dealtCard2 = deck.dealCard()
    expect(Math.abs(dealtCard1.rank - dealtCard2.rank) == 1 &&
      dealtCard1.suit == dealtCard2.suit).toBeFalsy()