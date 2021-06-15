//#!groovy
//@Library(value='jenkins-sharedlibs@master', changelog=false)_

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
      DOCKER_REGISTRY_NAME = ''
      jenkins_sp_id = 'jenkins_sp'
      SONAR_HOST_URL = 'http://192.168.1.12:9000'
      SONAR_AUTH_TOKEN = '1d207c5f1186076aba4843fcad5778e36b23ae76'
      SONAR_PROJECT_KEY = 'ontrack'
      SONAR_INCLUSIONS = "e2e_tests/*.test.js,app/__tests__/*.test.js,app/*.js,e2e_tests/*.js"
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
              //env.short_commit = git.getCommitSha() 
              //env.ontrack_label= "${env.short_commit}"
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
        /*stage ('Build') {
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
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS-Demo",
                        build: "${env.BUILD_ID}",
                        validationStamp: "Build",
                        buildResult: currentBuild.result,
                        description: "Build Step Passed",
                    )
                }
            }
        }*/
        /*stage ('Lint') {
            steps {
                container('nodejs'){
                sh """
                npm test
                """
                }
            }
            post {
                always {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS-Demo",
                        build: "${env.BUILD_ID}",
                        validationStamp: "LINT",
                        buildResult: currentBuild.result,
                        description: "Static Code Analysis is OK",
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
                always {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS-Demo",
                        build: "${env.BUILD_ID}",
                        validationStamp: "E2E",
                        buildResult: currentBuild.result,
                        description: "End to End Test is OK",
                    )
                }
            }
        }*/
        stage('Sonar') {
            steps{
              script{
                echo 'Start Analysis Code'
                      sh "/opt/sonar-scanner/bin/sonar-scanner -X \
                      -Dsonar.projectKey=$SONAR_PROJECT_KEY \
                      -Dsonar.host.url=$SONAR_HOST_URL \
                      -Dsonar.test.inclusions=$SONAR_INCLUSIONS \
                   //   -Dsonar.eslint.reportPaths=coverage/eslint-report.json \
                      -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
                  //    -Dsonar.testExecutionReportPaths=coverage/test-reporter.xml \
                      -Dsonar.login=$SONAR_AUTH_TOKEN \
                      -Dsonar.projectBaseDir=. \
                      -Dsonar.projectVersion=${env.BUILD_ID} \
                      -Dsonar.sources=."  
                }
            }
            post {
                always {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS-Demo",
                        build: "${GIT_COMMIT}-${env.BUILD_ID}",
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
