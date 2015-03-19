$( document ).ready(function() {

	// App Id and JavaScript Key
	var AppId 		  = "jix4a7ziO3LTyuL4PZ3IyyRUA7DmnwRO0zvka2z5";
	var JavaScriptKey = "YjcdhUmLeR4w43lx7lYyCmKJZXCXaiZDVADzSCJk";

	// Parse credentials (App Id, JavaScript key)
	Parse.initialize( AppId, JavaScriptKey );


	// Register an account
	$( "#registerButton" ).click(function( e ) {

		// Disallow regular behavior of form
	    e.preventDefault();

	    // Parse user object
	    var user = new Parse.User();

	    // Grab user input
	    var username = $( "#signup-username" ).val();
	    var password = $( "#signup-password" ).val();
	    var email 	 = $( "#signup-email" ).val();
		var errorDiv = $( ".registerError" )[0];

		if( username.length > 0 && password.length > 0 && email.length > 0 ) {
			// Set Parse object fields
		    user.set( "username", username );
			user.set( "password", password );
			user.set( "email",    email );

		    user.signUp(null, {
		        success: function( user ) {
			        var currentUser = Parse.User.current();
		        	// Redirect to a "logged in only" page
		        	if( currentUser ) {
						window.location="dashboard";
					}
			     },
			    error: function( user, error ) {
				 	var theError = "Error: " + error.message;
				 	errorDiv.style.visibility = "visible";
				 	errorDiv.innerHTML = theError;
				}
			});
		}
	});


	// Register with Facebook
	$( "#facebookButton" ).click(function( e ) {

		// Disallow regular behavior of form
	    e.preventDefault();

		Parse.FacebookUtils.logIn(null, {
			success: function(user) {
				FB.api(
					"/me",
					function (response) {
					  if ( response && !response.error ) {
					    var name  = response.first_name + response.last_name;
					    var email = response.email;						// not working yet... need more permissions

					    Parse.User.current().set( "username", name  );
					    Parse.User.current().set( "email",    email );  // not working yet... need more permissions
					    Parse.User.current().save();
					  }
					}
				);

				var currentUser = Parse.User.current();
		        // Redirect to a "logged in only" page
	        	if( currentUser ) {
					window.location="dashboard";
				}
			},
			error: function(user, error) {
				var errorDiv = $( ".registerError" )[0];
				 	errorDiv.style.visibility = "visible";
				 	errorDiv.innerHTML = "Error: " + error.code + " " + error.message;
			}
		});
	});


	// Login to account
	$( "#loginButton" ).click(function( e ) {

		// Disallow regular behavior of form
	    e.preventDefault();

		var username = $( "#login-username" ).val();
		var password = $( "#login-password" ).val();
		var errorDiv = $( ".loginError" )[0];

		if( username.length > 0 && password.length > 0 && username != " " && password != " ") {
			Parse.User.logIn(username, password, {
				success: function( user ) {
					var currentUser = Parse.User.current();
					// Redirect to a "logged in only" page
					if( currentUser ) {
						window.location="dashboard";
					}
				},
				 error: function( user, error ) {
				 	var theError = "Error: " + error.message;
				 	errorDiv.style.visibility = "visible";
				 	errorDiv.innerHTML = theError;
		 		}
			});
		}
	});
});
