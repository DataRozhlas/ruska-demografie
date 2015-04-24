countryNames =
  "cesko"      : "Česko"
  "rusko"      : "Rusko"
  "mexiko"     : "Mexiko"
  "chorvatsko" : "Chorvatsko"
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
    @xScales = @data.map ->
      if it.fixedXExtent
        d3.scale.linear!
          ..domain it.fixedXExtent
          ..range [0, innerWidth]
      else
        xScale
    barWidth = innerWidth / (@xScales[0].domain!.1 - @xScales[0].domain!.0)
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
    @yScales = @data.map (line, i) ->
      if line.fixedYExtent
        extent = that
      else
        extent = line.yExtent.slice!
      y = d3.scale.linear!
        ..domain extent
        ..range [innerHeight, 0]
    paths = @data.map (line, i) ~>
      d3.svg.line!
        ..x ~> @xScales[i] it.x
        ..y ~> @yScales[i] it.y
    @parentElement.selectAll \.line .data @data
      ..append \h3
        ..html (.title)
      ..append \h4
        ..html (.subtitle)
      ..append \h5
        ..html -> countryNames[it.country]
      ..append \svg
        ..attr {width, height}
        ..append \g
          ..attr \transform "translate(#{padding.left},#{padding.top})"
          ..attr \class \active-lines
          ..append \line
            ..attr \class \horizontal
            ..attr \x1 -13
          ..append \line
            ..attr \class \vertical
            ..attr \y2 innerHeight + 13
        ..append \g
          ..attr \class \drawing
          ..attr \transform "translate(#{padding.left},#{padding.top})"
          ..append \path
            ..attr \d ({data}, i) -> paths[i] data
          ..selectAll \circle.point .data (.data) .enter!append \circle
            ..attr \class \point
            ..classed \significant (d, i, ii) ~> d in @data[ii].significantYPoints
            ..attr \cx ({x, y}, i, ii) ~> @xScales[ii] x
            ..attr \cy ({x, y}, i, ii) ~> @yScales[ii] y
            ..attr \r 3
        ..append \g
          ..attr \class "axis x"
          ..attr \transform "translate(#{padding.left},#{height - 15})"
          ..append \line
            ..attr \class \full-extent
            ..attr \x1 -10
            ..attr \x2 innerWidth + padding.right
          ..append \line
            ..attr \class \extent
            ..attr \x1 (d, i) ~> @xScales[i] d.data.0.x
            ..attr \x2 (d, i) ~> @xScales[i] d.data[*-1].x
          ..selectAll \line.mark .data (.data) .enter!append \line
            ..attr \class \mark
            ..classed \significant (d, i, ii) ~> d in @data[ii].significantYPoints
            ..attr \x1 (d, i, ii) ~> @xScales[ii] d.x
            ..attr \x2 (d, i, ii) ~> @xScales[ii] d.x
            ..attr \y2 3
          ..selectAll \text.significant .data (.significantYPoints) .enter!append \text
            ..attr \class \significant
            ..attr \text-anchor \middle
            ..text -> it.x.toString!substr -2
            ..attr \y 15
            ..attr \x (d, i, ii) ~> @xScales[ii] d.x
          ..append \text
            ..attr \class \active-text
            ..attr \text-anchor \middle
            ..attr \y 15
        ..append \g
          ..attr \class "axis y"
          ..attr \transform "translate(37,#{padding.top})"
          ..append \line
            ..attr \class \full-extent
            ..attr \y1 0
            ..attr \y2 innerHeight + 10
          ..append \line
            ..attr \class \extent
            ..attr \y1 (d, i) ~> @yScales[i] d.yExtent.0
            ..attr \y2 (d, i) ~> @yScales[i] d.yExtent.1
          ..selectAll \line.mark .data (-> it.data ++ it.significantYPoints) .enter!append \line
            ..attr \class \mark
            ..classed \significant (d, i, ii) ~> d in @data[ii].significantYPoints
            ..attr \x1 0
            ..attr \x1 -3
            ..attr \y1 (d, i, ii) ~> @yScales[ii] d.y
            ..attr \y2 (d, i, ii) ~> @yScales[ii] d.y
          ..selectAll \text.significant .data (.significantYPoints) .enter!append \text
            ..attr \class \significant
            ..text (d, i, ii) ~> @createText d, @data[ii]
            ..attr \y (d, i, ii) ~> @yScales[ii] d.y
            ..attr \dy 3
            ..attr \x -7
            ..attr \text-anchor \end
          ..append \text
            ..attr \class \active-text
            ..attr \dy 3
            ..attr \x -7
            ..attr \text-anchor \end
        ..append \g
          ..attr \transform "translate(#{padding.left},#{padding.top})"
          ..attr \class \interaction
          ..selectAll \rect .data ((d, i) ~> [@xScales[i].domain!0 to @xScales[i].domain!1]) .enter!append \rect
            ..attr \width barWidth
            ..attr \x (d, i, ii) ~> (@xScales[ii] d) - barWidth / 2
            ..attr \height innerHeight + 30
            ..attr \y -5
            ..on \mouseover ~> @highlight it
            ..on \tochstart ~> @highlight it
            ..on \mouseout @~downlight
    @svg = @parentElement.selectAll \svg
    @circles = @svg.selectAll \circle
    @activeLineHorizontal = @svg.selectAll ".active-lines .horizontal"
    @activeLineVertical   = @svg.selectAll ".active-lines .vertical"
    @activeTextX = @svg.selectAll ".axis.x text.active-text"
    @activeTextY = @svg.selectAll ".axis.y text.active-text"

  highlight: (x) ->
    @svg.classed \active yes
    @circles.classed \active (.x == x)
    points = @data.map (line) ->
      line.data.filter (-> it.x == x) .pop! || null

    @activeLineHorizontal
      ..filter ((d, _, i) -> points[i])
        ..classed \active yes
        ..attr \x2 (d, _, i) ~> @xScales[i] points[i].x
        ..attr \y1 (d, _, i) ~> @yScales[i] points[i].y
        ..attr \y2 (d, _, i) ~> @yScales[i] points[i].y

    @activeLineVertical
      ..filter ((d, _, i) -> points[i])
        ..classed \active yes
        ..attr \y1 (d, _, i) ~> @yScales[i] points[i].y
        ..attr \x1 (d, _, i) ~> @xScales[i] points[i].x
        ..attr \x2 (d, _, i) ~> @xScales[i] points[i].x

    @activeTextX
      ..filter ((d, _, i) -> points[i])
        ..classed \active yes
        ..attr \x (d, _, i) ~> @xScales[i] points[i].x
        ..text (d, _, i) -> points[i].x.toString!substr -2

    @activeTextY
      ..filter ((d, _, i) -> points[i])
        ..classed \active yes
        ..attr \y (d, _, i) ~> @yScales[i] points[i].y
        ..text (d, _, i) ~> @createText points[i], @data[i]

  downlight: ->
    @parentElement
      .selectAll \.active
      .classed \active no

  createText: (point, line) ->
    if line.yFormat
      that point.y
    else
      decimals =
        | point.y > 100 => 0
        | point.y > 10 => 1
        | otherwise => 2
      ig.utils.formatNumber point.y, decimals
