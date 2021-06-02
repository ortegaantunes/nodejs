#!groovy
@Library(value='jenkins-sharedlibs@master', changelog=false)_

pipeline {
agent {
    kubernetes {
      label 'nodejs'
      nodeSelector 'ciworkers'
      containerTemplate {
        name 'nodejs'
        image 'ortega87/nodejs-buildbox:1.3'
        command 'sleep'
        args '9999999'
        resourceRequestCpu '50m'
        resourceLimitCpu '100m'
        resourceRequestMemory '100Mi'
        resourceLimitMemory '200Mi'
      }
      podRetention onFailure()
    }
  }
    
    environment {
      project_name='ontrack-poc-ci'
      DOCKER_REGISTRY_NAME = 'gscontainerregistry'
      jenkins_sp_id = 'jenkins_sp'
      SONAR_HOST_URL = 'http://10.10.3.140:9000'
      SONAR_AUTH_TOKEN = 'b44c8f69042f501abfbab0401d762a6adbc88f87'
      SONAR_PROJECT_KEY = 'ontrack_poc'
      SONAR_INCLUSIONS = 'app/,e2e_tests/,app/__tests__/'
    }
   
    options {
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '20')
        disableConcurrentBuilds()    
        skipStagesAfterUnstable() 
        timeout(time: 1, unit: 'HOURS')
        parallelsAlwaysFailFast()
    }

    stages {
        stage("init"){
          steps{
            script{
              sh "ls -la"
              sh "df -h"
              sh "env"
              env.short_commit = git.getCommitSha() 
              env.ontrack_label= "${env.short_commit}"
            }
          }
        }
        stage('Ontrack') {
        steps {
            ontrackBranchSetup(
                    project: 'POC',
                    branch: "NodeJS-Demo",
                    script: """\
                        branch.config {
                            gitBranch "NodeJS-Demo", [
                                buildCommitLink: [
                                    id: 'git-commit-property'
                                ]
                            ]
                        }
                    """
                )
            }
        }
        stage ('Build') {
            steps { 
                container('nodejs') {
                sh """
                npm install
                """ 
                }
            }
            post {
                always {
                    ontrackBuild(
                        project: 'POC',
                        branch: "NodeJS-Demo",
                        build: "${env.BUILD_ID}",
                        gitCommit: "${env.GIT_COMMIT}",
                    )
                }
                success {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS-Demo",
                        build: "${env.BUILD_ID}",
                        validationStamp: "Build",
                        buildResult: currentBuild.result,
                        description: "Build Step Passed",
                    )
                }
                failure {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS-Demo",
                        build: "${env.BUILD_ID}",
                        validationStamp: "Build",
                        buildResult: currentBuild.result,
                        description: "Build Step Failed",
                    )
                }
            }
        }
        stage ('Lint') {
            steps {
                container('nodejs'){
                sh """
                npm test
                """
                }
            }
            post {
                success {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS-Demo",
                        build: "${env.BUILD_ID}",
                        validationStamp: "LINT",
                        buildResult: currentBuild.result,
                        description: "Static Code Analysis is OK",
                    )
                }
                failure {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS-Demo",
                        build: "${env.BUILD_ID}",
                        validationStamp: "LINT",
                        buildResult: currentBuild.result,
                        description: "Static Code Analysis is Failing",
                    )
                }
            }
        }
            stage ('E2E') {
            steps {
                container('nodejs'){
                sh """
                npm run test:e2e
                """
                }
            }
            post {
                success {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS-Demo",
                        build: "${env.BUILD_ID}",
                        validationStamp: "E2E",
                        buildResult: currentBuild.result,
                        description: "End to End Test is OK",
                    )
                }
                failure {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS-Demo",
                        build: "${env.BUILD_ID}",
                        validationStamp: "E2E",
                        buildResult: currentBuild.result,
                        description: "End to End Test is Failing",
                    )
                }
            }
        }
            stage('Sonar') {
            steps{
              script{
                echo 'Start Analysis Code'
                      sh "/opt/sonar-scanner/bin/sonar-scanner -X \
                      -Dsonar.projectKey=$SONAR_PROJECT_KEY \
                      -Dsonar.host.url=$SONAR_HOST_URL \
                      -Dsonar.test.inclusions=$SONAR_INCLUSIONS \
                      -Dsonar.login=$SONAR_AUTH_TOKEN \
                      -Dsonar.projectBaseDir=. \
                      -Dsonar.sources=."    
                }
            }
            post {
                success {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS-Demo",
                        build: "${env.BUILD_ID}",
                        validationStamp: "sonarqube",
                        buildResult: currentBuild.result,
                        description: "Sonarqube",
                    )
                }
                failure {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS-Demo",
                        build: "${env.BUILD_ID}",
                        validationStamp: "sonarqube",
                        buildResult: currentBuild.result,
                        description: "Sonarqube",
                    )
                }
            }
        }       
    }
    post {
      success {
        script {
            ontrackValidate(project: 'POC',branch: "NodeJS-Demo",build: "${env.BUILD_ID}",validationStamp: "JOB",buildResult: currentBuild.result,description: "Job Completed with Success")
        }
      }    
      unstable {
        script {
            ontrackValidate(project: 'POC',branch: "NodeJS-Demo",build: "${env.BUILD_ID}",validationStamp: "JOB",buildResult: currentBuild.result,description: "Job has some unstable Stager")
        }
      }
      failure {
        script {
            ontrackValidate(project: 'POC',branch: "NodeJS-Demo",build: "${env.BUILD_ID}",validationStamp: "JOB",buildResult: currentBuild.result,description: "Job Failed all, please check the Logs")
          }
        }
    } 
}
