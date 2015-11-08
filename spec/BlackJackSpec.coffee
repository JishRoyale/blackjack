# BlackJackSpec.coffee
#
# @author Abe Fehr
#
BlackJack = require "../src/blackjack"
Card = require "../src/card"

describe "The game of blackjack", ->

  dummyTable =
    someFakeProperty: undefined
    players:
      getValues: -> [
        { hands: [[]] }
      ]

  it "hasn't started the game yet after initialization", ->
    game = new BlackJack dummyTable
    expect(game.started).toBeFalsy()

  it "can start the game if asked to", ->
    game = new BlackJack dummyTable
    game.start []
    expect(game.started).toBeTruthy()

  it "starting the game gives the dealer at least one card (the rest are dealt
  asynchronously)", ->
    game = new BlackJack dummyTable
    game.start []
    expect(game.dealer.length).not.toBe 0

  it "doesn't give the dealer any cards before it's started though", ->
    game = new BlackJack dummyTable
    expect(game.dealer.length).toBe 0

  it "contains an instance of the table that started it", ->
    game = new BlackJack dummyTable
    expect(game.table?).toBeTruthy()

  it "has the ability to deal cards to players", ->
    game = new BlackJack dummyTable
    game.deal2ToAllPlayers()
    # TODO: Need to write a proper matcher for this yet


  ###it "is in open state by default", ->
    game = new BlackJack dummyTable
    expect(game.state).toBe BlackJack.state.OPEN

  it "gets value from a card's rank", ->
    twoHearts = Card.new 2, Card.suit.HEARTS
    expect(BlackJack.getValueOf twoHearts).toBe 2

  it "gets the values of all face cards as ten", ->
    queenHearts = Card.new Card.rank.QUEEN, Card.suit.HEARTS
    expect(BlackJack.getValueOf queenHearts).toBe 10

  it "gets the value for an entire hand", ->
    hand = []
    hand.push Card.new 2, Card.suit.HEARTS
    hand.push Card.new Card.rank.QUEEN, Card.suit.HEARTS
    expect(BlackJack.getHandValue hand).toBe 12

  it "counts aces to be high when hand value is small", ->
    hand = []
    hand.push Card.new 2, Card.suit.HEARTS
    hand.push Card.new Card.rank.ACE, Card.suit.HEARTS
    expect(BlackJack.getHandValue hand).toBe 13

  it "counts aces to be low when the hand value is large enough", ->
    hand = []
    hand.push Card.new 5, Card.suit.CLUBS
    hand.push Card.new 10, Card.suit.HEARTS
    hand.push Card.new Card.rank.ACE, Card.suit.HEARTS
    expect(BlackJack.getHandValue hand).toBe 16

  it "has the option of counting all aces as soft", ->
    hand = []
    hand.push Card.new 2, Card.suit.HEARTS
    hand.push Card.new Card.rank.ACE, Card.suit.HEARTS
    expect(BlackJack.getHandValue hand, true).toBe 3
  ###