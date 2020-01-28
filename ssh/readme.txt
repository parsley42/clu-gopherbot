The keys here are:
* manage_rsa - dedicated encrypted read-write deploy key for Clu's custom repository
* deploy_rsa.pub - corresponding to an unencrypted private key used for deploying to e.g. a container or new VM
* robot_rsa - encrypted keypair the robot can use for CI/CD, ssh logins and other work
