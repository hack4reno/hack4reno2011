CloudFiles Poster
==================

Take a file that's uploaded using a browser's file upload via HTTP POST and send it to your [RackSpace Cloud](http://www.rackspacecloud.com/) CloudFiles account. This application was developed as a tool to catch audio recordings uploads from [Tropo](http://tropo.com/)

Requirements
------------

 * PHP 5.3
 * [KLogger](https://github.com/katzgrau/KLogger) 
 * [PHP CloudFiles](https://github.com/rackspace/php-cloudfiles)
 * Recomended: [FileInfo PECL Extension](http://www.php.net/manual/en/book.fileinfo.php) for better MIME type detection

Installation
------------

Copy poster.php to a directory on your server. Copy the php-cloudfiles and KLogger directories to the same location as poster.php. To run the demo, also copy demo.jpg and demo.php to the same location.

Optionally set a default CloudFiles container by editing the `$container_name` variable in poster.php.

Usage
-----

POST a file to poster.php using your RackSpace Cloud's username and API Access Key as your Basic auth username and password, respectively. Optionally include the following query string variables:

 * name - the name you would like to store the file as, if different than the name of the file you're uploading
 * container - the CloudFiles container to store this file in. Will override the default container set in the script.

Demo
----

Copy demo.jpg and demo.php to the same location on your web server as poster.php. Add your CloudFiles username and API key to the top of the file. Open demo.php in your browser, then check your CloudFiles account. You'll have a new container in it called Demo and a copy of demo.jpg inside it.

The image used in the demo is King Cloud from http://www.flickr.com/photos/kky/704056791/ used under a Creative Commons license.