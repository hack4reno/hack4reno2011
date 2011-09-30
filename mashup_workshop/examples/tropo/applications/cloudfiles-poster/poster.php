<?php

$container_name = '';

// Some clients only send HTTP Auth credentials if the server 
// responds with a 401 and asks for them.
if (empty($_SERVER['PHP_AUTH_USER'])) {
    header('WWW-Authenticate: Basic realm="CloudFiles Poster"');
    header('HTTP/1.0 401 Unauthorized');
    exit;
}

// Uses kLogger from https://github.com/katzgrau/KLogger
require_once 'KLogger/src/KLogger.php';
$log = new KLogger (dirname(__FILE__), KLogger::INFO );

$container_name = empty($_GET['container']) ? $container_name : $_GET['container'];

if (empty($container_name)) {
  $log->LogError('Container name MUST be set.');
  die('Container name MUST be set.');
}


$log->LogInfo('Received ' . $_FILES['filename']['name']);

include 'php-cloudfiles/cloudfiles.php';

// Extract user and api key from the http auth
$username = $_SERVER['PHP_AUTH_USER'];
$api_key = $_SERVER['PHP_AUTH_PW'];

// If there's a ?name= query variable, use that as the file name
$filename = empty($_GET['name']) ? $_FILES['filename']['name'] : $_GET['name'];

// Authenticate with CloudFiles and create our file and container objects
$auth = new CF_Authentication($username, $api_key);
$auth->authenticate();
$conn = new CF_Connection($auth);
$container = $conn->create_container($container_name);
$file = $container->create_object($filename);

// Set the content-type
if (class_exists('finfo')) {
  // Use the PECL finfo to determine mime type
  $finfo = new finfo(FILEINFO_MIME);
  // Rename the file so we get the right extension
  move_uploaded_file($_FILES['filename']['tmp_name'], "/tmp/$filename");
  $file->content_type = $finfo->file("/tmp/$filename");
} else {
  // PECL extension not installed, so try and guess
  $file->content_type = guessmime($filename);
}

$size = (float) sprintf("%u", filesize($_FILES['filename']['tmp_name']));
$fp = fopen($_FILES['filename']['tmp_name'], "r");
$file->write($fp, $size);
$uri = $container->make_public();

$log->LogInfo('Published ' . $_FILES['filename']['name'] . ' to container $container_name at ' . $file->public_uri());

header('HTTP/1.1 202 Created');
header('Location: ' . $file->public_uri());

function guessmime($filename) {
  // an array of common file extensions and their mime types
  $mimes = array(
  '.ai' => 'application/postscript',
  '.aif' => 'audio/aiff',
  '.aifc' => 'audio/aiff',
  '.aiff' => 'audio/aiff',
  '.asp' => 'text/asp',
  '.asx' => 'video/x-ms-asf',
  '.au' => 'audio/basic',
  '.avi' => 'video/avi',
  '.bin' => 'application/octet-stream',
  '.bm' => 'image/bmp',
  '.bmp' => 'image/bmp',
  '.bz' => 'application/x-bzip',
  '.bz2' => 'application/x-bzip2',
  '.class' => 'application/java',
  '.com' => 'application/octet-stream',
  '.conf' => 'text/plain',
  '.css' => 'text/css',
  '.doc' => 'application/msword',
  '.dot' =>	'application/msword',
  '.eps' => 'application/postscript',
  '.exe' => 'application/octet-stream',
  '.gif' => 'image/gif',
  '.gz' => 'application/x-gzip',
  '.gzip' => 'application/x-gzip',
  '.hqx' => 'application/binhex',
  '.htm' => 'text/html',
  '.html' => 'text/html',
  '.htmls' => 'text/html',
  '.ico' => 'image/x-icon',
  '.java' => 'text/x-java-source',
  '.jfif' => 'image/jpeg',
  '.jpe' => 'image/jpeg',
  '.jpeg' => 'image/jpeg',
  '.jpg' => 'image/jpeg',
  '.m3u' => 'audio/x-mpequrl',
  '.mid' => 'audio/midi',
  '.mov' => 'video/quicktime',
  '.mp3' => 'audio/mpeg3',
  '.mpa' => 'audio/mpeg',
  '.mpeg' => 'video/mpeg',
  '.mpg' => 'video/mpeg',
  '.pdf' => 'application/pdf',
  '.pic' => 'image/pict',
  '.pict' => 'image/pict',
  '.png' => 'image/png',
  '.pot' => 'application/mspowerpoint',
  '.ppt' => 'application/mspowerpoint',
  '.ps' => 'application/postscript',
  '.qt' => 'video/quicktime',
  '.rtf' => 'application/rtf',
  '.swf' => 'application/x-shockwave-flash',
  '.tgz' => 'application/x-compressed',
  '.tif' => 'image/tiff',
  '.tiff' => 'image/tiff',
  '.txt' => 'text/plain',
  '.wav' => 'audio/wav',
  '.xls' => 'application/excel',
  '.xml' => 'text/xml',
  '.zip' => 'application/x-compressed'
  );
  
  $ext = '.' . end(explode(".",$filename));
  return $mimes[$ext];  
}
?>