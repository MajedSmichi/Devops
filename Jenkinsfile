pipeline {
    agent any

    tools {
        maven 'Maven3'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'devops',
                    url: 'https://github.com/MajedSmichi/Devops.git',
                    credentialsId: 'devops'
            }
        }

        stage('Start MySQL') {
            steps {
                sh '''
                # Stop et supprime si déjà existant
                docker stop mysql-test || true
                docker rm mysql-test || true

                # Lancer MySQL
                docker run -d --name mysql-test -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=studentdb -p 3306:3306 mysql:8.1

                # Attendre que MySQL soit prêt
                until docker exec mysql-test mysql -uroot -proot -e "SELECT 1;" ; do
                    echo "Waiting for MySQL..."
                    sleep 5
                done
                '''
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

        stage('Stop MySQL') {
            steps {
                sh 'docker stop mysql-test && docker rm mysql-test'
            }
        }
    }
}
