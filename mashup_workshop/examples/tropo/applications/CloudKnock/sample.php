<?php

/*
 * A sample script illustrating one way to insert a user into the 
 *  CloudKnock database
 */

require 'classes/user.php';
require 'path/to/Sag.php';

$user = new User(null, null, null, null, "5551112222", null, "15551112222", null);
$user->setName("Your Name");

$sag = new Sag('your-db.couchone.com', '5984');
$sag->setDatabase('cloudknock');
$sag->post(sprintf($user));

?>