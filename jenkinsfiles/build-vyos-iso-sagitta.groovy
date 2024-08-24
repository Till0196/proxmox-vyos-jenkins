pipeline {
    agent any

    environment {
        DATE = sh(script: 'date +%Y%m%d', returnStdout: true).trim()
        CUSTOM_PACKAGES = 'vyos-1x-smoketest'
        APT_KEY_URL = 'http://172.17.17.17/apt.gpg.key'
        VYOS_BUILD_REPO = 'https://github.com/dd010101/vyos-build'
        VYOS_1X_REPO = 'https://github.com/vyos/vyos-1x.git'
        VYOS_MIRROR = 'http://172.17.17.17/sagitta'
        DEBIAN_ELTS_MIRROR = 'http://172.17.17.17:3142/deb.freexian.com/extended-lts'
    }

    stages {
        stage('Download apt signing key') {
            steps {
                script {
                    sh 'curl -s -S --fail-with-body $APT_KEY_URL -o apt.gpg.key'
                }
            }
        }

        stage('Get Latest Tag') {
            steps {
                script {
                    def getLatestTag = { branch ->
                        sh(script: '''
                            git clone -q --bare $VYOS_1X_REPO -b sagitta temp-git-tag > /dev/null
                            cd temp-git-tag
                            git describe --tags --abbrev=0
                            cd ../
                            rm -rf temp-git-tag
                        ''', returnStdout: true).trim()
                    }
                    env.LATEST = getLatestTag('sagitta')
                    env.RELEASE_NAME = "${env.LATEST}-release-${env.DATE}"
                }
            }
        }

        stage('Clone VyOS Build Repository') {
            steps {
                script {
                    sh '''
                        rm -rf vyos-build
                        git clone -q $VYOS_BUILD_REPO > /dev/null
                        cd vyos-build
                        git checkout "sagitta" > /dev/null
                        cd ../
                    '''
                }
            }
        }

        stage('Build ISO') {
            steps {
                script {
                    sh '''
                        docker run --rm --privileged -v ./vyos-build/:/vyos -v "./apt.gpg.key:/opt/apt.gpg.key" -w /vyos --sysctl net.ipv6.conf.lo.disable_ipv6=0 -e GOSU_UID=$(id -u) -e GOSU_GID=$(id -g) -w /vyos vyos/vyos-build:sagitta \
                            sudo --preserve-env ./build-vyos-image iso \
                            --architecture amd64 \
                            --build-by "" \
                            --build-type release \
                            --debian-mirror http://deb.debian.org/debian/ \
                            --version "$RELEASE_NAME" \
                            --vyos-mirror http://172.17.17.17/sagitta \
                            --custom-apt-key /opt/apt.gpg.key \
                            --custom-package "$customPackages"
                        docker run --rm --privileged -v ./vyos-build/:/vyos -v "./apt.gpg.key:/opt/apt.gpg.key" -w /vyos --sysctl net.ipv6.conf.lo.disable_ipv6=0 -e GOSU_UID=$(id -u) -e GOSU_GID=$(id -g) -w /vyos vyos/vyos-build:sagitta \
                             sudo chown -R $(id -u):$(id -g) build
                    '''
                }
            }
        }

        stage('Rename and Archive ISO') {
            steps {
                script {
                    sh '''
                        if [ -f vyos-build/build/live-image-amd64.hybrid.iso ]; then
                            mv vyos-build/build/live-image-amd64.hybrid.iso vyos-$RELEASE_NAME-iso-amd64.iso
                            echo "ISO build is complete. The file is called: vyos-$RELEASE_NAME-iso-amd64.iso"
                        else
                            echo "Failed to locate ISO file."
                            exit 1
                        fi
                    '''
                }
                archiveArtifacts artifacts: "vyos-$RELEASE_NAME-iso-amd64.iso", allowEmptyArchive: false
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
