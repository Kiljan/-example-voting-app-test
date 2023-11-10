# Example Voting App

Based on https://github.com/dockersamples/example-voting-app 

A simple distributed application running across multiple Docker containers.

The voting application only accepts one vote per client browser. It does not register additional votes if a vote has already been submitted from a client.


## Getting started

Download [Docker Desktop](https://www.docker.com/products/docker-desktop) for Mac or Windows. [Docker Compose](https://docs.docker.com/compose) will be automatically installed. On Linux, make sure you have the latest version of [Compose](https://docs.docker.com/compose/install/).

This solution uses Python, Node.js, .NET, with Redis for messaging and Postgres for storage.

Run in this directory to build and run the app:

```shell
docker compose up
```

The `vote` app will be running at [http://localhost:5000](http://localhost:5000), and the `results` will be at [http://localhost:5001](http://localhost:5001).

Alternately, if you want to run it on a [Docker Swarm](https://docs.docker.com/engine/swarm/), first make sure you have a swarm. If you don't, run:

```shell
docker swarm init
```

Once you have your swarm, in this directory run:

```shell
docker stack deploy --compose-file docker-stack.yml vote
```

## Run the app in Kubernetes

The folder k8s-specifications contains the YAML specifications of the Voting App's services.

Run the following command to create the deployments and services. Note it will create these resources in your current namespace (`default` if you haven't changed it.)

```shell
kubectl create -f k8s-specifications/
```

The `vote` web app is then available on port 31000 on each host of the cluster, the `result` web app is available on port 31001.

To remove them, run:

```shell
kubectl delete -f k8s-specifications/
```

## Architecture

![Architecture diagram](architecture.excalidraw.png)

* A front-end web app in [Python](/vote) which lets you vote between two options
* A [Redis](https://hub.docker.com/_/redis/) which collects new votes
* A [.NET](/worker/) worker which consumes votes and stores them in…
* A [Postgres](https://hub.docker.com/_/postgres/) database backed by a Docker volume
* A [Node.js](/result) web app which shows the results of the voting in real time


## PS. 

I use a different pipeline to build and push to my public DockerHub account, like this:
```
pipeline{
    agent { 
        node { 
            label 'terra' 
            } 
        }

    environment {
        registry_worker = "kiljan963/example-voting-app-worker"
        registry_vote = "kiljan963/example-voting-app-vote"
        registry_result = "kiljan963/example-voting-app-result"
        registryCredential = '3b570775-97b9-4808-a9bd-25977d8ceae7'
        dockerImage_worker = ''
        dockerImage_vote = ''
        dockerImage_result = ''
    } 

    stages{
        stage('Cloning  Git') {
            steps { 
                git 'https://github.com/Kiljan/Example-voting-app-test.git'
            }
        }
        stage('Building images') {
            steps{
                dir('./worker'){
                    script {
                        dockerImage_worker = docker.build registry_worker + ":$BUILD_NUMBER"
                        }
                }
                dir('./vote'){
                    script {
                        dockerImage_vote = docker.build registry_vote + ":$BUILD_NUMBER"
                        }
                }
                dir('./result'){
                    script {
                        dockerImage_result = docker.build registry_result + ":$BUILD_NUMBER"
                        }
                }
            }
        }
        stage('Deploy our image') {
            steps{
                script {
                    docker.withRegistry( '', registryCredential ) {
                    dockerImage_worker.push()
                    dockerImage_vote.push()
                    dockerImage_result.push()
                    }
                }
            }
        }
        stage('Cleaning up'){
            steps{
                sh "docker rmi $registry_worker:$BUILD_NUMBER"
                sh "docker rmi $registry_vote:$BUILD_NUMBER"
                sh "docker rmi $registry_result:$BUILD_NUMBER"
            }
        }
        
    }
}
```