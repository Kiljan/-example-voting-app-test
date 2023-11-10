pipeline {
    agent { 
        node { 
            label 'terra' 
            } 
        }

    environment {
        DOKPATH = '/home/vv/example-voting-app'
        registry_worker = "kiljan963/example-voting-app-worker"
        registryCredential = '3b570775-97b9-4808-a9bd-25977d8ceae7'
        dockerImage = ''
    }

    stages {
        stage('Run docker compose') {
            steps {
                dir ("${DOKPATH}") {
                    sh "docker compose up --detach"
                }
            }
        }
        stage('Healthcheck form docker') {
            steps {
                script {
                    sleep(60)
                    output = sh (
                        script: "${DOKPATH}/healthcheck_pipeline.sh",
                        returnStdout: true
                        ).trim()
                    if (output != 'pass') {
                        echo "Error: Command exited with output ${output}"
                    } else {
                        echo "Command executed successfully"
                    }
                }
            }
        }
        stage('Push to DockerHub') {
            steps {
                dir ("${DOKPATH}") {
                    script{
                        dockerImage = docker.build registry_worker + ":$BUILD_NUMBER"
                    }
                }
            }
        }
    }
}

