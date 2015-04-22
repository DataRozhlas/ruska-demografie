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

getExternalFields = ->
  "nasilna-smrt":
    title: "Násilná smrt"
  "valecna-smrt":
    title: "Válečná smrt"
  "sebevrazdy":
    title: "Sebevraždy"
  "dopravni-nehody":
    title: "Dopravní nehody"

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


getExterni = ->
  out = []
  for country in <[rusko chorvatsko mexiko]>
    fields = getExternalFields!
    out ++= parseData "#{country}-externi", fields

  out[0, 4, 8].forEach (.fixedYExtent = [0.04, 0.53])
  out[1, 5, 9].forEach (.fixedYExtent = [0, 1.27])
  out[2, 6, 10].forEach (.fixedYExtent = [0.07, 0.75])
  out[3, 7, 11].forEach (.fixedYExtent = [0.22, 0.51])
  out[0 to 3].forEach (.fixedXExtent = [1989 1996])
  out[4 to 7].forEach (.fixedXExtent = [1989 1996])
  out[8 to 11].forEach (.fixedXExtent = [2005 2012])
  out

getNaklady = ->
  countries = <[de cz ru in]>
  lines = d3.tsv.parse ig.data.naklady, (row) ->
    line =
      type: row['expense-type']
      data: for field in countries
        parseFloat row[field]
  {countries, lines}



ig.DataFormatter =
  rusko92: getRusko92!
  ceskoRusko92: getCeskoRusko92!
  ceskoRusko04: getCeskoRusko04!
  externi: getExterni!
  naklady: getNaklady!
