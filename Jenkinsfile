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
                        // Command ko ek hi line mein kar diya gaya hai taake backslash ka error na aaye
                        sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=portfolio-cloud -Dsonar.projectName=portfolio-cloud -Dsonar.sources=. -Dsonar.exclusions=**/node_modules/**"
                    } 
                } 
            } 
        }

        stage('Docker Build & Deploy') { 
            steps { 
                sshagent(['docker-credentials']) { 
                    sh """
                    scp -o StrictHostKeyChecking=no index.html Dockerfile ${DOCKER_SERVER}:/home/ubuntu/
                    ssh -o StrictHostKeyChecking=no ${DOCKER_SERVER} "
                        cd /home/ubuntu && \
                        docker build -t portfolio-app . && \
                        docker stop portfolio-app || true && \
                        docker rm portfolio-app || true && \
                        docker run -d -p 80:80 --name portfolio-app portfolio-app
                    "
                    """
                } 
            } 
        } 
    } 
    post { 
        success { 
            echo "Deployment Successful!" 
        } 
        failure { 
            echo "Pipeline Failed. Please check the SonarQube Scanner logs in Jenkins." 
        } 
    } 
}