pipeline {
    agent { label 'secondary' }
    options {
        timeout(time: 1, unit: 'HOURS')
    }
    stages {
        stage('Clone') {
            steps {
                checkout scm
            }
        }

        stage('Check sites') {
            steps {
                sh "chmod +x -R '${env.WORKSPACE}'"
                sh './SiteCheck.sh'
            }
        }
    }
}
