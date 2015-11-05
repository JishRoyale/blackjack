# deck.coffee
#
# @author Abe Fehr
#
Card = require "../src/card"

# The Deck module
Deck = ->

  # Returns a new instance of a Deck of cards
  #
  constructor = ->

    # Create all of the cards for the deck
    cards = []
    i = 0
    for key, suit of Card.suit
      j = 1
      while j <= 13
        rank = j
        cards.push Card.new rank, suit
        ++j
      ++i

    # The Fisher-Yates (Knuth) Shuffle
    # https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
    #
    shuffle = ->
      i = cards.length
      while --i > 0
        j = ~~(Math.random() * (i + 1))
        t = cards[j]
        cards[j] = cards[i]
        cards[i] = t
    shuffle()

    # Deals the top-most card from the deck
    #
    # @param [boolean] faceup whether or not the card should be kept faceup
    #
    dealCard = (faceup) ->
      if faceup? and faceup
        return cards.pop()
      else
        dealtCard = cards.pop()
        dealtCard.flip()
        return dealtCard

    {
      cards: cards
      dealCard: dealCard
    }

  # Public methods to return
  #
  {
    new: constructor
  }

module.exports = Deck()