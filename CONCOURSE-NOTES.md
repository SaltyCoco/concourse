### FLY CLI COMMANDS

    fly -t tutorial login -c <url of target> -u <username> -p <password>
        login cli to the target
            fly -t tutorial login -c http://localhost:8080 -u test -p test

    fly targets
    	shows the concourse deployments
    		name  url                    team  expiry                       
    		ps    http://localhost:8080  main  Thu, 10 Dec 2020 01:33:27 UTC
    		
    fly -t <target> execute -c <yml pipeline file>
        executes the pipeline
            fly -t tutorial e -c no_inputs.yml
            uploading task-inputs ?[1mdone?[22m
            executing build 3 at http://localhost:8080/builds/3
            ?[1minitializing?[0m
            ?[1mselected worker:?[0m d16d57811058
            ?[1mrunning ls -al?[0m
            total 8
            drwxr-xr-x    2 root     root          4096 Dec  9 20:38 ?[1;34m.?[m
            drwxr-xr-x    3 root     root          4096 Dec  9 20:38 ?[1;34m..?[m
            ?[32msucceeded?[0m

    
    fly -t <target> userinfo
    	shows the user role you have
    	  ./fly -t ps userinfo
    	  username  team/role 
          test      main/owner
    
    fly -t <target> pipelines
    	shows pipelines running for target
    	  ./fly -t ps pipelines
    	  name  paused  public  last updated
     	
    fly -t <target> set-pipeline -c <yml file> -p <pipeline name>
    	run a pipeline * initially it will be in a paused state
    	  ./fly -t ps set-pipeline -c /Users/ryanschulte/Documents/concourse/Training/.  	Pluralsight/concourse-getting-started/02/demos/mod1/before/mod1-pipeline.yml -p 	mod1-pipeline 
    		it will show you the yml file contents then ask you y/n if you want to ruin it
    		then it will provide the url for the pipeline
	
	* Remember to make shell scripts used in "run" executable
	    chmod +x <path to script>
	    
  
### BASIC INFO

	TASK
		part of a job that does something specific 
		1. Similar to a function, with input and output
		2. Smallest configurable unit
		3. Runs in containers using designed image 
			- container is destroyed upon completion
		4. Specify a statement to execute
        5. resources are the ONLY durable storage mechanism in a pipeline, everything else is stateless
        6. Task inputs produce dirs full of artifacts within the container
        7. Task outputs are stored on worker filesystem and mounted into containers for subsequent tasks within
            the same job, DOES NOT SHARE JOBS
        8. You can test tasks WITHOUT testing the pipeline i.e unit testing
        9. The input name needs to match the current directory, if it doesn't you need to specify it with -i
            see : https://concoursetutorial.com/basics/task-scripts/ for more details
		
		EXAMPLE TASK:
			——-
			platform: linux                        # which platform the task needs to be run on

            image_resource:                        # Sets specific container image that will run the task
			    type: docker-image
                source: {repository: unbuntu}      # "repository" is required source param and optional ones 
                                                   # could be tag or username/password, can also use your own
                                                   # docker image if you want pre-baked things
            inputs:
                name: demo-folder                  # Specify artifacts availabler in current dir @ task run time    
                                                   # An oiptional is path name, inputs can come from cli params
                                                   # a "get" step within build plabn or from "outputs" of 
                                                   # previous "task"
            
            outputs:                               # Artifacts produced by the task, a dir available to later
            - name: compiled-app                   # steps in the build plan * another task would reference
                                                   # "comp;iled-app" as a reference 

            run:                                   # Represents the command to run in the container, want to 
                path: find                         # make sure this is small, "path" could point a specific
                args: [.]                          # bash command or script provided by "input"

    RESOURCES
        1. Represent the external inputs and outputs of a job in a pipeline
        2. Resources have a "type" and behavior when retrieved or published too
        3. Concourse provides many resources "out of the box" such as S3, git, ect
        
        ___
        resource_types:                             # All resources have a "type" that determines the detected version,
        - name: azure-blobstore                     # what is retrieved and what occurs on "put", have ability to 
          type: docker-image                        # declare added param (optional) if needed by resource type
          source:                                   # "check_every" can be set which overrides 1m polling period.
            repository: [coordinates]
        
        fly -t ps execute -c mod2-task-3.yml -i resources=./resources
	        Need to reference the dir to tell concourse where the executable is if not in current dir

### UI INFO

	- a dotted line in the UI means the job needs to be triggered manually