pipeline { 
    agent any 
    environment { 
        REPO_URL      = 'https://github.com/zaidqureshi3111995/portfolio-cloud' 
        SONARQUBE_ENV = 'SonarQube-Server' 
        DOCKER_SERVER = 'ubuntu@172.31.26.188' 
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
                        -Dsonar.sources=. 
                        """ 
                    } 
                } 
            } 
        } 
        stage('Docker Build & Deploy') { 
            steps { 
                sshagent(['docker-server-ssh']) { 
                    sh """ 
                    # index.html is being used here 
                    scp -o StrictHostKeyChecking=no index.html Dockerfile 
${DOCKER_SERVER}:/home/ubuntu/ 
                    ssh -o StrictHostKeyChecking=no ${DOCKER_SERVER} ' 
                    cd /home/ubuntu 
                    docker build -t portfolio-app . 
                    docker stop portfolio-app || true 
                    docker rm portfolio-app || true 
                    docker run -d -p 80:80 --name portfolio-app portfolio-app 
                    ' 
                    """ 
                } 
            } 
        } 
    } 
    post { 
        success { 
            echo "    Deployment Successful: http://172.31.26.188" 
        } 
        failure { 
            echo "   Pipeline Failed" 
        } 
    } 
} 
