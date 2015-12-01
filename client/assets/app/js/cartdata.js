$('.remove').click(function(event) {
  event.preventDefault();
  $.ajax({
    url: $(this).attr('href'),
    type: "GET",
    //processData: false,
    //dataType: "json",
    success: function(data) {
    console.log(data);
    if(!data)
      $('#myModal').modal('hide');
    else
      $('#cartData').html(data);
    }
  });
  //$.get($(this).attr('href'), function(data) {
    //console.log(data);
    //if(!data)
      //$('#myModal').modal('hide');
    //else
      //$('#cartData').html(data);
  //});
});
$('#check').click(function(event) {
  $('#myModal').modal('hide');
});