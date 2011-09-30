<?php
// Set your CloudFiles username and password here
$user = '';
$apikey = '';


$ch = curl_init();
curl_setopt($ch, CURLOPT_USERPWD, "$user:$apikey");
curl_setopt($ch, CURLOPT_HEADER, 0);
curl_setopt($ch, CURLOPT_VERBOSE, 0);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_URL, str_replace('demo.php', 'poster.php', getself()) . '?container=demo');
curl_setopt($ch, CURLOPT_POST, true);

$post = array(
    "filename"=>'@' . dirname(__FILE__) . '/demo.jpg',
);
curl_setopt($ch, CURLOPT_POSTFIELDS, $post); 
$response = curl_exec($ch);
print_r($response);


function getself() {
  $pageURL = 'http';
  $url = ($_SERVER["HTTPS"] == "on") ? 'https' : 'http';
  $url .= "://" . $_SERVER["SERVER_NAME"];
  $url .= ($_SERVER["SERVER_PORT"] != "80") ? ':'. $_SERVER["SERVER_PORT"] : '';
  $url .= $_SERVER["REQUEST_URI"];
  return $url;
}
?>