var SliderChart = $.Class.create({
  initialize: function(config) {
    this.cats = pv.keys(config['data']);
    this.states = config['states'];
    this.data = config['data'];
    this.proposal = config['proposal'];
    this.totals = config['totals'];
    this.align = config['align'];
    this.editable = config['editable'];
    this.normalized = config['normalized'];
    this.total_id = config['total_id'];
    this.scale = config['scale'];

    this.formatScaledNumber = function(number, format) {
      return $.formatNumber(number * this.scale, format)
    };

    var totals = (this.totals ? this.totals : this.totals = new Array(this.states.length));
    if (this.normalized) {
      pv.values(this.data).forEach(function(v) {
        for (var i = 0; i < v.length; i++) {
          totals[i] = (totals[i] || 0) + v[i];
        }
      });
      config['normalized_data'] = this.normalized_data = pv.dict(pv.keys(this.data), function(c) {
        var chunk = config['data'][c].slice(0);
        for (var i = 0; i < chunk.length; i++) {
          chunk[i] = chunk[i] / totals[i];
        }
        return chunk;
      });
      pv.keys(this.proposal).forEach(function(c) {
        config['proposal'][c] = config['normalized_data'][c].slice(0);
      });
    } else {
      pv.values(this.data).forEach(function(v) {
        for (var i = 0; i < v.length; i++) {
          totals[i] = 1;
        }
      });
    }

    var ordered_cats = this.cats.slice(0);
    ordered_cats.sort(function(a, b) {
      if (config['editable']) {
        return config['data'][b][0] - config['data'][a][0];
      } else {
        if (config['normalized']) {
          return pv.median(config['normalized_data'][b]) - pv.median(config['normalized_data'][a]);
        } else {
          return pv.median(config['data'][b]) - pv.median(config['data'][a]);
        }
      }
    });
    this.cats = ordered_cats;
    this.ordered_data = this.cats.map(function(c) {
      return config['normalized'] ? config['normalized_data'][c] : config['data'][c];
    });

    this.w = config['width'];
    if (this.editable) {
      this.h = this.cats.length * config['bar_height'];
    } else {
      this.h = this.cats.length * (pv.max(this.ordered_data.map(function(d) { return d.length; })) * config['bar_height'] + 20);
    }
    this.x = pv.Scale.linear(0, pv.max(this.ordered_data.map(function(d) { return pv.max(d); })) * 1.5).range(0, this.w);
    this.y = pv.Scale.ordinal(this.cats).splitBanded(0, this.h, 1);

    //this.overlay_colors = pv.colors('rgb(27,158,119)', 'rgb(217,95,2)', 'rgb(117,112,179)', 'rgb(231,41,138)', 'rgb(102,166,30)');
    this.overlay_colors = pv.Colors.category10();
    //this.overlay_colors = pv.Colors.category20();

    this.moreColor = pv.color('limegreen').alpha(0.5);
    this.lessColor = pv.color('red').alpha(0.5);
    this.evenColor = 'rgb(130,181,217)';
    this.oddColor  = 'rgb(174,199,232)';

    this.vis = new pv.Panel()
        .def('obj', this)
        .events('all')
        .event("mousemove", pv.Behavior.point(config['bar_height'] / 8))
        .top(25)
        .width(this.w)
        .height(this.h);

    // Original value bars
    this.orig_panels = this.vis.add(pv.Panel)
        .def('obj', this)
        .data(this.ordered_data)
        .top(function() { return this.obj().y(this.index); })
        .height(this.y.range().band);

    this.orig_bars = this.orig_panels.add(pv.Bar)
        .data(function(d) { return d; })
        .width(this.x)
        .fillStyle(function(d) {
          if (!this.parent.obj().proposal || this.parent.obj().proposal[this.parent.obj().cats[this.parent.index]][this.index] >= d) {
            return this.index % 2 ? this.parent.obj().oddColor : this.parent.obj().evenColor;
          } else {
            return this.parent.obj().lessColor;
          }
        });

    if (this.editable) {
      this.orig_bars.visible(function(d) { return this.index == 0; })
        .top(function(d, g) { return this.index * this.parent.obj().y.range().band; })
        .height(function(d, g) { return this.parent.obj().y.range().band - 2; });
    } else {
      this.orig_bars.top(function(d, g) {
          return this.index * ((this.parent.obj().y.range().band - 20) / g.length) + 20;
        })
        .height(function(d, g) { return (this.parent.obj().y.range().band - 20) / g.length - 2; });
    }

    if (!this.editable) {
      var orig_bar_labels = this.orig_bars.anchor(this.align == 'left' ? 'right' : 'left').add(pv.Label)
          .textAlign(this.align)
          .textBaseline("middle")
          .textMargin(5)
          .textStyle('grey')
          .font("bold 10px sans-serif")
          .text(function(d) { return '$' + this.parent.obj().formatScaledNumber(d * this.parent.obj().totals[this.index], {format:"#,###.00", locale:"us"}); });
    }

    this.category_labels = this.vis.add(pv.Label)
        .data(this.ordered_data)
        .textMargin(0)
        .textBaseline('bottom')
        .top(function(d, g) { return this.parent.obj().y(this.index) + 5; })
        .font("bold 12px sans-serif")
        .textBaseline('top')
        .visible(function() { return !this.parent.obj().editable; })
        .text(function() { return this.parent.obj().cats[this.index] + ':'; });

    this.axis_labels = this.orig_bars.anchor(this.align).add(pv.Label)
        .font("bold 12px sans-serif")
        .text(function() {
          if (this.parent.obj().editable) {
            return this.parent.obj().cats[this.parent.index];
          } else {
            return this.parent.obj().states[this.index];
          }
        });

    if (this.editable) {
      this.proposal_bars = this.vis.add(pv.Panel)
          .def('obj', this)
          .data(function() { return this.obj().cats.map(function(c) { return config['proposal'][c]; }); })
          .top(function() { return this.obj().y(this.index); })
          .height(this.y.range().band)
        .add(pv.Bar)
          .data(function(d) { return d; })
          .visible(function() { return this.index == 0; })
          .top(function(d, g) { return this.index * this.parent.obj().y.range().band; })
          .height(function(d, g) { return this.parent.obj().y.range().band - 2; })
          .width(function(d) {
            if (this.parent.obj().ordered_data[this.parent.index][this.index] < d) {
              return this.parent.obj().x(d - this.parent.obj().ordered_data[this.parent.index][this.index]);
            } else return this.parent.obj().x(d);
          })
          .strokeStyle('black')
          .lineWidth(0)
          .fillStyle(function(d) {
            if (this.parent.obj().ordered_data[this.parent.index][this.index] < d) {
              return this.parent.obj().moreColor;
            } else if (this.index % 2) {
              return this.parent.obj().oddColor;
            } else return this.parent.obj().evenColor;
          });

      this.positions = new Array();
      for (var i = 0; i < this.cats.length; i++) {
        var local_cat = this.cats[i];
        var local_positions = this.proposal[local_cat].slice(0);
        this.positions[i] = new Array();
        for (var j = 0; j < local_positions.length; j++) {
          this.positions[i][j] = {
            x: this.x(local_positions[j]),
            state: this.states[j],
            category: local_cat
          };
          if (this.align == 'right') {
            this.positions[i][j].x = this.w - this.positions[i][j].x;
          }
        }
      }

      // Drag handle
      this.handle_container = this.vis.add(pv.Panel)
          .def('obj', this)
          .data(this.positions)
          .top(function() { return this.obj().y(this.index); })
          .height(this.y.range().band)
        .add(pv.Bar)
          .data(function(d) { return d; })
          .visible(function() { return this.index == 0; })
          /*
          .top(function(d) { return this.index * this.parent.obj().y.range().band - (config['bar_height'] / 5 + 4); })
          .height(function(d) { return this.parent.obj().y.range().band + config['bar_height'] / 5 + 4; })
          */
          .top(function(d) { return this.index * this.parent.obj().y.range().band; })
          .height(function(d) { return this.parent.obj().y.range().band - 2; })
          .width(30)
          .cursor("pointer")
          .event("mousedown", pv.Behavior.drag())
          .event("dragstart", this.update)
          .event("drag", this.update)
          .fillStyle("rgba(0,0,0,0.001)");

      this.handle_bars = this.handle_container.add(pv.Bar)
          .cursor("pointer")
          .event("mousedown", pv.Behavior.drag())
          .event("dragstart", this.update)
          .event("drag", this.update)
          .width(2)
          .fillStyle("black");

      this.handle_tips = this.handle_bars.add(pv.Dot)
          .def('obj', this)
          .data(function(d) { return d; })
          .cursor("pointer")
          .event("mousedown", pv.Behavior.drag())
          .event("dragstart", this.update)
          .event("drag", this.update)
          .shape("circle")
          .angle(Math.PI / 2)
          .top(function(d, g) { return (this.index * this.obj().y.range().band) + config['bar_height'] / 2 - 1; })
          .left(function(d) { return d.x + 1; })
          .lineWidth(0)
          .strokeStyle('black')
          .fillStyle('black')
          .radius(config['bar_height'] / 5);

      /*
      this.handle_dots_left = this.handle_bars.add(pv.Dot)
          .def('obj', this)
          .data(function(d) { return d; })
          .cursor("pointer")
          .event("mousedown", pv.Behavior.drag())
          .event("dragstart", this.update)
          .event("drag", this.update)
          .shape("triangle")
          .angle(Math.PI / 2)
          .top(function(d, g) { return (this.index * this.obj().y.range().band) - (config['bar_height'] / 10 + 3); })
          .lineWidth(0)
          .strokeStyle('black')
          .fillStyle(this.lessColor.alpha(1))
          .left(function(d) { return d.x - (config['bar_height'] / 10 + 3); })
          .radius(config['bar_height'] / 10);
      this.handle_dots_right = this.handle_bars.add(pv.Dot)
          .def('obj', this)
          .data(function(d) { return d; })
          .cursor("pointer")
          .event("mousedown", pv.Behavior.drag())
          .event("dragstart", this.update)
          .event("drag", this.update)
          .shape("triangle")
          .angle(-Math.PI / 2)
          .top(function(d, g) { return (this.index * this.obj().y.range().band) - (config['bar_height'] / 10 + 3); })
          //.top(function(d) { return (this.index * this.obj().y.range().band) + (this.obj().y.range().band / 2); })
          .lineWidth(0)
          .strokeStyle('black')
          .fillStyle(this.moreColor.alpha(1))
          .left(function(d) { return d.x + (config['bar_height'] / 10 + 3); })
          .radius(config['bar_height'] / 10);
      */

      /*
      this.handle_labels = this.handle_bars.anchor(this.align == 'left' ? 'right' : 'left').add(pv.Label)
          .def('obj', this)
          .cursor("pointer")
          .textAlign(this.align)
          .textBaseline("middle")
          .textMargin(5)
          .top(10)
          //.textStyle('rgba(0,0,0,0.5)')
          .strokeStyle('black')
          .font("bold 10px sans-serif");
          */

      if (this.align == 'left') {
        this.proposal_bars.left(function(d) {
          if (this.parent.obj().ordered_data[this.parent.index][this.index] < d) {
            return this.parent.obj().x(this.parent.obj().ordered_data[this.parent.index][this.index]);
          } else return 0;
        });
        this.handle_container.left(function(d) { return d.x - 15; });
        this.handle_bars.left(function(d) { return d.x; });
        //this.handle_labels.text(function(d) { return '$' + this.obj().formatScaledNumber(this.obj().x.invert(d.x) * this.obj().totals[this.index], {format:"#,###.00", locale:"us"}); });
      } else if (this.align == 'right') {
        this.proposal_bars.right(function(d) {
          if (this.parent.obj().ordered_data[this.parent.index][this.index] < d) {
            return this.parent.obj().x(this.parent.obj().ordered_data[this.parent.index][this.index]);
          } else return 0;
        });
        this.handle_container.left(function(d) { return d.x - 15; });
        this.handle_bars.left(function(d) { return d.x - 2; });
        //this.handle_labels.text(function(d) { return '$' + this.obj().formatScaledNumber(this.obj().x.invert(this.obj().w - d.x) * this.obj().totals[this.index], {format:"#,###.00", locale:"us"}); });
      }
    }

    if (this.editable && pv.max(this.ordered_data.map(function(d) { return d.length; })) > 1) {
      this.compare_panels = this.vis.add(pv.Panel)
          .def('obj', this)
          .def('active', this.states.length - 1)
          .data(this.states)
          .top(0)
          .visible(function(d) { return this.index != 0; })
          .height(this.h);

      this.compare_lines = this.compare_panels.add(pv.Line)
          .data(this.ordered_data)
          //.interpolate('cardinal')
          .top(function() {
            return this.index * this.parent.obj().y.range().band * 3 +
                this.parent.obj().y.range().band * 2.5;
          })
          .strokeStyle(function() { return this.parent.obj().overlay_colors(this.parent.index).alpha(0.33); })
          .lineWidth(function() { return (this.parent.active() == this.parent.index) ? 6 : 0; })

      this.compare_dots = this.compare_lines.add(pv.Dot)
          .cursor('pointer')
          .radius(config['bar_height'] / 7)
          .strokeStyle('none')
          .fillStyle(function() {
            var local_color = this.parent.obj().overlay_colors(this.parent.index);
            return this.parent.active() == this.parent.index ? local_color : local_color.alpha(0.75);
          })
          .event("point", function() { return this.parent.active(this.parent.index).parent; });

      this.compare_dots.anchor('top').add(pv.Label)
          .visible(function() { return this.parent.active() == this.parent.index; })
          .textStyle(function() { return pv.color(this.parent.obj().overlay_colors(this.parent.index)).alpha(1); })
          .textMargin(15)
          .textAlign(this.align)
          .font("bold 12px sans-serif")
          .text(function(d) { return this.parent.obj().states[this.parent.index] + ': ' + '$' + this.parent.obj().formatScaledNumber(d[this.parent.index] * this.parent.obj().totals[this.parent.index], {format:"#,###.00", locale:"us"}); });
    }

    // X-axis ticks
    this.x_rules = this.vis.add(pv.Rule)
        .data(this.x.ticks(5))
        .visible(!this.editable)
        .strokeStyle(function(d) { return d ? "rgba(255,255,255,.3)" : "#ddd"; })
        .lineWidth(function(d) { return d ? 0 : 1; });

    this.vis.add(pv.Rule)
        .data(this.x.ticks(5))
        .left(this.x)
        .strokeStyle(function(d) { return d ? 'rgba(255,255,255,0.3)' : 'black'; })
      .add(pv.Rule)
        .top(-8)
        .height(5)
        .strokeStyle('black')
      .anchor('top').add(pv.Label)
        .def('obj', this)
        .top(-8)
        .font("bold 10px sans-serif")
        .text(function(d) { return '$' + (d ? this.obj().formatScaledNumber(d / 1000000000, {format:"#,###.##", locale:"us"}) : 0) + 'b'; });

    if (this.align == 'left') {
      if (this.editable) {
        this.vis.left(190);
      } else {
        this.vis.left(50);
      }
      this.vis.right(110);
      this.orig_bars.left(0);
      this.axis_labels
        .textAlign('right')
        .textMargin(10);
      this.category_labels.left(5)
        .textAlign('left');
      this.x_rules.left(this.x);
      this.compare_lines.left(function(d) { return this.parent.obj().x(d[this.parent.index]); });
    } else if (this.align == 'right') {
      if (this.editable) {
        this.vis.right(190);
      } else {
        this.vis.right(50);
      }
      this.vis.left(120);
      this.orig_bars.right(0);
      this.axis_labels
        .textAlign('left')
        .textMargin(10);
      this.category_labels.right(5)
        .textAlign('right');
      this.x_rules.right(this.x);
      this.compare_lines.right(function(d) { return this.parent.obj().x(d[this.parent.index]); });
    }
  },
  update: function(d) {
    var bar_width = d.x;
    var total_prefix = '$ ';
    if (this.parent.obj().align == 'right') {
      bar_width = this.parent.obj().w - bar_width;
      total_prefix += '-'
    }
    var state_index = this.parent.obj().states.indexOf(d.state);
    this.parent.obj().proposal[d.category][state_index] = this.parent.obj().x.invert(bar_width);
    $('#' + this.parent.obj().total_id).text(total_prefix + this.parent.obj().formatScaledNumber(pv.sum(pv.values(this.parent.obj().proposal).map(function(d) { return d[state_index]; })) * this.parent.obj().totals[state_index], {format:"#,###.00", locale:"us"}));
    $(document).trigger('total_changed');
    return this.parent.obj().vis;
  },
  render: function() {
    this.vis.render();
  }
});