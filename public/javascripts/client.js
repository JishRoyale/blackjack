var socket = io();

var dealer = [];
var player = [];

/**
 * deal card dealer
 *
 * Deals a card to the dealer
 */
socket.on("deal card dealer", function(properties) {
  // Create the card and deal it
  var card = new Card(properties);
  dealer.push(card);
  card.deal($(".card-area.dealer"));

  // Log the event to the console
  var cardDescription;
  if(properties.face.down) {
    cardDescription = "A facedown card";
  } else {
    cardDescription = "A " + properties.rank + " of " + properties.suit;
  }
  printDebug(cardDescription + " was dealt to the dealer");
});

/**
 * deal card player
 *
 * Deals a card to the player
 */
socket.on("deal card player", function(properties) {
  // Create the card and deal it
  var card = new Card(properties);
  player.push(card);
  card.deal($(".card-area.player"));

  // Log the event to the console
  var cardDescription = "A " + properties.rank + " of " + properties.suit;
  printDebug(cardDescription + " was dealt to you");
});

/**
 * dealer bust
 */
socket.on("dealer bust", function(score) {
  disableButtons();
  alert("Dealer busts! You win!");
  askToPlayAgain();
});

/**
 * player bust
 */
socket.on("player bust", function(score) {
  disableButtons();
  alert("You bust! Dealer wins!");
  askToPlayAgain();
});

/**
 * dealer wins
 */
socket.on("dealer wins", function(score) {
  disableButtons();
  alert("Dealer wins!");
  askToPlayAgain();
});

/**
 * player wins
 */
socket.on("player wins", function(score) {
  disableButtons();
  alert("Player wins!");
  askToPlayAgain();
});

/**
 * dealer blackjack
 */
socket.on("dealer blackjack", function(score) {
  disableButtons();
  alert("Dealer blackjack! That sucks!");
  askToPlayAgain();
});

/**
 * player blackjack
 */
socket.on("player blackjack", function(score) {
  disableButtons();
  alert("Player blackjack! Yay!");
  askToPlayAgain();
});

/**
 * push
 */
socket.on("push", function(score) {
  disableButtons();
  alert("Push! You both tied");
  askToPlayAgain();
});

/**
 * update dealer score
 *
 * Updates the score of the dealer
 */
socket.on("update dealer score", function(score) {
  $(".scores span.dealer").html(score);
});

/**
 * update player score
 *
 * Updates the score of the player
 */
socket.on("update player score", function(score) {
  $(".scores span.player").html(score);
});

/**
 * display message
 *
 * Writes a message to the debug console
 */
socket.on("display message", function(message) {
  printDebug(message, INFO);
});

socket.on("state", function(state) {
  printDebug("Just heard that the current state was: " + state, DEBUG);

  // If the state was lobby, add the start button
  switch (state) {
    case 1:
      switchToLobby();
      break;
    case 2:
      switchToPlaying();
      break;
  }
});

/**
 * connect
 *
 * Generates a unique ID(UUID), stores it in WebStorage and sends it to the server
 */
socket.on("connect", function () {
  if (!(uuid = localStorage.getItem("uuid"))) {
    var date = new Date();
    var randomlyGeneratedUID = Math.random().toString(36).substring(3,16)+date;
    localStorage.setItem("uuid", randomlyGeneratedUID);
  }

  socket.emit("register", uuid);
});

/**
 * error
 *
 * Forwards the error to the debug console on screen and in the F12 Dev Tools
 */
socket.on("error", function(message) {
  printDebug(message, ERROR);
  console.error(message);
});

/**
 * stats
 *
 * Forwards the error to the debug console on screen and in the F12 Dev Tools
 */
socket.on("stats", function(players) {
  $("div.players").find("ul").empty();
  for (var i=0; i<players.length; ++i) {
    var player = players[i];
    // Construct the list item that talks about the player
    var playerListItem = $("<li></li>");
    playerListItem.append(player.uuid.substring(0,5)); // Their UUID
    playerListItem.append(" - " + player.status);      // Their status
    $("div.players").find("ul").append(playerListItem);
  }
});

/**
 * flip dealer card
 *
 * Flips the facedown card on the screen
 */
socket.on("flip dealer card", function() {
  var card = dealer[1];
  card.flip(); // Because this is the one that's facedown
  printDebug("The dealer's card was flipped faceup");
});

/**
 * Changes the buttons in the button area to reflect the lobby's options
 */
var switchToLobby = function() {
  var buttonArea = $(".button-area");
  buttonArea.empty();

  // Create a start button
  var startButton = $("<button></button>");
  startButton.append("Start Game");
  startButton.on("click", function() {
    socket.emit("start game");
    disableButtons();
    // Indicate to the user that we're waiting for the other players to start
    $(".button-area").find("button").html("Waiting for other players");
  });
  buttonArea.append(startButton);
};

/**
 * Changes the buttons in the button area to reflect the in-game options
 */
var switchToPlaying = function() {
  var buttonArea = $(".button-area");
  buttonArea.empty();

  // Create a hit button
  var hitButton = $("<button></button>");
  hitButton.append("Hit");
  hitButton.on("click", function() { socket.emit("hit"); });
  buttonArea.append(hitButton);

  // Create a stand button
  var standButton = $("<button></button>");
  standButton.append("Stand");
  standButton.on("click", function() {
    socket.emit("stand");
    disableButtons();
  });
  buttonArea.append(standButton);
};

/**
 * Disables the buttons on the screen
 */
var disableButtons = function() {
  $(".button-area").find("button").prop("disabled", true);
};

/**
 * Asks the user if he wants another game
 */
var askToPlayAgain = function() {
  var buttonArea = $(".button-area");
  buttonArea.empty();

  // Create a play again button
  var playAgainButton = $("<button></button>");
  playAgainButton.append("Play Again");
  playAgainButton.on("click", function() {
    clearPlayingArea();
    socket.emit("play again");
  });
  buttonArea.append(playAgainButton);
};

/**
 * Clears all of the cards in the playing area
 */
var clearPlayingArea = function() {
  dealer = [];
  player = [];
  $(".card-area.dealer").empty();
  $(".card-area.player").empty();
};

/**
 * What to do when the reset button is clicked in the top corner
 *
 * This is only intended for debugging. It is useful to restore the server
 * restarting it and refreshing all the webpages
 */
$("#resetButton").on("click", function() {
  // Send a message to the server to reset everything
  socket.emit("reset server");
  socket.disconnect();

  // Refresh the webpage in a second
  setTimeout(function() { location.reload() }, 1000);
});