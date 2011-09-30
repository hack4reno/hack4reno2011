Drupal as an Application Development Framework
==============================================

Drupal isn't a content management system. It's an application development platform that happens to ship with a great CMS as it's default implementation. Look at any chart comparing features of development frameworks and you'll see user management and authentication, forms management and validation, data storage, database migrations, internationalization and translation, MVC model with flexible templating, unit testing, and caching. Sounds a lot like Drupal. We'll look at why Drupal is an ideal application development platform for apps beyond content management, talk about where Drupal can improve in these areas, and look at an example application.

This module is a demonstration of using Drupal to power a web application. It uses [Tropo](http://tropo.com/) to accept a phone call, convert a sentance to speech, then uses the Google Translate API to translate that sentance into several languages, playing each one. Finally, it asks a question, saves your response as a node, and sends a text message.

Requirements
------------

 * Drupal 7
 * [Tropo Library for PHP](http://github.com/tropo/tropo-webapi-php)

Installation
-------------

 1. Upload this module to where ever you place your Drupal modules. Don't have a regular location? I suggest /sites/all/modules/
 2. Get the [Tropo Library for PHP](http://github.com/tropo/tropo-webapi-php) and place the tropo-webapi-php directory inside this module's directory.
 3. Activate the module inside of Drupal
 4. Visit admin/frameworkdemo if you want to override any strings that the module outputs.
