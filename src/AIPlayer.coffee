# AIPlayer.coffee
#
# Represents an AI player in the game.
#
# @author Abe Fehr
#
Player = require "../src/Player"

class AIPlayer extends Player

  # Returns a new instance of an AIPlayer
  #
  # @param [object] handlers what to do when hit, stand and split are requested
  #   by this AI Player. Should contain a hit, stand, and split function
  #
  constructor: (@handlers) ->
    # Create a fake socket to give to the player
    dummy =
      emit: (->)
      id: ""
      disconnect: (->)
    # Generate own UUID
    @uuid = ""
    @uuid += Math.random().toString(36).substr(2) while @uuid.length < 24
    dummy.id += Math.random().toString(36).substr(2) while dummy.id.length < 12
    @type = "robot"
    # Call the super's constructor
    super @uuid, dummy

  # Requests an action for a round from the player. An action is chosen based on
  # the following strategy:
  #
  # - if you have your two initial cards to be of the same rank, then split
  # - if your current value is 21, then stay
  # - else: if at least one other player has stayed with two cards with the
  #         visible card being an ace or a card of value 10, then hit
  # - else: if your value is between 18 and 20
  #   o then if any other player has his visible cards add up to strictly more
  #             than your hand’s value minus 10, then hit
  #   o else stay
  # - else: hit
  #
  # @param [array] dealer the cards in the dealer's hand
  #
  requestAction: (dealer) ->

    # For now, always stand
    @handlers.stand @socket

    ###
    if # your two initial cards are the same rank, then split
    if # your current value is 21, then stand
    else if # at least one other player has stood with two cards and the visible
      # card being an ace or a card of value 10
    else if # your value is between 18 and 20
      if # any other player has visible cards that add up to strictly more than
        # hand value - 10, hit
      else
        # stand
    else
      # hit
    ###

    # Call the super's requestAction because why? I forgot
    #super.requestAction dealer

  # Robots are always ready to play right when you add them. This is necessary
  # because otherwise it would be impossible to get the ready signal from them
  #
  status: "ready"

module.exports = AIPlayer