class Atoms.Atom.CarouselIndex extends Atoms.Class.Atom

  @template: """
    <div class="index"></div>
  """

  add: (index, is_active=false) ->
    item = Atoms.$("<span data-carousel-index=\"#{index + 1}\">.</span>")
    if is_active then item.addClass "active"
    @el.append item

  reset: ->
    @el.html ""

  setActive: (index) ->
    elements = @el.find("[data-carousel-index]").removeClass("active")
    elements.filter("[data-carousel-index='#{index + 1}']").addClass("active")

