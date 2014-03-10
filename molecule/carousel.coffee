ATTRIBUTES =
  TRANSITION  : "data-carousel-transition"
  POSITION    : "data-carousel-position"

TRANSITION =
  PREVIOUS  : "previous"
  CURRENT   : "current"
  NEXT      : "next"

TRIGGER_PX = 120
RESISTANCE = 1 / 4


_removeTransform = (el) ->
  el.style.webkitTransform = ""
  el.style.MozTransform = ""
  el.style.transform = ""


class Atoms.Molecule.Carousel extends Atoms.Class.Molecule

  @base = "Form"

  @template = """
    <div id="{{id}}" {{#if.style}}class="{{style}}" {{/if.style}}></div>
  """

  constructor: ->
    super
    @index = @appendChild "Atom", "CarouselIndex", {}
    do @initialize
    @el.bind("touchstart", @_onStart)
      .bind("swiping", @_onSwiping)
      .bind("touchend", @_onEnd)
      .bind("webkitTransitionEnd", @_onTransitionEnd)

  initialize: ->
    @index.reset()
    @current_index = 0
    @num_childs = @children.length - 1
    @blocked = false
    for child, i in @children
      if not child.el.hasClass("index")
        if i is 0 then child.el.attr(ATTRIBUTES.POSITION, TRANSITION.CURRENT)
        else if i is 1 then child.el.attr(ATTRIBUTES.POSITION, TRANSITION.NEXT)
        @index.add(i, i is 0)

  next: ->
    if @_canGo(true)
      @_go(true)
      @blocked = true

  previous: ->
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
      @children[@current_index].el.attr(ATTRIBUTES.TRANSITION, "restoring")
      other_index = if @swiped > 0 then @current_index-1 else @current_index+1
      @children[other_index]?.el.attr(ATTRIBUTES.TRANSITION, "restoring")

  _resetPositions: ->
    child.el.removeAttr(ATTRIBUTES.POSITION) for child in @children

  _handleSwipe: ->
    target = @children[@current_index].el
    possible = @_canGo(@swiped < 0)
    toSwipe = if possible then @swiped else @swiped * RESISTANCE
    target.vendor "transform", "translateX(#{toSwipe}px)"
    if possible
      otherTarget = Atoms.$(target[0][if @swiped > 0 then "previousSibling" else "nextSibling"])
      otherTarget.vendor "transform", "translateX(#{toSwipe}px)"

  _canGo: (is_next=true) ->
    !((@current_index is 0 and !is_next) or (@current_index is @num_childs - 1 and is_next))

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

    if transition is TRANSITION.CURRENT
      do @_resetPositions
      @index.setActive @current_index
      child.setAttribute(ATTRIBUTES.POSITION, TRANSITION.CURRENT)
      child.previousSibling?.setAttribute(ATTRIBUTES.POSITION, TRANSITION.PREVIOUS)
      if child.nextSibling?
        if child.nextSibling.className != "index"
          child.nextSibling.setAttribute(ATTRIBUTES.POSITION, TRANSITION.NEXT)
      @blocked = false

    if transition is "restoring" and child.getAttribute(ATTRIBUTES.POSITION) is TRANSITION.CURRENT
      @blocked = false

    child.removeAttribute(ATTRIBUTES.TRANSITION)


