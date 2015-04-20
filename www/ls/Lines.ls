class ig.Lines
  (@parentElement, @data) ->
    console.log @data
    width = height = 227px
    minX = d3.min @data.map -> d3.min it.data.map (.x)
    maxX = d3.max @data.map -> d3.max it.data.map (.x)
    padding = {top: 5 right: 7 bottom: 25 left: 7}
    innerWidth = width - padding.left - padding.right
    innerHeight = height - padding.top - padding.bottom
    xScale = d3.scale.linear!
      ..domain [minX, maxX]
      ..range [0, innerWidth]
    yScales = @data.map (line) ->
      extent = d3.extent line.data.map (.y)
      if extent.0 > 0 then extent.0 = 0
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
            ..attr \cx ({x, y}, i) -> xScale x
            ..attr \cy ({x, y}, i, ii) -> yScales[ii] y
            ..attr \r 3
        ..append \g
          ..attr \class \axis
          ..attr \transform "translate(#{padding.left},#{height - 15})"
          ..append \line
            ..attr \class \yExtent
            ..attr \x1 -> xScale it.data.0.x
            ..attr \x2 -> xScale it.data[*-1].x
          ..selectAll \line.mark .data (.data) .enter!append \line
            ..attr \class \mark
            ..attr \x1 -> xScale it.x
            ..attr \x2 -> xScale it.x
            ..attr \y2 3
          ..selectAll \text .data (-> [it.data[0], it.data[*-1]]) .enter!append \text
            ..attr \text-anchor \middle
            ..html -> it.x.toString!substr -2
            ..attr \y 15
            ..attr \x -> xScale it.x
