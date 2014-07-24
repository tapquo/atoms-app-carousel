###
@TODO

@namespace Atoms.Molecule
@class Carousel

@author Javier Jimenez Villar <javi@tapquo.com> || @soyjavi
###
"use strict"

ATTRIBUTES =
  TRANSITION  : "data-carousel-transition"
  POSITION    : "data-carousel-position"

TRANSITION =
  PREVIOUS  : "previous"
  CURRENT   : "current"
  NEXT      : "next"
  RESTORE   : "restoring"


TRIGGER_PX = 120
RESISTANCE = 5


class Atoms.Molecule.Carousel extends Atoms.Class.Molecule

  @extends  : true

  @template : """<div {{#if.style}}class="{{style}}"{{/if.style}}></div>"""

  @available: ["Atom.Figure", "Atom.Image", "Atom.Video", "Molecule.Div"]

  @base     : "Form"

  @events   : ["swipe", "start", "change", "end"]

  constructor: ->
    super
    do @initialize
    if "swipe" in (@attributes.events or [])
      @el.bind "touchstart", @_onStart
      @el.bind "swiping", @_onSwiping
      @el.bind "touchend", @_onEnd
    @el.bind "webkitTransitionEnd", @_onTransitionEnd
    @el.bind "transitionend", @_onTransitionEnd

  clean: ->
    @destroyChildren()

  initialize: ->
    @index = new Atoms.App.Extension.Carousel.Index container: @el
    @children.unshift @index

    if @children.length > 1
      @_index = 1
      @_total_childs = @children.length - 1
      @blocked = false
      for child, index in @children when child.constructor.base isnt "index"
        transition = if index is 1 then TRANSITION.CURRENT else TRANSITION.NEXT
        child.el.attr ATTRIBUTES.POSITION, transition
        @index.add index, index is 1
    if @attributes.interval and @children.length > 2
      @_interval = setTimeout @next, @attributes.interval
    @bubble "start", {}

  next: =>
    if @_canMove(true)
      @_move next = true
      @blocked = true
    else if @attributes.interval and @_total_childs > 1
      @children[1].el.attr(ATTRIBUTES.POSITION, "next")
      @children[1].el.attr(ATTRIBUTES.TRANSITION, "current")
      @children[@_total_childs].el.attr(ATTRIBUTES.TRANSITION, "next")
      @_index = 1
      @bubble "end", {}

  previous: =>
    if @_canMove(false)
      @_move next = false
      @blocked = true

  _onStart: =>
    return if @blocked
    @swiped = 0

  _onSwiping: (event) =>
    if @swiped isnt null
      @swiped = event.touch.delta.x
      do @_handleSwipe
      clearTimeout @_interval if @attributes.interval
    event.originalEvent.preventDefault()
    event.stopPropagation()

  _onEnd: =>
    return if @swiped is null
    absPx = Math.abs(@swiped)
    if absPx > 0
      @blocked = true
      next = @swiped < 0
      if absPx > TRIGGER_PX and @_canMove(next) then @_move(next)
      else @_removeTransforms(true)
    @swiped = null

  _removeTransforms: (animate) ->
    _removeTransform(child.el[0]) for child in @children
    if animate
      @children[@_index].el.attr(ATTRIBUTES.TRANSITION, TRANSITION.RESTORE)
      other_index = if @swiped > 0 then @_index-1 else @_index+1
      @children[other_index]?.el.attr(ATTRIBUTES.TRANSITION, TRANSITION.RESTORE)

  _resetPositions: ->
    child.el.removeAttr(ATTRIBUTES.POSITION) for child in @children

  _handleSwipe: ->
    target = @children[@_index].el
    possible = @_canMove(@swiped < 0)
    toSwipe = if possible then @swiped else @swiped / RESISTANCE
    target.vendor "transform", "translateX(#{toSwipe}px)"
    if possible
      otherTarget = Atoms.$(target[0][if @swiped > 0 then "previousSibling" else "nextSibling"])
      otherTarget.vendor "transform", "translateX(#{toSwipe}px)"

  _canMove: (is_next=true) ->
    !((@_index is 1 and !is_next) or (@_index is @_total_childs and is_next) )

  _move: (next) ->
    if next
      direction = TRANSITION.NEXT
      future_index = @_index + 1
      @children[@_index - 1]?.el.removeAttr(ATTRIBUTES.POSITION)
    else
      direction = TRANSITION.PREVIOUS
      future_index = @_index - 1
      @children[@_index + 1]?.el.removeAttr(ATTRIBUTES.POSITION)

    @_removeTransforms(false)
    @children[@_index].el.attr(ATTRIBUTES.TRANSITION, direction)
    _removeTransform(@children[@_index].el[0])
    @children[future_index].el.attr(ATTRIBUTES.TRANSITION, TRANSITION.CURRENT)
    @_index = future_index
    @bubble "change", index: @_index

  _onTransitionEnd: (e) =>
    child = e.target
    transition = child.getAttribute(ATTRIBUTES.TRANSITION)
    position = child.getAttribute(ATTRIBUTES.POSITION)
    if transition is TRANSITION.CURRENT
      do @_resetPositions
      @index?.setActive @_index
      child.setAttribute(ATTRIBUTES.POSITION, TRANSITION.CURRENT)
      child.previousSibling?.setAttribute(ATTRIBUTES.POSITION, TRANSITION.PREVIOUS)
      if child.nextSibling?
        if child.nextSibling.className != "index"
          child.nextSibling.setAttribute(ATTRIBUTES.POSITION, TRANSITION.NEXT)

    clearTimeout @_interval if @attributes.interval
    if transition is TRANSITION.CURRENT or (transition is TRANSITION.RESTORE and position is TRANSITION.CURRENT)
      @blocked = false
      if @attributes.interval
        setTimeout (=> @_interval = setTimeout(@next, @attributes.interval)), 100

    child.removeAttribute(ATTRIBUTES.TRANSITION)

_removeTransform = (el) ->
  el.style.webkitTransform = ""
  el.style.MozTransform = ""
  el.style.transform = ""
