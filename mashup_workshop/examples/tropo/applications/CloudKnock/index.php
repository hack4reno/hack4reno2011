<?php

// The details of your CouchDB instance.
define("COUCH_DB_HOST", "");
define("COUCH_DB_PORT", "");
define("COUCH_DB_NAME", "");

// Current call properties
$channel = $currentCall->channel;
$network = $currentCall->network;
$callerID = $currentCall->callerID;

// A variable to hold the name of the user (sent with knocks).
$userName;

// Check to ensure the user is valid.
if(!validateUser($userName, $callerID, $network)) {
	_log("*** Invalid user: $callerID on $channel / $network ***");
	hangup();
}

else {
	_log("*** Validated user $callerID ***");

	// Handle incoming telephone calls.
	if($channel == 'VOICE') {
		say(".");
		$result = ask("Check in, check out or knock knock?", array("choices" => "check in(in, 1), check out(out, 2), knock knock(knock, 3)", "attempts" => "3", "timeout" => "10.0"));
		$message = $result->value;
	}

	// Handle incoming messages on text channel.
	else {
		$message = strtolower($currentCall->initialText);
	}

	switch($message) {

		// User is checking in.
		case 'check in':
			if(checkIn($callerID, $channel, $network)) {
				say('You have been checked in to Cloud knock.');
			}
			else {
				say('Could not check you in. Do you need to check out?');
			}
			break;

			// User is checking out.
		case 'check out':
			if(checkOut($callerID)) {
				say('You have been checked out of Cloud knock.');
			}
			else {
				say('Could not check you out. Do you need to check in?');
			}
			break;

			// Somebody's knocking on the door, somebody's rining the bell...
		case 'knock knock':
			if(knockKnock($userName, $callerID)) {
				say('OK. knocks sent.');
			}
			else {
				say('No one checked in. :-(');
			}
			break;

		default:
			say('Sorry, I did not understand.');
	}

	hangup();

}


// Send a message to all users.
function knockKnock($userName, $callerID) {

	$user_list = getUserList();
	$users = json_decode($user_list);
	if(count($users->rows) == 0) {
		return false;
	}
	else {

		foreach($users->rows as $user) {

			$channel = $user->value->channel;
			$network = $user->value->network;
			$name = $user->value->name;
			$address = $user->key;
			
			$msg = "$userName is outside knocking, please let them in.";

			if($channel == 'VOICE') {
				$address = 'tel:+1'.$address;
			}
				message($msg, array("to" => $address, "network" => $network));	

		}
		return true;

	}
}

// Get all checked in users.
function getUserList() {

	$url = COUCH_DB_HOST.":".COUCH_DB_PORT."/".COUCH_DB_NAME."/_design/users/_view/checkedin";
	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_HTTPGET, true);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	$result = curl_exec($ch);
	curl_close($ch);
	return $result;

}

// Check a user in.
function checkIn($callerID, $channel, $network) {

	$url = COUCH_DB_HOST.":".COUCH_DB_PORT."/".COUCH_DB_NAME."/".$callerID;
	$doc = json_encode(array("channel" => $channel, "network" => $network));
	$putData = tmpfile();
	fwrite($putData, $doc);
	fseek($putData, 0);

	$ch = curl_init($url);
	curl_setopt($ch, CURLOPT_PUT, true);
	curl_setopt($ch, CURLOPT_INFILE, $putData);
	curl_setopt($ch, CURLOPT_INFILESIZE, strlen($doc));
	curl_exec($ch);
	$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
	curl_close($ch);

	if ($code != '201') {
		return false;
	}
	return true;

}

// Check a user out.
function checkOut($callerID) {

	$url = COUCH_DB_HOST.":".COUCH_DB_PORT."/".COUCH_DB_NAME."/".$callerID;

	$ch = curl_init($url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	$user = json_decode(curl_exec($ch));

	$url .= '?rev='.$user->_rev;

	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'DELETE');
	curl_exec($ch);
	$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
	curl_close($ch);

	if ($code != '200') {
		return false;
	}
	return true;

}

// Validate a user.
function validateUser(&$userName, $callerID, $network) {

	$url = COUCH_DB_HOST.":".COUCH_DB_PORT."/".COUCH_DB_NAME."/_design/channel/_view/".strtolower($network);
	$ch = curl_init($url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
	$result = curl_exec($ch);
	curl_close($ch);

	if(!result) {
		return false;
	}
	else {
		$user_list = json_decode($result);
		foreach($user_list->rows as $user) {
			if($user->value->address == $callerID) {
				$userName = $user->value->name;
				return true;
			}
		}
		return false;
	}

}
?>