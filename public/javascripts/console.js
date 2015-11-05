/**
 * console.js
 *
 * This file contains all of the functions necessary for console logging and
 * debugging
 */

// Different logging levels
var DEBUG = 0;
var INFO = 1;
var WARNING = 2;
var ERROR = 3;

/**
 * Writes to the debug console on screen
 *
 * @param {string} text - the text to print to the screen
 * @param {number} level - the level of debug text to print(NOT YET IMPLEMENTED)
 */
var printDebug = function(text, level) {
  // The level is info by default
  level = level || INFO;

  // Get the current date:
  var now = new Date();

  // Create a timestamp
  var timestamp = $("<span></span>");
  timestamp.addClass("timestamp");
  timestamp.append(("0" + now.getHours()).slice(-2) + ":" + ("0" + now.getMinutes()).slice(-2) + ":" + ("0" + now.getSeconds()).slice(-2));

  // Create the message
  var message = $("<span></span>");
  switch(level) {
    case DEBUG:
      message.addClass("debug");
      break;
    case INFO:
      message.addClass("info");
      break;
    case WARNING:
      message.addClass("warning");
      break;
    case ERROR:
      message.addClass("error");
      break;
  }
  message.append(text);

  // Add the timestamp and the message to the log
  $("#debugBox").append(timestamp);
  $("#debugBox").append(message);
  $("#debugBox").append("<br>");

  // Scroll to the bottom of the debug box
  $('#debugBox').scrollTop($('#debugBox')[0].scrollHeight);
};