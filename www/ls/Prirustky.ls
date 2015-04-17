
class ig.Prirustky
  (@parentElement, @topoJson, @oblastData) ->
    features = @processData @topoJson, @oblastData
    @drawMap features

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
    console.log d3.extent features.map (.plodnost)
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
        features_assoc[id].plodnost = parseFloat line['plodnost']
        features_assoc[id].rusu = parseFloat line['rusu']
    features
