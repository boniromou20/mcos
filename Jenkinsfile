pipeline {
    agent { label 'docker' }
    options {
        buildDiscarder( logRotator( numToKeepStr: '15' ) )
        skipDefaultCheckout()
        timeout( time: 10, unit: 'MINUTES')
    }
    stages {
        stage('Checkout SCM') {
            steps {
                deleteDir()
                checkout scm
            }
        }
        stage('Test') {
            steps {
                sh 'make test'
            }
            post {
                always {
                  publishHTML(target:[allowMissing: false,
                                      alwaysLinkToLastBuild: false,
                                      keepAll: true,
                                      reportDir: 'target/reports/spec',
                                      reportFiles: 'index.html',
                                      reportName: 'Test Report'])

                  publishHTML(target:[allowMissing: false,
                                      alwaysLinkToLastBuild: false,
                                      keepAll: true,
                                      reportDir: 'target/reports/coverage',
                                      reportFiles: 'index.html',
                                      reportName: 'Test Case Coverage Report'])

                  publishHTML(target:[allowMissing: false,
                                      alwaysLinkToLastBuild: false,
                                      keepAll: true,
                                      reportDir: 'target/reports/rubycritic',
                                      reportFiles: 'overview.html',
                                      reportName: 'RubyCritic Report'])

                }
            }
        }
        stage('Build & Release') {
            when {
                branch 'master'
            }
            steps {
                sh 'make build'
                sh 'make release'
            }
        }
        stage('Tag & Publish') {
            when {
                branch 'master'
            }
            steps {
                sh "make tag ${tagName()}"
                sh 'make publish'
            }
        }
    }
    post {
        always {
            sh 'make clean'
            notifyBuild( currentBuild.result )
        }
    }
}

def notifyBuild(String buildStatus) {
  // Default values
  buildStatus =  buildStatus ?: 'PASSED'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def details = "Check console output at ${env.BUILD_URL} to view the results."

  emailext (
      subject: subject,
      body: details,
      recipientProviders: [[$class: 'DevelopersRecipientProvider'], [$class: 'RequesterRecipientProvider']]
    )
}

def tagName() {
    "${version()}.build${env.BUILD_NUMBER}"
}

def version() {
    def matcher = readFile( findFiles(glob: 'app/version.rb')[0].path ) =~ /VERSION\s+\=\s+['"](.*)['"]/
    matcher ? matcher[0][1] : error('Version not find')
}
