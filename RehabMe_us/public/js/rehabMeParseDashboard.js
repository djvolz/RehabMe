$( document ).ready(function() {

	// Parse credentials (App Id, JavaScript key)
	var AppId 		  = "jix4a7ziO3LTyuL4PZ3IyyRUA7DmnwRO0zvka2z5";
	var JavaScriptKey = "YjcdhUmLeR4w43lx7lYyCmKJZXCXaiZDVADzSCJk";

	// Parse credentials (App Id, JavaScript key)
	Parse.initialize( AppId, JavaScriptKey );


	// Parse object
	var ExerciseObject = Parse.Object.extend( "ExerciseObject" );
	// Query
	var query = new Parse.Query( ExerciseObject );
	// order by
	query.descending( "createdAt" );
	// limit how many entries you would like to query
	query.limit( 5 );

	// you can filter the data (all entries where skipped is CalfRaises)
	//query.equalTo( "skipped", "CalfRaises" );

	// Data we are creating for the table
	var myExercises = '';
	// Actual pending-words finding function
	query.find( {

		success: function( results ) {
			for ( var i = 0; i < results.length; i++ ) {
			  var object = results[ i ];

			  myExercises +=
					'<tr><td id="dateCol">' +
							object[ 'createdAt' ] +
					// Performed
					'<td id="wordCol">' +
							object.get( 'performed' ) +
			  		// Skipped
					'</td><td id="defCol">' +
					  		object.get( 'skipped' )  +
					'</td></tr>'
				}

			  (function( $ ) {
			      // If we did not get results, then say so on the table
			      if( myExercises == '' ) {
			      	var noResults = undefined;
			        	noResults = "<tr><td>No entries</td></tr>";
			        // append it to the empty row
				    $( '#wordData' ).html( noResults );
				  } else {
				  	// Add our found words/defs with the searched-for status
				  	$( '#wordData' ).html( myExercises );
				  }
			  })( jQuery );
		},
	    // Handle errors
	    error: function( error ) {
	        console.log( "Error: " + error.code + " " + error.message );
	    }
   });
});
