$("button").click(function() {
  $("#purchase").attr("action", "/products/" + $(this).val());
});
$('#add').click(function(event) {
  event.preventDefault();
  var items = $("#purchase").serializeArray();
  $.ajax({
    url: "/products/addToCart",
    type: "POST",
    //processData: false,
    data: items,
    //dataType: "json",
    success: function(data) {
    console.log(data);
    if(data == "error")
      alert("You can't buy more than in stock");
    else {
      $('input').val('0');
      $('#cart').html(data);
    }
  }
  });
  //$.post("/products/addToCart", items, function(data) {
    //console.log(data);
    //if(data == "error")
      //alert("You can't buy more than in stock");
    //else {
      //$('input').val('0');
      //$('#cart').html(data);
    //}
  //});
});