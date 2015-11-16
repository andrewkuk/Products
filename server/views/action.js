$("button").click(function() {
  $("#purchase").attr("action", "/products/" + $(this).val());
})
