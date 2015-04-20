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
    ig.DataFormatter.cesko92
