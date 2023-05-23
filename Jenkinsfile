pipeline {
    agent any
    options {
        timeout(time: 1, unit: 'HOURS')
    }
    stages {
        stage('Clone') {
            steps {
                checkout scm
            }
        }

        stage('Run') {
            steps {
                sh './SiteCheck.sh'
            }
        }
    }
}
