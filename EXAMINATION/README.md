Deploy laravel and set up postgresql

You are required to deploy a Laravel application
The entire deployment steps including installation of packages and dependencies, configuring your apache webserver etc, will be defined in an ansible playbook and deployed to atleast one ansible slave.
You should also write a bash script that would install and set up postgresql. 
This bash would be run on your ansible slaves using an ansible playbook 

Requirements
We should be able to access your deployment using a domain name of your choice(not an IP address).

We should be able to test all the endpoints without errors

Your base url may or may not display the default Laravel page.

These must be done on virtual machines on any cloud provider of your choice(any Linux distro of your choice)

Your application must be encrypted with TLS/SSL
