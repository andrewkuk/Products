$('.remove').click(function(event) {
  event.preventDefault();
  $.get($(this).attr('href'), function(data) {
    console.log(data);
    if(!data)
      $('#myModal').modal('hide');
    else
      $('#cartData').html(data);
  });
}); 
