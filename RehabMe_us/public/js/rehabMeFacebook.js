
// Parse App Id and JavaScript Key
var AppId         = "jix4a7ziO3LTyuL4PZ3IyyRUA7DmnwRO0zvka2z5";
var JavaScriptKey = "YjcdhUmLeR4w43lx7lYyCmKJZXCXaiZDVADzSCJk";

// Facebook appId
var facebookId = "1552401785022460";

Parse.initialize( AppId, JavaScriptKey );


// Facebook functions
window.fbAsyncInit = function() {
  Parse.FacebookUtils.init({
    appId      : facebookId, // Facebook App ID
    status     : false,      // Check Facebook Login status
    cookie     : true,       // Enable cookies to allow Parse to access the session
    xfbml      : true,       // Initialize Facebook social plugins on the page
    version    : 'v2.2'      // Point to the latest Facebook Graph API version
  });
};

(function(d, s, id){
   var js, fjs = d.getElementsByTagName(s)[0];
   if (d.getElementById(id)) {return;}
   js = d.createElement(s); js.id = id;
   js.src = "//connect.facebook.net/en_US/all.js";
   fjs.parentNode.insertBefore(js, fjs);
 }(document, 'script', 'facebook-jssdk'));
