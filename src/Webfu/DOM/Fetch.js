'use strict';

exports.responseOkImpl = function(response) {
  return response.ok;
};


exports.responseStatusImpl = function(response) {
  return response.status;
};


exports.responseStatusTextImpl = function(response) {
  var statusText = response.statusText;
  if (statusText == null)
    return "";

  return statusText;
};


exports.responseBodyAsTextImpl = function(response) {
  var body = response.text();
  if (body == null)
    return "";

  return body;
};


exports.win_fetch_foreign = function (url) {
  return function (w) {

    return function () { // Eff wrapper
      var promise = w.fetch( url );
      return promise;
    };

  };
};

