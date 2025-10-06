pipeline {
    agent any

    tools {
        maven 'Maven3' // Assure-toi que Maven est configuré dans Jenkins
    }

    environment {
        SONAR_TOKEN = credentials('jenkins') // Ton token SonarQube enregistré dans Jenkins
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
                sh 'mvn clean install'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') { // Nom du serveur SonarQube configuré dans Jenkins
                    // Utiliser le nom du conteneur SonarQube dans Docker network
                    sh "mvn sonar:sonar -Dsonar.projectKey=student-management -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=${SONAR_TOKEN}"
                }
            }
        }

        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t student-management:latest .'
            }
        }

        stage('Docker Compose Deploy') {
            steps {
                echo 'Deploying application with Docker Compose...'
                sh 'docker-compose down || true'  // Arrête les anciens conteneurs si existants
                sh 'docker-compose up -d --build'
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished.'
        }
    }
}
