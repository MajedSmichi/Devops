pipeline {
    agent any

    tools {
        maven 'Maven3' // (configure this name in Jenkins -> Global Tool Configuration)
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'devops', url: 'https://github.com/MajedSmichi/student-management.git'
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

        stage('Package') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying application...'
            }
        }
    }
}
