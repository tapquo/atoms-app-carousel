'use strict'

gulp    = require 'gulp'
coffee  = require 'gulp-coffee'
concat  = require 'gulp-concat'
connect = require 'gulp-connect'
header  = require 'gulp-header'
uglify  = require 'gulp-uglify'
gutil   = require 'gulp-util'
stylus  = require 'gulp-stylus'
pkg     = require './package.json'

source =
  coffee: [ "atom/*.coffee"
            "molecule/*.coffee"
            "organism/*.coffee"]
  stylus: [ "bower_components/stylmethods/vendor.styl"
            "style/*.styl"]
  test  : [ "test/atom/*.coffee"
            "test/molecule/*.coffee"
            "test/organism/*.coffee"
            "test/entity/*.coffee"
            "test/app.coffee"]

banner = [
  "/**"
  " * <%= pkg.name %> - <%= pkg.description %>"
  " * @version v<%= pkg.version %>"
  " * @link    <%= pkg.homepage %>"
  " * @author  <%= pkg.author.name %> (<%= pkg.author.site %>)"
  " * @license <%= pkg.license %>"
  " */"
  ""
].join("\n")

gulp.task "coffee", ->
  gulp.src source.coffee
    .pipe concat "#{pkg.name}.coffee"
    .pipe(coffee().on('error', gutil.log))
    .pipe uglify mangle: false
    .pipe header banner, pkg: pkg
    .pipe gulp.dest "."
    .pipe connect.reload()

gulp.task "stylus", ->
  gulp.src source.stylus
    .pipe concat "#{pkg.name}.styl"
    .pipe(stylus(compress: true, errors: true))
    .pipe header banner, pkg: pkg
    .pipe gulp.dest "."
    .pipe connect.reload()

gulp.task "init", ["coffee", "stylus"]

gulp.task "default", ->
  gulp.watch source.coffee, ["coffee"]
  gulp.watch source.stylus, ["stylus"]
