$("button").click(function() {
  $("button").removeAttr("clicked");
  $(this).attr("clicked", "true");
})
$("#purchase").submit(function(){
  var action = $("button[clicked=true]").val();
  $("#purchase").attr("action", "/products/" + action);
}) 
