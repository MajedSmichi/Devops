pipeline {
    agent any

    tools {
        maven 'Maven3'
    }

    environment {
        SONAR_TOKEN = credentials('sonar-devops')
        KUBECONFIG = '/var/jenkins_home/.kube/config'
        DOCKERHUB_CREDENTIALS = 'dockerhub-cred' // ID du credentials Jenkins pour Docker Hub
        DOCKERHUB_REPO = 'majed/student-management' // ton repo Docker Hub
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'devops',
                    url: 'https://github.com/MajedSmichi/Devops.git',
                    credentialsId: 'devops'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh """
                        mvn sonar:sonar \
                        -DskipTests \
                        -Dsonar.projectKey=student-management \
                        -Dsonar.host.url=http://sonarqube:9000 \
                        -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    sh "docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} ."

                    // Login Docker Hub
                    withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS}", 
                                                      usernameVariable: 'DOCKER_USER', 
                                                      passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    }

                    // Push de l'image
                    sh "docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}"
                }
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                script {
                    echo 'Deploying application on Kubernetes...'
                    sh 'kubectl apply -f k8s/namespace.yaml || true'
                    sh 'kubectl apply -f k8s/mysql-deployment.yaml'
                    sh 'kubectl apply -f k8s/mysql-service.yaml'

                    // Mettre à jour le deployment Spring Boot avec l'image Docker Hub
                    sh "kubectl set image deployment/student-app student-app=${DOCKERHUB_REPO}:${IMAGE_TAG}"
                    sh 'kubectl apply -f k8s/student-app-service.yaml'
                }
            }
        }
    }

    post {
        always {
            echo '✅ Pipeline terminé'
        }
    }
}
