var TOGGLE_BUTTON_SELECTED = 'toggle-button--selected';

var $storyLikeButton = function () { return $('.story-like-button'); };
var $storyLikeCounter = function () { return $('.story-like-counter'); };

var likesUrl = function (storyId) {
  return '/api/stories/' + storyId + '/likes';
};

var toggleUserLike = function () {
  var storyId = $(this).data('storyId');
  var storyIsLiked = $(this).hasClass(TOGGLE_BUTTON_SELECTED);

  $.ajax({
    url: likesUrl(storyId),
    method: storyIsLiked ? 'DELETE' : 'POST',
    success: function (data) {
      $storyLikeCounter().text(data.score);
    },
  });

  $(this).toggleClass(TOGGLE_BUTTON_SELECTED);

  return false;
};

$(function () {
  $(document.body).removeClass('no-transitions');
  $storyLikeButton().click(toggleUserLike);
});
