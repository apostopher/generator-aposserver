'use strict';
var util   = require('util');
var yeoman = require('yeoman-generator');
var fs     = require('fs');
var _      = require('lodash');


var RestGenerator = yeoman.generators.NamedBase.extend({
  init: function () {
    console.log('Hello! REST controller will be created for resource uri /' + this.name + '/*');
  },

  files: function () {
    this.copy('_RESTController.coffee', 'src/RESTController.coffee');
  },

  updateConfig: function (){
    var app_config = this.dest.readJSON('config/config.json');
    if (!_.isArray(app_config.resources)) {
      app_config.resources = [];
    };
    if (-1 === _.indexOf(app_config.resources, this.name)) {
      app_config.resources.push(this.name);
    };
    this.dest.write('config/config.json', JSON.stringify(app_config));
  }
});

module.exports = RestGenerator;