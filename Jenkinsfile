pipeline {
    agent { 
        node { 
            label 'terra' 
            } 
        }

    environment {
        DOKPATH = '/home/vv/example-voting-app'
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
    }
}