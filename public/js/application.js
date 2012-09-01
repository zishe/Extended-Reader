$(this).tooltip({
  selector: "a[rel=tooltip]"
})

Mousetrap.bind('space', function() {
  console.log('space');
  $('#btn-next').click();
});

Mousetrap.bind('right', function() {
  console.log('right');
  $('#btn-next').click();
});

Mousetrap.bind('left', function() {
  console.log('left');
  $('#btn-prev').click();
});

function endsWith(str, suffix) {
    return str.indexOf(suffix, str.length - suffix.length) !== -1;
}

function endsWithArr(str, suffix) {
  for (var i = suffix.length - 1; i >= 0; i--) {
    if (str.indexOf(suffix[i], str.length - suffix[i].length) !== -1) 
      return true;
  }
}