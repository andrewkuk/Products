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
$('.finalvalue').focusin(function() {
  $(this).data('prev', $(this).val());
});
$('.finalvalue').change(function () {
  if($(this).val() > 0) 
    $.ajax({
      url: 'products/changequa/' + $(this).attr('name'),
      type: "POST",
      data: {'quantity': $(this).val()},
      success: function(data) {
      console.log(data);
      if(data == "big quantity") {
        alert("You can't buy more than in stock");
        $('#cartData').html($('#cartData').html());
      }
      else
        $('#cartData').html(data);
      }
    });
  else {
    $(this).val($(this).data('prev'));
    alert("Enter a positive number");
  }
});