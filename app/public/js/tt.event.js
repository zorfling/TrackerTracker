// Thin abstraction on top of jQuery's event handling.
var TT = TT || {};
TT.Event = (function () {

  var pub = {};

  pub.trigger = function (eventName, args) {
    $(window).trigger('TT.' + eventName, args);
  };

  pub.bind = function (eventName, callback) {
    $(window).bind('TT.' + eventName, callback);
  };

  pub.unbind = function (eventName) {
    $(window).unbind('TT.' + eventName);
  };

  return pub;

}());
