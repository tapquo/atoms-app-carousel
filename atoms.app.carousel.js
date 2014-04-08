/* atoms v0.04.08
   http://atoms.tapquo.com
   Copyright (c) 2014 Tapquo S.L. - Licensed MIT */
(function(){var ATTRIBUTES,AUTO_INTERVAL,RESISTANCE,TRANSITION,TRIGGER_PX,_removeTransform,__hasProp={}.hasOwnProperty,__extends=function(child,parent){function ctor(){this.constructor=child}for(var key in parent)__hasProp.call(parent,key)&&(child[key]=parent[key]);return ctor.prototype=parent.prototype,child.prototype=new ctor,child.__super__=parent.prototype,child},__bind=function(fn,me){return function(){return fn.apply(me,arguments)}};Atoms.App.Extension.Carousel={},Atoms.App.Extension.Carousel.Index=function(_super){function Index(attributes){null==attributes&&(attributes={}),attributes.method="prepend",Index.__super__.constructor.call(this,attributes)}return __extends(Index,_super),Index.template="<div></div>",Index.base="index",Index.prototype.add=function(index,active){var child;return null==active&&(active=!1),child=Atoms.$('<span data-index="'+(index+1)+'"></span>'),active&&child.addClass("active"),this.el.append(child)},Index.prototype.reset=function(){return this.el.html("")},Index.prototype.setActive=function(index){return this.el.find("[data-index]").removeClass("active").filter("[data-index='"+(index+1)+"']").addClass("active")},Index}(Atoms.Class.Atom),ATTRIBUTES={TRANSITION:"data-carousel-transition",POSITION:"data-carousel-position"},TRANSITION={PREVIOUS:"previous",CURRENT:"current",NEXT:"next",RESTORE:"restoring"},TRIGGER_PX=120,AUTO_INTERVAL=3e3,RESISTANCE=4,Atoms.Molecule.Carousel=function(_super){function Carousel(){this._onTransitionEnd=__bind(this._onTransitionEnd,this),this._onEnd=__bind(this._onEnd,this),this._onSwiping=__bind(this._onSwiping,this),this._onStart=__bind(this._onStart,this),this.previous=__bind(this.previous,this),this.next=__bind(this.next,this),Carousel.__super__.constructor.apply(this,arguments),this.index=new Atoms.App.Extension.Carousel.Index({container:this.el}),this.children.unshift(this.index),this.attributes.auto&&(this.auto_interval=setTimeout(this.next,AUTO_INTERVAL)),this.initialize(),this.el.bind("touchstart",this._onStart).bind("swiping",this._onSwiping).bind("touchend",this._onEnd).bind("webkitTransitionEnd",this._onTransitionEnd)}return __extends(Carousel,_super),Carousel.template='<div {{#if.style}}class="{{style}}"{{/if.style}}></div>',Carousel.available=["Atom.Figure","Atom.Image","Atom.Video","Atom.Audio"],Carousel.base="Form",Carousel.prototype.initialize=function(){var child,index,transition,_i,_len,_ref,_ref1,_ref2,_results;for(console.log("children",this.children.length,this.children),null!=(_ref=this.index)&&_ref.reset(),this.current_index=1,this.num_childs=this.children.length-1,this.blocked=!1,_ref1=this.children,_results=[],index=_i=0,_len=_ref1.length;_len>_i;index=++_i)child=_ref1[index],"index"!==child.constructor.base&&(transition=1===index?TRANSITION.CURRENT:TRANSITION.NEXT,child.el.attr(ATTRIBUTES.POSITION,transition),_results.push(null!=(_ref2=this.index)?_ref2.add(index,1===index):void 0));return _results},Carousel.prototype.next=function(){return this._canGo(!0)?(this._go(!0),this.blocked=!0):this.attributes.auto?(this.children[1].el.attr(ATTRIBUTES.POSITION,"next"),this.children[1].el.attr(ATTRIBUTES.TRANSITION,"current"),this.children[this.num_childs].el.attr(ATTRIBUTES.TRANSITION,"next"),this.current_index=1):void 0},Carousel.prototype.previous=function(){return this._canGo(!1)?(this._go(!1),this.blocked=!0):void 0},Carousel.prototype._onStart=function(){return this.blocked?void 0:this.swiped=0},Carousel.prototype._onSwiping=function(evt){return null!==this.swiped&&(this.swiped=evt.quoData.delta.x,this._handleSwipe(),this.attributes.auto&&clearTimeout(this.auto_interval)),evt.originalEvent.preventDefault(),evt.stopPropagation()},Carousel.prototype._onEnd=function(){var absPx,is_next;if(null!==this.swiped)return absPx=Math.abs(this.swiped),absPx>0&&(this.blocked=!0,is_next=this.swiped<0,absPx>TRIGGER_PX&&this._canGo(is_next)?this._go(is_next):this._removeTransforms(!0)),this.swiped=null},Carousel.prototype._removeTransforms=function(animate){var child,other_index,_i,_len,_ref,_ref1;for(_ref=this.children,_i=0,_len=_ref.length;_len>_i;_i++)child=_ref[_i],_removeTransform(child.el[0]);return animate?(this.children[this.current_index].el.attr(ATTRIBUTES.TRANSITION,TRANSITION.RESTORE),other_index=this.swiped>0?this.current_index-1:this.current_index+1,null!=(_ref1=this.children[other_index])?_ref1.el.attr(ATTRIBUTES.TRANSITION,TRANSITION.RESTORE):void 0):void 0},Carousel.prototype._resetPositions=function(){var child,_i,_len,_ref,_results;for(_ref=this.children,_results=[],_i=0,_len=_ref.length;_len>_i;_i++)child=_ref[_i],_results.push(child.el.removeAttr(ATTRIBUTES.POSITION));return _results},Carousel.prototype._handleSwipe=function(){var otherTarget,possible,target,toSwipe;return target=this.children[this.current_index].el,possible=this._canGo(this.swiped<0),toSwipe=possible?this.swiped:this.swiped/(RESISTANCE+1),target.vendor("transform","translateX("+toSwipe+"px)"),possible?(otherTarget=Atoms.$(target[0][this.swiped>0?"previousSibling":"nextSibling"]),otherTarget.vendor("transform","translateX("+toSwipe+"px)")):void 0},Carousel.prototype._canGo=function(is_next){return null==is_next&&(is_next=!0),!(1===this.current_index&&!is_next||this.current_index===this.num_childs&&is_next)},Carousel.prototype._go=function(is_next){var direction,future_index,_ref,_ref1;return is_next?(direction=TRANSITION.NEXT,future_index=this.current_index+1,null!=(_ref=this.children[this.current_index-1])&&_ref.el.removeAttr(ATTRIBUTES.POSITION)):(direction=TRANSITION.PREVIOUS,future_index=this.current_index-1,null!=(_ref1=this.children[this.current_index+1])&&_ref1.el.removeAttr(ATTRIBUTES.POSITION)),this._removeTransforms(!1),this.children[this.current_index].el.attr(ATTRIBUTES.TRANSITION,direction),_removeTransform(this.children[this.current_index].el[0]),this.children[future_index].el.attr(ATTRIBUTES.TRANSITION,TRANSITION.CURRENT),this.current_index=future_index},Carousel.prototype._onTransitionEnd=function(e){var child,position,transition,_ref,_ref1,_this=this;return child=e.target,transition=child.getAttribute(ATTRIBUTES.TRANSITION),position=child.getAttribute(ATTRIBUTES.POSITION),transition===TRANSITION.CURRENT&&(this._resetPositions(),null!=(_ref=this.index)&&_ref.setActive(this.current_index),child.setAttribute(ATTRIBUTES.POSITION,TRANSITION.CURRENT),null!=(_ref1=child.previousSibling)&&_ref1.setAttribute(ATTRIBUTES.POSITION,TRANSITION.PREVIOUS),null!=child.nextSibling&&"index"!==child.nextSibling.className&&child.nextSibling.setAttribute(ATTRIBUTES.POSITION,TRANSITION.NEXT)),this.attributes.auto&&clearTimeout(this.auto_interval),(transition===TRANSITION.CURRENT||transition===TRANSITION.RESTORE&&position===TRANSITION.CURRENT)&&(this.blocked=!1,this.attributes.auto&&setTimeout(function(){return _this.auto_interval=setTimeout(_this.next,AUTO_INTERVAL)},100)),child.removeAttribute(ATTRIBUTES.TRANSITION)},Carousel}(Atoms.Class.Molecule),_removeTransform=function(el){return el.style.webkitTransform="",el.style.MozTransform="",el.style.transform=""}}).call(this);