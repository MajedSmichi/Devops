pipeline {
    agent any

    tools {
        maven 'Maven3'
    }

    environment {
        SONAR_TOKEN = credentials('sonar-devops')
        KUBECONFIG = '/var/jenkins_home/.kube/config'
        DOCKERHUB_CREDENTIALS = 'dockerhub-cred' 
        DOCKERHUB_REPO = 'majedsmichi/student-management'
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
                    
                    withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS}", 
                                                      usernameVariable: 'DOCKER_USER', 
                                                      passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    }

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

                    // Créer ou mettre à jour le déploiement de l'application
                    sh 'kubectl apply -f k8s/student-app-deployment.yaml'
                    sh "kubectl set image deployment/student-app student-app=${DOCKERHUB_REPO}:${IMAGE_TAG} -n student-management"
                    sh 'kubectl apply -f k8s/student-app-service.yaml'
                }
            }
        }

        stage('Check Student App') {
            steps {
                script {
                    echo 'Checking if Student App is ready...'
                    sh '''
                        POD=$(kubectl get pod -l app=student-app -n student-management -o jsonpath='{.items[0].metadata.name}')
                        for i in {1..10}; do
                            kubectl exec $POD -n student-management -- wget -qO- http://localhost:8089/student/actuator/prometheus && break
                            echo "Waiting for student-app to be ready..."
                            sleep 5
                        done
                    '''
                }
            }
        }

        stage('Deploy Monitoring') {
            steps {
                script {
                    echo 'Deploying Prometheus and Grafana...'
                    sh 'kubectl apply -f k8s/monitoring/namespace.yaml'
                    sh 'kubectl apply -f k8s/monitoring/prometheus-config.yaml'
                    sh 'kubectl apply -f k8s/monitoring/prometheus-deployment.yaml'
                    sh 'kubectl apply -f k8s/monitoring/prometheus-service.yaml'
                    sh 'kubectl apply -f k8s/monitoring/grafana-deployment.yaml'
                    sh 'kubectl apply -f k8s/monitoring/grafana-service.yaml'
                }
            }
        }
    }

    post {
        always {
            echo '✅ Pipeline terminé'
        }
        success {
            echo '🎉 Build & deploy réussis !'
        }
        failure {
            echo '❌ Il y a eu un problème dans la pipeline.'
        }
    }
}
