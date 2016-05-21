var StatePicker = $.Class.create({
  initialize: function(config) {
    this.geo_data = config['geo_data'];
    this.data = config['data'];
    this.max = config['max']

    this.w = config['width']
    this.h = config['height']

    this.scale = pv.Geo.scale()
        .domain({lng: -128, lat: 24}, {lng: -64, lat: 50})
        .range({x: 0, y: 0}, {x: this.w, y: this.h});

    this.geo_data.forEach(function(c) {
      c.code = c.code.toUpperCase();
      c.centLatLon = centroid(c.borders[0]);
    });

    // Add the main panel
    this.vis = new pv.Panel()
        .width(this.w)
        .height(this.h);

    // Add a panel for each state
    this.state_panels = this.vis.add(pv.Panel)
        .def("active", -1)
        .data(this.geo_data);

    // Add a panel for each state land mass
    this.state_panels.add(pv.Panel)
        .data(function(c) { return c.borders; })
      .add(pv.Line)
        .def('obj', this)
        .data(function(l) { return l; })
        .left(this.scale.x)
        .top(this.scale.y)
        .fillStyle(function(d, l, c) {
          return this.parent.parent.active() == this.parent.parent.index ? "lightgreen" : (this.obj().data.indexOf(c.code) >= 0 ? "lightblue" : "white");
        })
        .event("mouseover", function() {
          this.parent.parent.active(this.parent.parent.index);
          return this.parent;
        })
        .event("mouseout", function() {
          this.parent.parent.active(-1);
          return this.parent;
        })
        .lineWidth(1)
        .strokeStyle("black");

    console.log('hi');
  },
  render: function() {
    this.vis.render();
  }
});