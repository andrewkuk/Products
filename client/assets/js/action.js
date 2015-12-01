$("button").click(function() {
  $("#purchase").attr("action", "/products/" + $(this).val());
});
$('#add').click(function(event) {
  event.preventDefault();
  var items = $("#purchase").serializeArray();
  $('input').val('0');
  $.post("/products/addToCart", items, function(data) {
    console.log(data);
    if(data == "error")
      alert("You can't buy more than in stock");
    else  
      $('#cart').html(data);
  });
});