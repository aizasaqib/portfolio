pipeline { 
    agent any 
    environment { 
        REPO_URL      = 'https://github.com/aizasaqib/portfolio' 
        SONARQUBE_ENV = 'SonarQube-Server' 
        DOCKER_SERVER = 'ubuntu@ip-172-31-11-228' 
    } 
    stages { 
        stage('Checkout Code') { 
            steps { 
                git branch: 'master', 
                url: "${REPO_URL}", 
                credentialsId: 'github-credentials' 
            } 
        } 
        
        stage('SonarQube Analysis') { 
            steps { 
                script { 
                    def scannerHome = tool 'SonarQube Scanner' 
                    withSonarQubeEnv("${SONARQUBE_ENV}") { 
                        sh """ 
                        ${scannerHome}/bin/sonar-scanner \ 
                        -Dsonar.projectKey=portfolio-cloud \ 
                        -Dsonar.projectName=portfolio-cloud \ 
                        -Dsonar.sources=. \
                        -Dsonar.exclusions=**/node_modules/**,**/dist/**,**/*.test.js \
                        -Dsonar.java.binaries=.
                        """ 
                    } 
                } 
            } 
        }

        // Quality Gate stage is important to prevent loops/bad code deployment
        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build & Deploy') { 
            steps { 
                sshagent(['docker-credentials']) { 
                    sh """ 
                    # StrictHostKeyChecking fix to prevent SSH hang
                    scp -o StrictHostKeyChecking=no index.html Dockerfile ${DOCKER_SERVER}:/home/ubuntu/ 
                    
                    ssh -o StrictHostKeyChecking=no ${DOCKER_SERVER} ' 
                        cd /home/ubuntu
                        # Build container
                        docker build -t portfolio-app . 
                        
                        # Existing container ko clean up karna
                        docker stop portfolio-app || true 
                        docker rm portfolio-app || true 
                        
                        # New container run karna
                        docker run -d -p 80:80 --name portfolio-app portfolio-app 
                    ' 
                    """ 
                } 
            } 
        } 
    } 
    post { 
        success { 
            echo "Deployment Successful: http://172.31.26.188" 
        } 
        failure { 
            echo "Pipeline Failed - Check SonarQube or Docker Logs" 
        } 
    } 
}