<?php

/*
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

answer();

wait(750);	// let's wait a bit until the call is actually fully answered

$callerID = $currentCall->callerID;	// the current caller ID
$myNumber = '15555555555';	// your phone number - must include the country code
$pinLength = 6;	// how many digits long you want your pin to be
$myPin = '123456';	// must be $pinLength digits
$pinAttempts = 0;	// initialize this to 0

// we'll do something different for VOICE and then SMS and IM
if($currentCall->channel == "VOICE") {
	switch($callerID) {
		// check to see if the person calling is in the same area code as you
		// since it might be you and you might want to use the access number
		// from a number other than yours
		case strpos($callerID, '555') === 0:
			// prompt the caller for the pin number
			promptPin();
			
			// set $callerID so that it looks like you're calling from your phone
			if(strpos($myNumber, $callerID) !== false) {
				$callerID = $myNumber;
			}
			
			// give them a directory of number to call
			callOptions();
			break;
			
		// if the call is coming from a different area code, just forward the call
		// to your phone
		default:
			forwardCall($myNumber);
			break;
	}
} else {
	// if someone is texting your Tropo number, forward it to your phone
	if($callerID != $myNumber) {
		forwardText($callerID, $currentCall->initialText);
	
	// otherwise, you're the one texting your Tropo number, so just send back a friendly Hello. :) 
	} else {
		say("Hello - you just sent a text/IM!");
	}
}

say("Goodbye!");
hangup();

function forwardText($callerID, $text) {
	global $myNumber;
	
	// takes the sender's caller ID, prepends it to the message, and forwards the text to you
	message($callerID . ' - ' . $text, array(
		'to'	=>	'tel:+'.$myNumber,
		'network'	=>	'SMS'
	));
}

function forwardCall($numberToCall) {
	global $callerID;
	
	say("Calling.");
	
	// transfer the call to the number we passed in using the caller ID we set
	transfer("tel:+".$numberToCall, array(
		"callerID" => $callerID,
		"playvalue"=>"http://themes.stumpnet.net/Jeopardy%20(Think%20Song).mp3",	// this is the jeopardy think song
		"terminator"=>"#",	// at any point before the call is answered, you may press pound to end it
		"onTimeout"=>"timeoutFCN"
	));
	
	// at this point, the call has ended
	wait(500);	
	say("Call ended.");
	wait(500);
}

// timeout if we can't forward the call
function timeoutFCN($event) {
	say("Sorry, but nobody answered.");
}

function callOptions() {
	// ask the caller who they want to call
	$result = ask("To call: Home, press 1. To call a specific number, press 2. To end this call, press star.", array(
		"choices"	=> "1, 2, *",
		"repeat"	=> 3	// repeat the prompts 3 times
	));
	
	if($result->name == 'choice') {
		switch($result->value) {
			case '1':
				forwardCall('14155555555');
				break;
			case '2':
				$call = ask("Please enter the 10 digit number you would like to call, starting with the area code!", array(
					"choices" => "[10 DIGITS]",
					"repeat" => 3
				));
				
				if($call->name == 'choice') {
					forwardCall('1'.$call->value);
				} else {
					say("Sorry, I didn't get that.");
				}				
				break;
			case '*':
				return;
		}
	}
	
	// recursively call this function now until the user gets hung up on or until they hang up
	callOptions();
	return;
}

function promptPin() {
	global $pinLength;	

	// prompt the user for their pin number, followed by the pound key
	$result_pin = ask("Please enter your pin number, then press pound to continue.", array(
		"choices"=>"[".$pinLength." DIGITS]",
		"terminator" => "#",
		"timeout" => 15.0
		)
	);

	// verify it
	verifyPin($result_pin->value);
}

function verifyPin($pin) {
	global $myPin;
	global $pinAttempts;
	
	++$pinAttempts;
	
	// we'll tell the caller they got the pin number wrong
	if($pin != $myPin) {
		say("You did not enter the correct pin!");
		
		// if we reach 3 attempts, hang up on the caller
		if($pinAttempts == 3) {
			say("Goodbye!");
			hangup();
			exit;
		}
		
		// keep prompting until the 3rd attempt
		promptPin();
	}
}

?>