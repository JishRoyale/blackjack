# Player.coffee
#
# Represents a generic player in the game, either real or artificial. Meets the
# following requirements:
# - make a decision
# - contains uuid
# - contains a list of hands (for splitting later)
# - contains actual socket with ID
#
# These players were originally intended to be generic, but are only useful for
# playing BlackJack at the moment since their requestAction method are specific
#
# @author Abe Fehr
#
class Player

  # Returns a new instance of a Player
  #
  # @param [string] uuid the unique identifier of the player
  # @param [Socket] socket the socket of the player
  #
  constructor: (@uuid, @socket) ->
    @hands = [[]] # The list of hands contains the first, empty hand

  # Requests an action for a round from the player
  #
  requestAction: ->

  # The status of the player. Possible statuses are:
  # - idle: a player's state when they first register, before the game begins.
  # - ready: when the start game button has been pressed a player's state
  #          changes to ready. Once all players are ready the state is changed
  #          once again.
  # - waiting: the status after a game has begun and before performing any
  #            actions, as well as the state when it is not a particular user's
  #            turn
  # - playing: the status during the player's turn and before performing an
  #            action like splitting, standing or hitting
  # - hitting: set by pressing the hit button and deals the player a single card
  # - standing: set by pressing the stand button and disallows the player to get
  #             dealt any more cards
  # - splitting: set by pressing the split button and moves the player's two
  #              cards into separate piles as well as gets dealt one card on
  #              each pile
  #
  status: "idle"

module.exports = Player