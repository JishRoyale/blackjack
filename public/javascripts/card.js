/**
 * Represents a playing card in the game
 *
 * @param {object} options - the values for the card: suit, rank, and face.up/face.down
 */
var Card = function(options) {

  // A private function just used inside this card
  var rankToClass = function(rankNumber) {
    switch(rankNumber) {
      case 1:
        return "ace";
      case 2:
        return "two";
      case 3:
        return "three";
      case 4:
        return "four";
      case 5:
        return "five";
      case 6:
        return "six";
      case 7:
        return "seven";
      case 8:
        return "eight";
      case 9:
        return "nine";
      case 10:
        return "ten";
      case 11:
        return "jack";
      case 12:
        return "queen";
      case 13:
        return "king";
    }
  };

  // Create the actual DOM element for the card
  var HTML = $("<div></div>");
  HTML.addClass("card");
  HTML.addClass("deal");
  HTML.addClass(options.face.down ? "facedown" : "faceup");
  HTML.addClass(rankToClass(options.rank));
  HTML.addClass(options.suit);
  var front = $("<div></div>");
  front.addClass("front");
  var rankTop = $("<div></div>");
  rankTop.addClass("rank");
  rankTop.addClass("top");
  front.append(rankTop);
  var middle = $("<div></div>");
  middle.addClass("middle");
  middle.addClass("suit");
  front.append(middle);
  var rankBottom = $("<div></div>");
  rankBottom.addClass("rank");
  rankBottom.addClass("bottom");
  front.append(rankBottom);
  HTML.append(front);
  var back = $("<div></div>");
  back.addClass("back");
  back.addClass("upholstry");
  HTML.append(back);

  /**
   * Flips the card faceup if it's face down
   */
  var flip = function() {

    // If the card is face up, don't do anything
    if(HTML.hasClass("faceup")) { return; }

    // Define the animation
    $.keyframe.define([{
        name: "flip",
        "0%":   { "transform": "rotateY(0deg)" },
        "30%":  { "transform": "translateX(100%)" },
        "80%":  { "box-shadow": "0 0 1vh 0.5vh #444" },
        "100%": { "transform": "translateX(100%) rotateY(180deg)" }
      }
    ]);
    // Change the transform origin of the card to be the left side, that way it
    // doesn't flip over the center, but over the side(more realistic-looking)
    HTML.css("transform-origin", "0% 50%");

    // Animate the actual card
    HTML.playKeyframe({
      name: "flip",
      duration: "1.5s",
      complete: function() {
        HTML.removeClass("facedown")    // Remove its facedown status
            .addClass("faceup")         // Make it known to be faceup now
            .css("animation", "")       // Remove reference to this CSS animation
            .css("transform", "rotateY(0deg)");
      }
    });
  };

  /**
   * Adds the card to the table somewhere
   *
   * @param {jQuery DOM Object} container - where to place the card on the table
   */
  var deal = function(container) {

    // Put the card in the place given
    container.append(HTML);

    // Define the deal animation
    $.keyframe.define([{
        name: "deal",
        "0%": {
          "transform": "translateY(-230px) scale(1.3)",
          "opacity": "0"
        },
        "100%": {
          "transform": " translateY(0) rotate(" + (Math.random() * 6 - 3) + "deg)",
          "opacity": "1"
        }
      }
    ]);

    // Animate the card
    HTML.playKeyframe({
      name: "deal",
      duration: ".5s",
      complete: function() {

        // This isn't perfect, perhaps in the future I can use the jQuery object
        var el = HTML.get(0);
        var st = window.getComputedStyle(el, null);
        var tr = st.getPropertyValue("-webkit-transform") ||
                 st.getPropertyValue("-moz-transform") ||
                 st.getPropertyValue("-ms-transform") ||
                 st.getPropertyValue("-o-transform") ||
                 st.getPropertyValue("transform") ||
                 "fail...";

        // With rotate(30deg)...
        // matrix(0.866025, 0.5, -0.5, 0.866025, 0px, 0px)
        // rotation matrix - http://en.wikipedia.org/wiki/Rotation_matrix

        var values = tr.split("(")[1];
            values = values.split(")")[0];
            values = values.split(",");
        var a = values[0];
        var b = values[1];
        var c = values[2];
        var d = values[3];

        var scale = Math.sqrt(a*a + b*b);

        // arc sin, convert from radians to degrees, round
        // DO NOT USE: see update below
        var sin = b/scale;
        var angle = Math.round(Math.asin(sin) * (180/Math.PI));

        HTML.removeClass("deal");
        HTML.attr("style","transform: rotate(" + angle + "deg)").removeClass("boostKeyframe");

      }
    });
  };

  return {
    HTML: HTML,
    flip: flip,
    deal: deal
  };
};