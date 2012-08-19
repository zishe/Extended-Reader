// $(function() {
//     console.log('ready');
//     $('#btn-next').tipsy({gravity: 'n'});//fade: true, 
//     console.log('tipsy added');
//   }
// )

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
