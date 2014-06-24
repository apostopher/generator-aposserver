#!/usr/bin/env node

"use strict"

require('shelljs/global');

if (require.main === module) {
  // STEP 1: copy nginx file to /etc/nginx/sites-available/
  var nginx_conf = "/etc/nginx/sites-available/<%= nginx_app %>";
  console.log("Copying nginx configuration...");
  cp('-f', './nginx.conf', nginx_conf);

  // STEP 2: create a softlink in /etc/nginx/sites-enabled/
  console.log("Creating nginx symlink...");
  ln('-sf', nginx_conf, '/etc/nginx/sites-enabled/<%= nginx_app %>');

  // STEP 3: restart nginx
  console.log("restarting nginx...");
  exec('service nginx stop', {async:false});
  exec('service nginx start', {async:false});

  // STEP 4: copy monit config to /etc/init/
  console.log("Copying upstart configuration...");
  var upstart_conf = "<%= nginx_app %>.conf";
  cp('-f', './' + upstart_conf, '/etc/init/' + upstart_conf);
  <% if (ports.length > 1) { %>
  var upstart_master_conf = "<%= nginx_app %>-master.conf";
  cp('-f', './' + upstart_master_conf, '/etc/init/' + upstart_master_conf);
  <% }; %>

  console.log("Installed!");
};

