'use strict';
var util = require('util');
var path = require('path');
var yeoman = require('yeoman-generator');
var yosay = require('yosay');
var chalk = require('chalk');


var AposserverGenerator = yeoman.generators.Base.extend({

  constructor: function () {
    yeoman.generators.Base.apply(this, arguments);
    this.config.save();
  },

  init: function () {
    this.pkg = require('../package.json');

    this.on('end', function () {
      this.npmInstall();
    });
  },

  askFor: function () {
    var done = this.async();

    // Have Yeoman greet the user.
    this.log(yosay('Welcome to the marvelous Aposserver generator!'));

    var prompts = [{
      type: 'input',
      name: 'server_name',
      message: 'What would you like to call your server?',
      default: this.appname
    },
    {
      type: 'confirm',
      name: 'mongodb_support',
      message: 'Do you want me to include mongodb support?',
      default: true
    },
    {
      type: 'confirm',
      name: 'socketio_support',
      message: 'Do you want me to include socket.io support?',
      default: false
    },
    {
      type: 'confirm',
      name: 'nginx_support',
      message: 'Do you want me to generate nginx and upstart config?',
      default: true
    }];

    this.prompt(prompts, function (props) {
      var self = this;
      this.user_settings = {}
      this.user_settings.server_name = this._.capitalize(this._.camelize(props.server_name));
      this.user_settings.needs_mongodb = props.mongodb_support;
      this.user_settings.needs_socketio = props.socketio_support;
      if (props.nginx_support) {
        var prompts = [{
          type: 'input',
          name: 'nginx_ports',
          message: "What ports do you want '" + this.user_settings.server_name + "' to listen on?",
          default: "9090"
        }];
        this.prompt(prompts, function (nginx_props){
          self.user_settings.nginx_settings = {
            nginx_app: self.user_settings.server_name.toLowerCase(),
            ports: self._getPortsRange(nginx_props.nginx_ports),
            root: process.cwd()
          };
          done();
        });
      }else{
        done();
      };
    }.bind(this));
  },

  app: function () {
    this.mkdir('src');
    this.mkdir('config');
    this.mkdir('test');
    this.mkdir('test/src');

    this.copy('_Cakefile', 'Cakefile');
    this.copy('gitignore', '.gitignore');

    this.template('_package.json', 'package.json', this.user_settings);
    this.template('_npm-shrinkwrap.json', 'npm-shrinkwrap.json', this.user_settings);
    this.template('_index.html', 'index.html', this.user_settings);


    if (this.user_settings.needs_mongodb) {
      this.template('_index_with_mongo.coffee', 'src/index.coffee', this.user_settings);
    } else{
      this.template('_index.coffee', 'src/index.coffee', this.user_settings);
    };
    
    if (this.user_settings.nginx_settings) {
      var nginx_app_name = this.user_settings.nginx_settings.nginx_app;
      this.template('_nginx.conf', 'nginx.conf', this.user_settings.nginx_settings);
      this.template('_config.json', 'config/config.json', this.user_settings.nginx_settings);
      if (this.user_settings.nginx_settings.ports.length > 1) {
        this.template('_upstart-master.conf',  nginx_app_name + '-master.conf', this.user_settings.nginx_settings);
        this.template('_upstart.conf', nginx_app_name + '.conf', this.user_settings.nginx_settings);
      }else{
        this.template('_upstart-single.conf', nginx_app_name + '.conf', this.user_settings.nginx_settings);
      };
      
    };
  },

  projectfiles: function () {
    this.copy('editorconfig', '.editorconfig');
    this.copy('jshintrc', '.jshintrc');
  },

  _getPortsRange: function (ports_config){
    var ports_range = ports_config.split("-");
    var start = +ports_range[0];
    if (ports_range.length === 1) {
      return [start];
    };
    var end = +ports_range[1];
    var num_of_ports = end - start
    if(num_of_ports < 0){
      return [start];
    }
    var ports = [];
    while(start <= end){
      ports.push(start);
      start += 1;
    }
    return ports;
  }
});

module.exports = AposserverGenerator;
