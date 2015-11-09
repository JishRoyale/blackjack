# ActualPlayer.coffee
#
# Represents an actual player in the game.
#
# @author Abe Fehr
#
Player = require "../src/Player"

class ActualPlayer extends Player

  # Returns a new instance of an ActualPlayer
  #
  # @param [string] uuid the unique identifier of the player
  # @param [Socket] socket the socket of the player
  #
  constructor: (@uuid, @socket) ->
    @type = "human"
    super @uuid, @socket

  # Requests an action for a round from the player
  #
  requestAction: ->
    actions = ["hit", "stand"]
    if @hands[0].length is 2 and @hands[0][0].rank is @hands[0][1].rank
      actions.push "split"
    @socket.emit "allow actions", actions

module.exports = ActualPlayer