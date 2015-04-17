
class ig.Prirustky
  (@parentElement, @topoJson, @oblastData) ->
    features = @processData @topoJson, @oblastData
    @drawMap features
    @drawCorrelator features

  drawCorrelator: (features) ->
    ele = @parentElement.select "div.col:nth-child(4) div"
    height = width = ele.node!clientWidth
    @svg = svg = ele.append \svg
      ..attr {width, height}
    padding = 10

    @x = d3.scale.linear!
      ..domain d3.extent features.map (.rusu)
      ..range [width - padding, padding]
    @y = d3.scale.linear!
      ..domain d3.extent features.map (.plodnost)
      ..range [height - padding, padding]

    svg.append \g
      ..selectAll \circle .data features .enter!append \circle
        ..attr \class \point
        ..attr \r 2
        ..attr \cx ~> @x it.rusu
        ..attr \cy ~> @y it.plodnost

    svg.append \g
      ..attr \transform "translate(0, #{@y 2})"
      ..append \text
        ..text "hranice přežití"
        ..attr \x padding
        ..attr \dy -21
      ..append \text
        ..text "2 děti na jednu matku"
        ..attr \x padding
        ..attr \dy -5
      ..append \line
        ..attr \class \sustainment-line
        ..attr \x1 padding
        ..attr \x2 width - padding
        ..attr \y1 0
        ..attr \y2 0
    svg.append \text
      ..attr \x width - padding
      ..attr \y height - padding
      ..attr \text-anchor \end
      ..text "Méně etnických Rusů ›"
    svg.append \text
      ..attr \x width - padding - 15
      ..attr \y height - 8
      ..attr \text-anchor \end
      ..attr \transform "rotate(90, #{width - padding}, #{height - padding})"
      ..text "Nižší plodnost ›"
    @highlightPoint @svg, features[33], -13, "Ingušsko"


  highlightPoint: (parent, feature, dx, text) ->
    direction = (if dx > 0 then 1 else -1)
    g = @svg.append \g
      ..attr \class \highlight
      ..attr \transform "translate(#{@x feature.rusu}, #{@y feature.plodnost})"
      ..append \circle
        ..attr \class \highlight
        ..attr \r 5.5
      ..append \line
        ..attr \x1 5.5 * direction
        ..attr \x2 dx
      ..append \text
        ..text text
        ..attr \text-anchor \end
        ..attr \x dx + 5 * direction
        ..attr \dy 3


  drawMap: (features) ->
    {geo} = ig.utils
    col = @parentElement.select "div.col:nth-child(2) div"
    width = col.node!clientWidth
    {projection, width, height} = geo.getFittingProjection features, {width}
    path = d3.geo.path!
      ..projection projection
    for feature in features
      feature.d = path feature

    color = d3.scale.linear!
      ..domain ig.utils.divideToParts do
        [0, 1]
        8
      ..range ['rgb(252,251,253)','rgb(239,237,245)','rgb(218,218,235)','rgb(188,189,220)','rgb(158,154,200)','rgb(128,125,186)','rgb(106,81,163)','rgb(84,39,143)','rgb(63,0,125)'].reverse!

    svg = col.append \svg .attr {width, height}
      ..selectAll \path .data features .enter!append \path
        ..attr \d (.d)
        ..attr \fill -> color it.rusu
    color2 = d3.scale.linear!
      ..domain ig.utils.divideToParts do
        d3.extent features.map (.plodnost)
        9
      ..range ['rgb(255,255,229)','rgb(247,252,185)','rgb(217,240,163)','rgb(173,221,142)','rgb(120,198,121)','rgb(65,171,93)','rgb(35,132,67)','rgb(0,104,55)','rgb(0,69,41)']

    col2 = @parentElement.select "div.col:nth-child(3) div"
    svg = col2.append \svg .attr {width, height}
      ..selectAll \path .data features .enter!append \path
        ..attr \d (.d)
        ..attr \fill -> color2 it.plodnost


  processData: (topoJson, oblastData) ->
    {features} = topojson.feature topoJson, topoJson.objects.data
    features_assoc = {}
    for feature in features
      features_assoc[feature.properties.id] = feature
    oblasti = {}
    for line in d3.tsv.parse oblastData
      ids = line.id.split ","
      for id in ids
        features_assoc[id]
          ..plodnost = parseFloat line['plodnost']
          ..rusu = parseFloat line['rusu']
          ..nazev = line['region']

    features
