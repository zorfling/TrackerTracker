var TT = TT || {};
TT.TeamCity = (function () {

  var pub = {};

  pub.settingsOK = function () {
    return $.cookie('teamcityHostname') && $.cookie('teamcityUsername') &&
      $.cookie('teamcityPassword');
  };

  pub.getHighestNumber = function (numbers) {
    return Math.max.apply(Math, numbers);
  };

  pub.getBuildStatus = function (story) {
    if (!pub.settingsOK()) {
      return;
    }

    TT.Ajax.get('/getTeamcityBuildStatus', {
      data: {
        storyID: story.id
      },
      callback: function (html) {
        story.buildStatus = '<span class="teamcity-not-found">Build not found</span>';

        if (html) {
          html = $(html);

          // Highest number tends to be merged builds, so favoring TC order.
          // var buildNumber = pub.getHighestNumber(html
          //  .find('tr.searchItem .buildNumber a.resultsLink').text().split('#'));
          var buildNumber = html.find('tr.searchItem .buildNumber a.resultsLink')
            .first().text().replace('#', '');
          var successful = html.find('tr.searchItem a.resultsLink:contains(' + buildNumber + ')')
            .closest('.statusText').text().indexOf('failed') === -1;
          var linkClass = successful ? 'teamcity-successful' : 'teamcity-failed';
          var url = $.cookie('teamcityHostname') +
            '/searchResults.html?query=' + story.id;

          if (buildNumber) {
            story.buildStatus = '<a href="' + url + '" target="_blank" class="' +
              linkClass + ' external">#' + buildNumber + '</a>';
          }
        }

        TT.View.redrawStory(story);
      }
    });
  };

  return pub;

}());
