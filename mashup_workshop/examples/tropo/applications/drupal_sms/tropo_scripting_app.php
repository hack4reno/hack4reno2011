<?php
// Function that's used for incoming messages. Sends the session information to drupal
function sendToDrupal(&$ch, $postData) {
	$url = "http://marksilver.net/drupaldev/617/?q=sms/tropo/receive/";
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_POST, true);
	curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);				 
	curl_exec($ch);
	if (curl_getinfo($ch, CURLINFO_HTTP_CODE) != '200') { return false; }
	return true;
}

if ($action == 'create' ) {
	$options = array('channel' => $channel, 'network' => $network);
	call($to, $options);
	say($message);
	hangup();
}
else{
	$ch = curl_init();
	answer();
	if ($currentCall->channel == "TEXT") {
		$postData = json_encode($currentCall);
		if (sendToDrupal($ch, $postData)) { say("I've passed your information along to Drupal. Thank you.");}
		else {say("Something went wrong and I wasn't able to send your message to Drupal. Please try again and/or contact your Drupal administrator.");}		
	}
	else {
		say("Sorry, Drupal cannot currently receive phone calls. Try text messaging this phone number or contact your Drupal administrator.")
	}
	curl_close($ch);
	hangup();
}

?>