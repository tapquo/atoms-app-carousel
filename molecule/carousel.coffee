ATTRIBUTES =
  TRANSITION  : "data-carousel-transition"
  POSITION    : "data-carousel-position"

TRANSITION =
  PREVIOUS  : "previous"
  CURRENT   : "current"
  NEXT      : "next"
  RESTORE   : "restoring"


TRIGGER_PX = 120
AUTO_INTERVAL = 3000
RESISTANCE = 4


class Atoms.Molecule.Carousel extends Atoms.Class.Molecule

  @template = """<div {{#if.style}}class="{{style}}"{{/if.style}}></div>"""

  @available = ["Atom.Figure", "Atom.Image", "Atom.Video", "Atom.Audio"]

  @base = "Form"

  constructor: ->
    super
    @index = new Atoms.App.Extension.Carousel.Index container: @el
    @children.unshift @index

    @auto_interval = setTimeout @next, AUTO_INTERVAL if @attributes.auto
    do @initialize
    @el.bind("touchstart", @_onStart)
      .bind("swiping", @_onSwiping)
      .bind("touchend", @_onEnd)
      .bind("webkitTransitionEnd", @_onTransitionEnd)

  initialize: ->
    console.log "children", @children.length ,@children
    @index?.reset()
    @current_index = 1
    @num_childs = @children.length - 1
    @blocked = false
    for child, index in @children when child.constructor.base isnt "index"
      transition = if index is 1 then TRANSITION.CURRENT else TRANSITION.NEXT
      child.el.attr ATTRIBUTES.POSITION, transition
      @index?.add index, index is 1

  next: =>
    if @_canGo(true)
      @_go(true)
      @blocked = true
    else if @attributes.auto
      @children[1].el.attr(ATTRIBUTES.POSITION, "next")
      @children[1].el.attr(ATTRIBUTES.TRANSITION, "current")
      @children[@num_childs].el.attr(ATTRIBUTES.TRANSITION, "next")
      @current_index = 1

  previous: =>
    if @_canGo(false)
      @_go(false)
      @blocked = true

  _onStart: (evt) =>
    return if @blocked
    @swiped = 0

  _onSwiping: (evt) =>
    if @swiped isnt null
      @swiped = evt.quoData.delta.x
      do @_handleSwipe
      clearTimeout @auto_interval if @attributes.auto
    evt.originalEvent.preventDefault()
    evt.stopPropagation()

  _onEnd: (evt) =>
    return if @swiped is null
    absPx = Math.abs(@swiped)
    if absPx > 0
      @blocked = true
      is_next = @swiped < 0
      if absPx > TRIGGER_PX and @_canGo(is_next) then @_go(is_next)
      else @_removeTransforms(true)
    @swiped = null

  _removeTransforms: (animate) ->
    _removeTransform(child.el[0]) for child in @children
    if animate
      @children[@current_index].el.attr(ATTRIBUTES.TRANSITION, TRANSITION.RESTORE)
      other_index = if @swiped > 0 then @current_index-1 else @current_index+1
      @children[other_index]?.el.attr(ATTRIBUTES.TRANSITION, TRANSITION.RESTORE)

  _resetPositions: ->
    child.el.removeAttr(ATTRIBUTES.POSITION) for child in @children

  _handleSwipe: ->
    target = @children[@current_index].el
    possible = @_canGo(@swiped < 0)
    toSwipe = if possible then @swiped else @swiped / (RESISTANCE + 1)
    target.vendor "transform", "translateX(#{toSwipe}px)"
    if possible
      otherTarget = Atoms.$(target[0][if @swiped > 0 then "previousSibling" else "nextSibling"])
      otherTarget.vendor "transform", "translateX(#{toSwipe}px)"

  _canGo: (is_next=true) ->
    !((@current_index is 1 and !is_next) or (@current_index is @num_childs and is_next))

  _go: (is_next) ->
    if is_next
      direction = TRANSITION.NEXT
      future_index = @current_index + 1
      @children[@current_index - 1]?.el.removeAttr(ATTRIBUTES.POSITION)
    else
      direction = TRANSITION.PREVIOUS
      future_index = @current_index - 1
      @children[@current_index + 1]?.el.removeAttr(ATTRIBUTES.POSITION)

    @_removeTransforms(false)
    @children[@current_index].el.attr(ATTRIBUTES.TRANSITION, direction)
    _removeTransform(@children[@current_index].el[0])
    @children[future_index].el.attr(ATTRIBUTES.TRANSITION, TRANSITION.CURRENT)
    @current_index = future_index

  _onTransitionEnd: (e) =>
    child = e.target
    transition = child.getAttribute(ATTRIBUTES.TRANSITION)
    position = child.getAttribute(ATTRIBUTES.POSITION)
    if transition is TRANSITION.CURRENT
      do @_resetPositions
      @index?.setActive @current_index
      child.setAttribute(ATTRIBUTES.POSITION, TRANSITION.CURRENT)
      child.previousSibling?.setAttribute(ATTRIBUTES.POSITION, TRANSITION.PREVIOUS)
      if child.nextSibling?
        if child.nextSibling.className != "index"
          child.nextSibling.setAttribute(ATTRIBUTES.POSITION, TRANSITION.NEXT)

    clearTimeout @auto_interval if @attributes.auto
    if transition is TRANSITION.CURRENT or (transition is TRANSITION.RESTORE and position is TRANSITION.CURRENT)
      @blocked = false
      if @attributes.auto
        setTimeout (=> @auto_interval = setTimeout(@next, AUTO_INTERVAL)), 100

    child.removeAttribute(ATTRIBUTES.TRANSITION)

_removeTransform = (el) ->
  el.style.webkitTransform = ""
  el.style.MozTransform = ""
  el.style.transform = ""
