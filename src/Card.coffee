# Card.coffee
#
# @author Abe Fehr
#

# The Card module
Card = ->

  # Returns a new instance of a Card
  #
  # @param [number] rank the rank of the card from 1(ace) to 13(king)
  # @param [string] the suit of the card(eg "hearts", "diamonds", etc)
  #
  constructor = (rank, suit) ->

    face = { down: false, up: true }

    # Flips the card facedown
    #
    flip = ->
      face.down = !face.down
      face.up = !face.up

    # Return a string representation of the card
    string = (->
      "#{
        switch rank
          when ranks.ACE then "A"
          when ranks.JACK then "J"
          when ranks.QUEEN then "Q"
          when ranks.KING then "K"
          else rank
        }#{
        switch suit
          when suits.HEARTS then "♥"
          when suits.DIAMONDS then "♦"
          when suits.CLUBS then "♣"
          when suits.SPADES then "♠"
        }")()

    {
      rank: rank
      suit: suit
      flip: flip
      face: face
      string: string
    }

  # An enumeration of the various suits
  #
  suits =
    HEARTS: "hearts"
    DIAMONDS: "diamonds"
    CLUBS: "clubs"
    SPADES: "spades"

  # Another enumeration for the non-numerical ranks
  #
  ranks =
    ACE: 1
    JACK: 11
    QUEEN: 12
    KING: 13

  # Public methods to return
  #
  {
    new: constructor
    suit: suits
    rank: ranks
  }

module.exports = Card()
