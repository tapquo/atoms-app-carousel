Atoms.App.Extension.Carousel = {}

class Atoms.App.Extension.Carousel.Index extends Atoms.Class.Atom

  @template: "<div></div>"

  @base: "index"

  constructor: (attributes = {})->
    attributes.method = "prepend"
    super attributes

  add: (index, active=false) ->
    child = Atoms.$ """<span data-index="#{index + 1}"></span>"""
    if active then child.addClass "active"
    @el.append child

  setActive: (index) ->
    @el.find("[data-index]")
      .removeClass("active")
      .filter("[data-index='#{index + 1}']").addClass("active")

