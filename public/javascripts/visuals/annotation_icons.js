var get_annotation_icons = function() { 
        return this.orig_bars.anchor(this.align).add(pv.Image)
        .url('/images/annotation-icon.png')
        .visible(function(){
          var this_category = this.parent.obj().cats[this.parent.index];
          var annotations = this.parent.obj().annotations;
          for (i in annotations) {
            if (annotations[i].description.length > 0 &&
                annotations[i].category.toUpperCase() == this_category.toUpperCase()) {
                return true;
            }
          }
          return false;
        })
        .width(16)
        .height(16)
        .left(-20)
        .top(2)
        .cursor(this.disabled ? "default" : 'pointer')
        .events('all')
        .event('mousemove', function() {
          var this_category = this.parent.obj().cats[this.parent.index];
          var annotations = this.parent.obj().annotations;
          for (i in annotations) {
            if (annotations[i].category == this_category) {
              var annotation = annotations[i].description;
              break;
            }
          }
          $("#annotation-popup").html(annotation)
                                .append("<br><br>")
                               /* .append(thumbup)
                                .append(" ")
                                .append(thumbdown);*/
          $("#annotation-popup").css({"left": (mouse_x+5) + "px",
                                      "top":  (mouse_y+5) + "px"});
          $("#annotation-popup").show();
          popup_active = true;
        })
        .event('mouseout', function() {
          popup_active = false;
          setTimeout(function() {
            if (!popup_active) $("#annotation-popup").hide();
          }, 1000);
        });
}; 