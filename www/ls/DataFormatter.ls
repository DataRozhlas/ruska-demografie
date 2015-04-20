getRusko92 = ->
  fields =
    doziti:
      title: "Věk dožití"
      fixedYExtent: [20, 65.73]
    "externi-umrti":
      title: "Úmrtí na externí příčiny"
    plodnost:
      title: "Plodnost"
    prirustek:
      title: "Přírůstek obyvatel"
  tsv = d3.tsv.parse ig.data['rusko-92'], (row) ->
    for field, value of row
      row[field] = parseFloat value
    row
  out = for id, field of fields
    field.data = tsv
      .map -> {x: it.rok, y: it[id]}
      .filter -> not isNaN it.y

    field.id = id
    field
  out

getCesko92 = ->
  out = getRusko92!
  fields =
    doziti:
      title: "Věk dožití"
    "externi-umrti":
      title: "Úmrtí na externí příčiny"
    plodnost:
      title: "Plodnost"
    prirustek:
      title: "Přírůstek obyvatel"
  tsv = d3.tsv.parse ig.data['cesko-92'], (row) ->
    for field, value of row
      row[field] = parseFloat value
    row
  for id, field of fields
    field.data = tsv
      .map -> {x: it.rok, y: it[id]}
      .filter -> not isNaN it.y

    field.id = id
    out.push field
  out[0, 4].forEach (.fixedYExtent = [56, 69.5])
  out[1, 5].forEach (.fixedYExtent = [0.9, 3.36])
  out[2, 6].forEach (.fixedYExtent = [1.3, 2.23])
  out[3, 7].forEach (.fixedYExtent = [0.61, 1.66])
  out


ig.DataFormatter =
  rusko92: getRusko92!
  cesko92: getCesko92!
