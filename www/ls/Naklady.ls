countryNames =
  de: "Německo"
  cz: "Česko"
  ru: "Rusko"
  in: "Indie"
class ig.Naklady
  (@parentElement, @data) ->
    @graph = @parentElement.select \.graph
    {clientWidth:@width} = @graph.node!
    @height = 390
    @padding = top: 30px right: 262px  bottom: 20px left: 262px
    @innerWidth  = @width - (@padding.left + @padding.right)
    @innerHeight = @height - (@padding.top + @padding.bottom)
    @drawLines!
    @drawVoronoiOverlay!

  drawLines: ->
    xStep = @innerWidth / 3
    @xScale = xScale = (index) -> index * xStep
    @yScale = yScale = ~> @innerHeight - (it * 1 / 0.306 * @innerHeight)
    path = d3.svg.line!
      ..x (.x)
      ..y (.y)
      ..interpolate \monotone

    @svg = @graph.append \svg
      ..attr {@width, @height}
      ..append \g
        ..attr \class \drawing
        ..attr \transform "translate(#{@padding.left},#{@padding.top})"
        ..selectAll \g.pole .data @data.countries .enter!append \g
          ..attr \class \pole
          ..attr \transform (d, i) -> "translate(#{xScale i}, 0)"
          ..append \line
            ..attr \y2 @innerHeight
          ..append \text
            ..attr \text-anchor \middle
            ..attr \dy -14
            ..text -> countryNames[it]
        ..append \g
          ..selectAll \g.line .data @data.lines .enter!append \g
            ..attr \class \line
            ..append \path
              ..attr \d ->
                line = []
                lead = 3
                for point, index in it.data
                  y = yScale point
                  x = xScale index
                  if index > 0 => line.push {y, x: x - lead}
                  if index == 0
                    x += 3
                  if index == it.data.length - 1
                    x -= 3
                  line.push {x, y}
                  if index < it.data.length - 1 => line.push {y, x: x + lead}
                path line
            ..selectAll \circle.point .data (.data) .enter!append \circle
              ..attr \class \point
              ..attr \r 5
              ..attr \cx (d, i) -> xScale i
              ..attr \cy yScale
            ..append \g
              ..attr \class \label-start
              ..attr \transform ->
                  y = yScale it.data[3]
                  y += switch it.type
                  | "Jídlo a nealkoholické nápoje" => -6
                  | "Rekreace a kultura"           => 8
                  | "Restaurace a hotely"          => -11
                  | "Oblečení a obuv"              => 5
                  | "Nákupy automobilů"            => 18
                  | otherwise                      => 4
                  "translate(500,#y)"
              ..append \text
                ..text -> "#{it.type}"
              ..append \line
                ..attr {x2: 0 y1: 4, y2: 4}
                ..attr \x1 -> @parentNode.querySelector 'text' .getBBox!width
              ..attr \text-anchor \start
          ..selectAll \g.label .data @data.lines .enter!append \g
            ..attr \class \label
            ..selectAll \text.point .data (.data) .enter!append \text
              ..attr \class \point
              ..attr \x (d, i) -> xScale i
              ..attr \y yScale
              ..text -> "#{ig.utils.formatNumber it * 100, 2} %"
              ..attr \dy 15
              ..attr \text-anchor (d, i) -> if i then \end else \start
              ..attr \dx (d, i) -> if i then -9 else 12
    @lines = @svg.selectAll \g.line
    @labels = @svg.selectAll \g.label
    @addPopisek do
      @yScale 0.305
      @yScale 0.285
      "Rusové i Indové platí nejvíc za jídlo, téměř třetinu příjmů.<br>To je charakteristické pro rozvojové ekonomiky."
    @addPopisek do
      @yScale 0.145
      @yScale 0.10
      "Naopak mají poloviční náklady spojené s bydlením. V Rusku cenu snižují státní dotace na energie"
    @addPopisek do
      @yScale 0.08
      @yScale 0.03
      "Rusové hodně utrácejí za alkohol, oblečení a nová auta"

  drawVoronoiOverlay: ->
    points = []
    for line in @data.lines
      for point, index in line.data
        x = @xScale index
        y = @yScale point
        points.push {x, y, line}
    @voronoi = d3.geom.voronoi!
      ..x ~> @padding.left + it.x
      ..y ~> @padding.top + it.y
      ..clipExtent [[0, 0], [@width, @height]]
    voronoiPolygons = @voronoi points
      .filter -> it
    @svg.append \g
      ..attr \class \voronoi
      ..selectAll \path .data voronoiPolygons .enter!append \path
        ..attr \d polygon
        ..on \mouseover ~> @highlightLine it.point.line
        ..on \touchstart ~> @highlightLine it.point.line
        ..on \mouseout ~> @downlightLines!

  highlightLine: (line) ->
    @graph.classed \active yes
    @lines.classed \active -> it is line
    @labels.classed \active -> it is line
    @texts

  downlightLines: ->
    @graph.classed \active no

  addPopisek: (y0, y1, text) ->
    height = Math.max do
      Math.abs y0 - y1
      1
    top = y0 + @padding.top

    @graph.append \div
      ..attr \class "popisek"
      ..classed \single-line height == 1
      ..style \top "#{top}px"
      ..style \height "#{height}px"
      ..append \div
        ..style \top "#{height * 0.5}px"
        ..attr \class \content
        ..html text



polygon = ->
  "M#{it.join "L"}Z"
