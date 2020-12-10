###Cannot Login - No Token
    When you try to login to concourse url it goes to
    a blank screen and says invalid token.
    
    * You need to run fly -t tutorial login -c http://localhost:8080 -u test -p test
    which will put a token on the machine you run it on.
    
    * If you get a blank screen with invalid session token you need to delete the 
    session key from the browser.