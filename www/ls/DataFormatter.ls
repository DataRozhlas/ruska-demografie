parseData = (key, fields) ->
  tsv = d3.tsv.parse ig.data[key], (row) ->
    for field, value of row
      row[field] = parseFloat value
    row

  out = for id, field of fields
    field.data = tsv
      .map -> {x: it.rok, y: it[id]}
      .filter -> not isNaN it.y

    field.id = id
    field

getCeskoRuskoFields = ->
  doziti:
    title: "Věk dožití"
  "externi-umrti":
    title: "Úmrtí na externí příčiny"
  plodnost:
    title: "Plodnost"
  prirustek:
    title: "Přírůstek obyvatel"

getRusko92 = ->
  fields = getCeskoRuskoFields!
    ..doziti.fixedYExtent: [20, 65.73]
  parseData 'rusko-92', fields

getCeskoRusko92 = ->
  out = getRusko92!
  fields = getCeskoRuskoFields!
  out ++= parseData "cesko-92", fields
  out[0, 4].forEach (.fixedYExtent = [56, 69.5])
  out[1, 5].forEach (.fixedYExtent = [0.9, 3.36])
  out[2, 6].forEach (.fixedYExtent = [1.3, 2.23])
  out[3, 7].forEach (.fixedYExtent = [0.61, 1.66])
  out

getCeskoRusko04 = ->
  fieldsRusko = getCeskoRuskoFields!
  out = parseData 'rusko-04', fieldsRusko
  fieldsCesko = getCeskoRuskoFields!
  out ++= parseData 'cesko-04', fieldsCesko
  out[0, 4].forEach (.fixedYExtent = [58.9, 75.2])
  out[1, 5].forEach (.fixedYExtent = [0.79, 3.8])
  out[2, 6].forEach (.fixedYExtent = [1.23, 1.76])
  out[3, 7].forEach (.fixedYExtent = [0.63, 1.14])
  out

ig.DataFormatter =
  rusko92: getRusko92!
  ceskoRusko92: getCeskoRusko92!
  ceskoRusko04: getCeskoRusko04!
