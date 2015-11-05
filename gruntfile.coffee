# gruntfile.coffee
#
# @author Abe Fehr
#
module.exports = (grunt) ->

  # Necessary "includes"
  grunt.loadNpmTasks "grunt-jasmine-node-coffee"

  # Task declarations
  grunt.initConfig

    jasmine_node:
      extensions: "coffee"

  # Task registration
  grunt.registerTask "test", ["jasmine_node"]
  grunt.registerTask "default", ->
    grunt.task.run ["test"]