﻿component{

	/**
	* index
	*/
	function index( event, rc, prc ){
		prc.welcomeMessage = "Welcome to ColdBox!";
		event.setView( "Main/index" );
	}

}
