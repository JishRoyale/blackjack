# table-spec.coffee
#
# @author Abe Fehr
#
Table = require "../src/table"

table = Table.new()

describe "The table", ->

  it "contains a game of blackjack", ->
    expect(table.game?).toBeTruthy()