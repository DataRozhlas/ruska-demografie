ig.fit!
if ig.containers['prirustky']
  new ig.Prirustky do
    d3.select that
    ig.data['rus-adm-topo']
    ig.data['narodnosti-porodnost']

if ig.containers['line-russia']
  new ig.Lines do
    d3.select that
    ig.DataFormatter.rusko92

if ig.containers['line-russia-czech']
  new ig.Lines do
    d3.select that
    ig.DataFormatter.ceskoRusko92

if ig.containers['line-russia-czech-2']
  new ig.Lines do
    d3.select that
    ig.DataFormatter.ceskoRusko04

if ig.containers['line-external-deaths']
  new ig.Lines do
    d3.select that
    ig.DataFormatter.externi

if ig.containers['strom']
  new ig.Strom do
    d3.select that

if ig.containers['naklady']
  new ig.Naklady do
    d3.select that
    ig.DataFormatter.naklady
