#!groovy
def LABEL_ID = "ontrack-poc-${UUID.randomUUID().toString()}"

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
        GIT_BRANCH = 'master'
        GIT_REPOS_URL = 'https://bitbucket.org/globalshares/poc-ontrack.git'
        BITBUCKET_CRED = "gscloudsvc"
    }
   
    options {
        buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '20')
        disableConcurrentBuilds()    
        skipStagesAfterUnstable() 
        timeout(time: 1, unit: 'HOURS')
        parallelsAlwaysFailFast()
        skipDefaultCheckout true

    }

    stages {
        stage('Checkout') {
            steps { 
            echo 'Start Clone Repository'
                checkout([$class: 'GitSCM', 
                    branches: [[name: "$GIT_BRANCH"]], 
                    doGenerateSubmoduleConfigurations: false, 
                    extensions: [[$class: 'RelativeTargetDirectory', 
                    relativeTargetDir: "."]], 
                    submoduleCfg: [], 
                    userRemoteConfigs: [
                    [credentialsId: "$BITBUCKET_CRED", 
                    url: "$GIT_REPOS_URL"]]
                    ])            
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
                        build: "${env.BUILD_ID}",
                        gitCommit: "${env.GIT_COMMIT}",
                    )
                }
                success {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS",
                        build: "${env.BUILD_ID}",
                        validationStamp: "Build",
                        buildResult: currentBuild.result,
                        description: "Build Step Passed",
                    )
                    //ontrackPromote(
                    //    project: 'POC',
                    //    branch: 'NodeJS',
                    //    build: "${env.BUILD_ID}",
                    //    promotionLevel: "BRONZE"
                    //)
                }
                failure {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS",
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
                        branch: "NodeJS",
                        build: "${env.BUILD_ID}",
                        validationStamp: "LINT",
                        buildResult: currentBuild.result,
                        description: "Static Code Analysis is OK",
                    )
                 //   ontrackPromote(
                 //       project: 'POC',
                 //       branch: 'NodeJS',
                 //       build: "${env.BUILD_ID}",
                 //       promotionLevel: "SILVER"
                 //   )
                }
                failure {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS",
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
                        branch: "NodeJS",
                        build: "${env.BUILD_ID}",
                        validationStamp: "E2E",
                        buildResult: currentBuild.result,
                        description: "End to End Test is OK",
                    )
                    //ontrackPromote(
                    //    project: 'POC',
                    //    branch: 'NodeJS',
                    //    build: "${env.BUILD_ID}",
                    //    promotionLevel: "GOLD"
                    //)
                }
                failure {
                    ontrackValidate(
                        project: 'POC',
                        branch: "NodeJS",
                        build: "${env.BUILD_ID}",
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
            ontrackValidate(project: 'POC',branch: "NodeJS",build: "${env.BUILD_ID}",validationStamp: "JOB",buildResult: currentBuild.result,description: "Job Completed with Success")
        }
      }    
      unstable {
        script {
            ontrackValidate(project: 'POC',branch: "NodeJS",build: "${env.BUILD_ID}",validationStamp: "JOB",buildResult: currentBuild.result,description: "Job has some unstable Stager")
        }
      }
      failure {
        script {
            ontrackValidate(project: 'POC',branch: "NodeJS",build: "${env.BUILD_ID}",validationStamp: "JOB",buildResult: currentBuild.result,description: "Job Failed all, please check the Logs")
          }
        }
    } 
}
