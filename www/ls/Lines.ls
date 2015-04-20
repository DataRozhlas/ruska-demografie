class ig.Lines
  (@parentElement, @data) ->
    width = height = 227px
    minX = d3.min @data.map -> d3.min it.data.map (.x)
    maxX = d3.max @data.map -> d3.max it.data.map (.x)
    padding = {top: 5 right: 7 bottom: 25 left: 47}
    innerWidth = width - padding.left - padding.right
    innerHeight = height - padding.top - padding.bottom
    xScale = d3.scale.linear!
      ..domain [minX, maxX]
      ..range [0, innerWidth]
    @data.forEach (line) ->
      extent = d3.extent line.data.map (.y)
      min = max = line.data.0
      for datum in line.data
        max = datum if datum.y > max.y
        min = datum if datum.y < min.y
      line.yExtent = [min.y, max.y]
      line.significantYPoints = [max, min]
      for endpoint in [line.data[0], line.data[*-1]]
        if endpoint not in line.significantYPoints
          line.significantYPoints.push endpoint
    yScales = @data.map (line, i) ->
      if line.fixedYExtent
        extent = that
      else
        extent = line.yExtent.slice!
        if extent.0 > 0 then extent.0 = 0
      console.log i, extent
      y = d3.scale.linear!
        ..domain extent
        ..range [innerHeight, 0]
    paths = @data.map (line, i) ->
      d3.svg.line!
        ..x -> xScale it.x
        ..y -> yScales[i] it.y
    @parentElement.selectAll \.line .data @data
      ..append \h2
        ..html (.title)
      ..append \svg
        ..attr {width, height}
        ..append \g
          ..attr \class \drawing
          ..attr \transform "translate(#{padding.left},#{padding.top})"
          ..append \path
            ..attr \d ({data}, i) -> paths[i] data
          ..selectAll \circle.point .data (.data) .enter!append \circle
            ..attr \class \point
            ..classed \significant (d, i, ii) ~> d in @data[ii].significantYPoints
            ..attr \cx ({x, y}, i) -> xScale x
            ..attr \cy ({x, y}, i, ii) -> yScales[ii] y
            ..attr \r 3
        ..append \g
          ..attr \class "axis x"
          ..attr \transform "translate(#{padding.left},#{height - 15})"
          ..append \line
            ..attr \class \extent
            ..attr \x1 -> xScale it.data.0.x
            ..attr \x2 -> xScale it.data[*-1].x
          ..selectAll \line.mark .data (.data) .enter!append \line
            ..attr \class \mark
            ..classed \significant (d, i, ii) ~> d in @data[ii].significantYPoints
            ..attr \x1 -> xScale it.x
            ..attr \x2 -> xScale it.x
            ..attr \y2 3
          ..selectAll \text .data (.significantYPoints) .enter!append \text
            ..attr \text-anchor \middle
            ..text -> it.x.toString!substr -2
            ..attr \y 15
            ..attr \x -> xScale it.x
        ..append \g
          ..attr \class "axis y"
          ..attr \transform "translate(37,#{padding.top})"
          ..append \line
            ..attr \class \extent
            ..attr \y1 (d, i) -> yScales[i] d.yExtent.0
            ..attr \y2 (d, i) -> yScales[i] d.yExtent.1
          ..selectAll \line.mark .data (-> it.data ++ it.significantYPoints) .enter!append \line
            ..attr \class \mark
            ..classed \significant (d, i, ii) ~> d in @data[ii].significantYPoints
            ..attr \x1 0
            ..attr \x1 -3
            ..attr \y1 (d, i, ii) -> yScales[ii] d.y
            ..attr \y2 (d, i, ii) -> yScales[ii] d.y
          ..selectAll \text .data (.significantYPoints) .enter!append \text
            ..text (d, i, ii) ~>
              if @data[ii].yFormat
                that d.y
              else
                decimals =
                  | d > 100 => 0
                  | d > 10 => 1
                  | otherwise => 2
                ig.utils.formatNumber d.y, decimals
            ..attr \y (d, i, ii) -> yScales[ii] d.y
            ..attr \dy 3
            ..attr \x -7
            ..attr \text-anchor \end
