<?php

/*
 * User class.
 * Use this class to add new users to the CloudKnock database
 */
class User {

	private $_aim;
	private $_gtalk;
	private $_jabber;
	private $_msn;
	private $_name;
	private $_pstn;
	private $_sip;
	private $_sms;
	private $_yahoo;
	
	/**
	 * 
	 * Class constructor
	 * @param string $aim
	 * @param string $gtalk
	 * @param string $jabber
	 * @param string $msn
	 * @param string $pstn
	 * @param string $sip
	 * @param string $sms
	 * @param string $yahoo
	 */
	public function __construct($aim=NULL, $gtalk=NULL, $jabber=NULL, $msn=NULL, $pstn=NULL, $sip=NULL, $sms=NULL, $yahoo=NULL){
		$this->_aim = $aim;
		$this->_gtalk = $gtalk;
		$this->_jabber = $jabber;
		$this->_msn = $msn;
		$this->_pstn = $pstn;
		$this->_sip = $sip;
		$this->_sms = $sms;
		$this->_yahoo = $yahoo;

	}

	/**
	 * Set the name of the CloudKnock user
	 * @param string $name
	 */
	public function setName($name) {
		$this->_name = $name;
	}

	/**
	 * Render the JSON for inserting into CouchDB
	 */
	public function __toString() {
		
		if(!isset($this->_name)) {
			die('You must set a user name.');
		}
		
		$this->type = "user";
		$this->aim = isset($this->_aim) ? $this->_aim : null;
		$this->gtalk = isset($this->_gtalk) ? $this->_gtalk : null;
		$this->jabber = isset($this->_jabber) ? $this->_jabber : null;
		$this->msn = isset($this->_msn) ? $this->_msn : null;
		$this->name = isset($this->_name) ? $this->_name : null;
		$this->pstn = isset($this->_pstn) ? $this->_pstn : null;
		$this->sip = isset($this->_sip) ? $this->_sip : null;
		$this->sms = isset($this->_sms) ? $this->_sms : null;
		$this->yahoo = isset($this->_yahoo) ? $this->_yahoo : null;	
			
		return json_encode($this);
	}

	/**
	 * Override method
	 * @param string $attribute
	 * @param string $value
	 */
	public function __set($attribute, $value) {
		$this->$attribute= $value;
	}

}

?>