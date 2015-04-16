shareUrl = window.location

ig.fit = ->
  return unless $?
  $hero = $ "<div class='hero'></div>"
    ..append "<div class='overlay'></div>"
    ..append "<span class='copy'>Fotografie &copy; Magistrát města Karlovy Vary</span>"
    ..append "<a href='#' class='scroll-btn'>Continue reading</a>"
    ..find 'a.scroll-btn' .bind 'click touchstart' (evt) ->
      evt.preventDefault!
      offset = $filling.offset!top + $filling.height! - 50
      d3.transition!
        .duration 800
        .tween "scroll" scrollTween offset
  $ 'body' .prepend $hero

  $ '#article h1' .html 'The Greenest Czech Towns<br>As Seen from Space:<br>Karlovy Vary, Prague, Ostrava&hellip;'

  $filling = $ "<div class='ig filling'></div>"
    ..css \height $hero.height! + 50
  $ "p.perex" .after $filling

  $shares = $ "<div class='shares'>
    <a class='share fb' target='_blank' href='https://www.facebook.com/sharer/sharer.php?u=#shareUrl'><img src='https://samizdat.cz/tools/icons/facebook-bg-white.svg'></a>
    <a class='share tw' target='_blank' href='https://twitter.com/home?status=#shareUrl'><img src='https://samizdat.cz/tools/icons/twitter-bg-white.svg'></a>
  </div>"
  $hero.append $shares
  sharesTop = $shares.offset!top
  sharesFixed = no

  $ window .bind \resize ->
    $shares.removeClass \fixed if sharesFixed
    sharesTop := $shares.offset!top
    $shares.addClass \fixed if sharesFixed
    $filling.css \height $hero.height! + 50


  $ window .bind \scroll ->
    top = (document.body.scrollTop || document.documentElement.scrollTop)
    if top > sharesTop and not sharesFixed
      sharesFixed := yes
      $shares.addClass \fixed
    else if top < sharesTop and sharesFixed
      sharesFixed := no
      $shares.removeClass \fixed
  $shares.find \a .bind \click ->
    window.open do
      @getAttribute \href
      ''
      "width=550,height=265"
  <~ $
  $ '#aside' .remove!

scrollTween = (offset) ->
  ->
    interpolate = d3.interpolateNumber do
      window.pageYOffset || document.documentElement.scrollTop
      offset
    (progress) -> window.scrollTo 0, interpolate progress
