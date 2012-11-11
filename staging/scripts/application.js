var endsWith, endsWithArr;

endsWith = function(str, suffix) {
  return str.indexOf(suffix, str.length - suffix.length) !== -1;
};

endsWithArr = function(str, suffix) {
  var i;
  i = suffix.length - 1;
  while (i >= 0) {
    if (str.indexOf(suffix[i], str.length - suffix[i].length) !== -1) {
      return true;
    }
    i--;
  }
};

Mousetrap.bind("space", function() {
  console.log("space");
  return $("#btn-next").click();
});

Mousetrap.bind("right", function() {
  console.log("right");
  return $("#btn-next").click();
});

Mousetrap.bind("left", function() {
  console.log("left");
  return $("#btn-prev").click();
});

$("a[rel=tooltip]").tooltip();

$(".dropdown-toggle").dropdown();

$('#fine-uploader').ready(function() {});
