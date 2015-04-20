getRusko92 = ->
  fields =
    doziti:
      title: "Věk dožití"
    "externi-umrti":
      title: "Úmrtí na externí příčiny"
    plodnost:
      title: "Plodnost"
    imigrace:
      title: "Imigrace"
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
ig.DataFormatter =
  rusko92: getRusko92!
