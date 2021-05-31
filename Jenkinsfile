#!groovy
@Library(value='jenkins-sharedlibs@master', changelog=false)_

pipeline {
agent {
    kubernetes {
      label 'nodejs'
      nodeSelector 'ciworkers'
      containerTemplate {
        name 'nodejs'
        image 'node:12-alpine'
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
              sh "env"
              env.short_commit = git.getCommitSha() 
              env.ontrack_label= "${env.BRANCH_NAME}${env.short_commit}"
            }
          }
        }
        stage('Ontrack') {
        steps {
            ontrackBranchSetup(
                    project: 'POC',
                    branch: "NodeJS",
                    script: """\
                        branch.config {
                            gitBranch "NodeJS", [
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
                        branch: "NodeJS",
                        build: "${env.ontrack_label}",
                        gitCommit: "${env.GIT_COMMIT}",
                    )
                }
                success {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS",
                        build: "${env.ontrack_label}",
                        validationStamp: "Build",
                        buildResult: currentBuild.result,
                        description: "Build Step Passed",
                    )
                    //ontrackPromote(
                    //    project: 'POC',
                    //    branch: 'NodeJS',
                    //    build: "${env.ontrack_label}",
                    //    promotionLevel: "BRONZE"
                    //)
                }
                failure {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS",
                        build: "${env.ontrack_label}",
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
                        branch: "NodeJS",
                        build: "${env.ontrack_label}",
                        validationStamp: "LINT",
                        buildResult: currentBuild.result,
                        description: "Static Code Analysis is OK",
                    )
                 //   ontrackPromote(
                 //       project: 'POC',
                 //       branch: 'NodeJS',
                 //       build: "${env.ontrack_label}",
                 //       promotionLevel: "SILVER"
                 //   )
                }
                failure {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS",
                        build: "${env.ontrack_label}",
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
                        branch: "NodeJS",
                        build: "${env.ontrack_label}",
                        validationStamp: "E2E",
                        buildResult: currentBuild.result,
                        description: "End to End Test is OK",
                    )
                    //ontrackPromote(
                    //    project: 'POC',
                    //    branch: 'NodeJS',
                    //    build: "${env.ontrack_label}",
                    //    promotionLevel: "GOLD"
                    //)
                }
                failure {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS",
                        build: "${env.ontrack_label}",
                        validationStamp: "E2E",
                        buildResult: currentBuild.result,
                        description: "End to End Test is Failing",
                    )
                }
            }
        }
    }
    post {
      success {
        script {
            ontrackValidate(project: 'POC',branch: "NodeJS",build: "${env.ontrack_label}",validationStamp: "JOB",buildResult: currentBuild.result,description: "Job Completed with Success")
        }
      }    
      unstable {
        script {
            ontrackValidate(project: 'POC',branch: "NodeJS",build: "${env.ontrack_label}",validationStamp: "JOB",buildResult: currentBuild.result,description: "Job has some unstable Stager")
        }
      }
      failure {
        script {
            ontrackValidate(project: 'POC',branch: "NodeJS",build: "${env.ontrack_label}",validationStamp: "JOB",buildResult: currentBuild.result,description: "Job Failed all, please check the Logs")
          }
        }
    } 
}
