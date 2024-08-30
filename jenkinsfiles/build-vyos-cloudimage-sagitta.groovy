pipeline {
    agent any

    environment {
        PACKER_VYOS_REPO = 'https://github.com/vyos-contrib/packer-vyos'
    }

    stages {
        stage('Download ISO') {
            steps {
                script {
                    copyArtifacts projectName: 'build-vyos-iso-sagitta', filter: 'vyos-*-iso-amd64.iso', target: 'iso/'
                }
            }
        }

        stage('Clone Packer VyOS Repository and Setup') {
            steps {
                script {
                    sh '''
                        git clone $PACKER_VYOS_REPO
                        cd packer-vyos
                        mkdir iso
                        mv ../iso/vyos-*-iso-amd64.iso iso/
                        ISO_NAME=$(basename iso/vyos-*-iso-amd64.iso .iso)
                        echo $(sha256sum iso/${ISO_NAME}.iso | awk '{print $1}') > iso/SHA256SUM
                        echo ${ISO_NAME} > .vm_name
                        make init
                        cp vyos-1.4.pkrvars.hcl local-vyos-1.4.pkrvars.hcl
                        sed -i -E '/exit 0/d' scripts/vyos/apt-repo-debian.sh
                        sed -i -E "s|vm_name\\s*=\\s*\\"[^\\"]*\\"|vm_name = \\"${ISO_NAME}\\"|g" local-vyos-1.4.pkrvars.hcl
                        sed -i -E "s|cloud_init\\s*=\\s*\\"debian\\"|cloud_init = \\"comment\\"|g" local-vyos-1.4.pkrvars.hcl
                        sed -i -E "s|headless\\s*=\\s*false|headless = true|g" local-vyos-1.4.pkrvars.hcl
                    '''
                }
            }
        }

        stage('Build with Packer') {
            steps {
                script {
                    sh '''
                        cd packer-vyos
                        make build1-1.4
                        make build2-1.4
                        ls -l iso/
                    '''
                }
            }
        }

        stage('Rename and Archive Artifacts') {
            steps {
                script {
                    sh '''
                        cd packer-vyos
                        # Rename build1 files
                        for file in iso/vyos-*-build1.qcow2; do
                            mv "$file" "${file%-build1.qcow2}-prebuild.qcow2"
                        done
                        for file in iso/vyos-*-build1.qcow2.checksum; do
                            mv "$file" "${file%-build1.qcow2.checksum}-prebuild.checksum"
                        done

                        # Rename build2 files
                        for file in iso/vyos-*-build2.qcow2; do
                            mv "$file" "${file%-build2.qcow2}.qcow2"
                        done
                        for file in iso/vyos-*-build2.qcow2.checksum; do
                            mv "$file" "${file%-build2.qcow2.checksum}.checksum"
                        done
                        ls -l iso/
                    '''
                }
                archiveArtifacts artifacts: 'packer-vyos/iso/vyos-*.qcow2, packer-vyos/iso/vyos-*.img, packer-vyos/iso/vyos-*.checksum', allowEmptyArchive: false
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
