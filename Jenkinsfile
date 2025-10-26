pipeline {
    agent any

    parameters {
        // Choose which service(s) to deploy — must match folder names containing Dockerfile + docker-compose.yml
        choice(name: 'SERVICE', choices: ['n8n', 'portainer', 'whoami', 'all'], description: 'Select which stack to deploy')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Target environment')
        choice(name: 'RUN_TYPE', choices: ['Deploy', 'Build and Deploy'], description: 'Deployment type')
    }

    environment {
        INFRA_HOST   = 'infra.example.local'             // Proxmox or hypervisor host
        INFRA_CREDS  = 'infra-api-creds'                 // Jenkins credentials for Proxmox API
        INFRA_NODE   = 'infra-node'                      // Node name in Proxmox
        REGISTRY     = 'registry.example.local:5000'     // Local/private Docker registry
        DOCKER_CREDS = 'registry-creds'                  // Jenkins credentials for registry auth
        VAULT        = 'vault.example.local:8200'        // Vault instance for secrets
        DOCKER_USER  = 'deploy-user'                     // SSH user for Docker host VM
        VMID         = '100'                             // Docker host VM ID in Proxmox
        REMOTE_PATH  = '/opt/containers'                 // Deployment path on target VM
        DISC_USER    = '<@000000000000000000>'           // Discord user mention ID
    }

    stages {

        stage('Confirm Selection') {
            steps {
                echo "Selected stack: ${params.SERVICE}"
            }
        }

        // Builds and pushes Docker images (capsules) to the registry
        stage('Build & Push Docker Images') {
            when { expression { params['RUN_TYPE'] == 'Build and Deploy' } }
            steps {
                script {
                    def targets = (params.SERVICE == 'all') ? ['n8n', 'portainer', 'whoami'] : [params.SERVICE]

                    def envMap = [
                        dev:     [lan_ip: '10.0.0.11'],
                        staging: [lan_ip: '10.0.0.12'],
                        prod:    [lan_ip: '10.0.0.13']
                    ]
                    def selectedEnv = envMap[params.ENVIRONMENT]
                    def LAN_IP = selectedEnv.lan_ip

                    withCredentials([usernamePassword(
                        credentialsId: env.DOCKER_CREDS,
                        usernameVariable: 'REG_USER',
                        passwordVariable: 'REG_PASS'
                    )]) {

                        sh '''
                            echo "$REG_PASS" | docker login -u "$REG_USER" --password-stdin ${REGISTRY}
                        '''

                        def TAG = "build-${env.BUILD_NUMBER}"

                        targets.each { svc ->
                            echo "Building and pushing image for ${svc}..."
                            sh """
                                cd ${svc}
                                docker build --build-arg LAN_IP=${LAN_IP} -t ${REGISTRY}/${svc}:${TAG} -t ${REGISTRY}/${svc}:latest .
                                docker push ${REGISTRY}/${svc}:${TAG}
                                docker push ${REGISTRY}/${svc}:latest
                                cd ..
                            """
                        }

                        sh "docker logout ${REGISTRY}"
                    }
                }
            }
        }

        // Ensure the Docker host VM is powered on via Proxmox API
        stage('Ensure VM is Running') {
            steps {
                echo "Ensuring Docker host VM (${env.VMID}) is running..."
                withCredentials([
                    usernamePassword(
                        credentialsId: env.INFRA_CREDS,
                        usernameVariable: 'PVE_TOKENID',
                        passwordVariable: 'PVE_SECRET'
                    )
                ]) {
                    sh '''
                        echo "Starting VM if not already running..."
                        curl -sk -X POST "https://${INFRA_HOST}:8006/api2/json/nodes/${INFRA_NODE}/qemu/${VMID}/status/start" \
                            -H "Authorization: PVEAPIToken=${PVE_TOKENID}=${PVE_SECRET}" \
                            -H "Content-Type: application/json" \
                            --max-time 30 || true
                    '''
                }
            }
        }

        // Run Trivy image scan (HIGH and CRITICAL severity)
        stage('Security Scan') {
            steps {
                sh """
                    echo "Running Trivy vulnerability scan..."
                    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                        aquasec/trivy:latest image --severity HIGH,CRITICAL --no-progress \
                        ${REGISTRY}/${params.SERVICE}:latest > trivy-report.txt || true
                """
                archiveArtifacts artifacts: 'trivy-report.txt', allowEmptyArchive: true
            }
        }

        // Pulls capsule image, extracts docker-compose.yml, injects secrets, and deploys remotely
        stage('Pull & Deploy') {
            steps {
                script {
                    def envMap = [
                        dev:     [host: 'dev-host.example.local', creds: 'ssh-dev'],
                        staging: [host: 'staging-host.example.local', creds: 'ssh-staging'],
                        prod:    [host: 'prod-host.example.local', creds: 'ssh-prod']
                    ]
                    def selectedEnv = envMap[params.ENVIRONMENT]
                    def targetHost = selectedEnv.host
                    def targetCreds = selectedEnv.creds

                    def lanMap = [
                        dev:     [lan_ip: '10.0.0.11'],
                        staging: [lan_ip: '10.0.0.12'],
                        prod:    [lan_ip: '10.0.0.13']
                    ]
                    def selectedLan = lanMap[params.ENVIRONMENT]
                    def LAN_IP = selectedLan.lan_ip

                    def targets = (params.SERVICE == 'all') ? ['n8n', 'portainer', 'whoami'] : [params.SERVICE]

                    withCredentials([
                        string(credentialsId: 'vault-token', variable: 'VAULT_TOKEN'),
                        usernamePassword(credentialsId: env.DOCKER_CREDS, usernameVariable: 'REG_USER', passwordVariable: 'REG_PASS')
                    ]) {

                        sshagent (credentials: [targetCreds]) {

                            targets.each { svc ->
                                echo "Deploying ${svc} stack on ${targetHost}..."
                                sh """
                                    echo "Fetching secrets from Vault..."
                                    curl -s -H "X-Vault-Token: ${VAULT_TOKEN}" \
                                        http://${env.VAULT}/v1/secret/data/${svc}/${params.ENVIRONMENT} \
                                        | docker run --rm -i imega/jq -r '.data.data | to_entries | .[] | "\\(.key)=\\(.value)"' > .env

                                    echo "Injecting LAN_IP..."
                                    echo "LAN_IP=${LAN_IP}" >> .env

                                    echo "Copying .env to remote host..."
                                    scp -o StrictHostKeyChecking=no .env ${DOCKER_USER}@${targetHost}:${REMOTE_PATH}/${svc}/.env

                                    rm -f .env
                                """

                                sh """
                                    ssh -o StrictHostKeyChecking=no ${DOCKER_USER}@${targetHost} "
                                        set -e
                                        echo 'Logging into registry...'
                                        echo '${REG_PASS}' | docker login -u '${REG_USER}' --password-stdin ${REGISTRY}

                                        echo 'Preparing ${svc} stack...'
                                        mkdir -p ${REMOTE_PATH}/${svc}

                                        echo 'Pulling latest image...'
                                        docker pull ${REGISTRY}/${svc}:latest

                                        echo 'Extracting docker-compose.yml...'
                                        docker run --rm ${REGISTRY}/${svc}:latest cat /app/docker-compose.yml > ${REMOTE_PATH}/${svc}/docker-compose.yml

                                        echo 'Hold my beer, I am deploying.'
                                        cd ${REMOTE_PATH}/${svc}

                                        echo 'Stopping and removing existing containers...'
                                        docker compose down --remove-orphans || true
                                        docker ps -aq --filter \\"label=com.docker.compose.project=${svc}\\" | xargs -r docker rm -f || true

                                        echo 'Pruning stopped containers and dangling images...'
                                        docker container prune -f || true

                                        echo 'Starting stack...'
                                        docker compose up -d
                                        echo '✅ ${svc} deployed successfully.'
                                    "
                                """
                            }
                        }
                    }
                }
            }
        }
    }

    post {

        always {
            sh 'rm -f .env || true'
        }

        success {
            withCredentials([string(credentialsId: 'discord-webhook', variable: 'DISCORD_WEBHOOK_URL')]) {
                script {
                    def duration  = currentBuild.durationString ?: "N/A"
                    def userPing  = env.DISC_USER
                    def timestamp = new Date().format("yyyy-MM-dd HH:mm:ss")

                    def payload = [
                        content: "${userPing}",
                        embeds: [[
                            title: "✅ CapsuleBay Deployment Successful",
                            color: 3066993,
                            fields: [
                                [name: "Service", value: "${params.SERVICE}", inline: true],
                                [name: "Environment", value: "${params.ENVIRONMENT}", inline: true],
                                [name: "Duration", value: "${duration}", inline: false]
                            ],
                            description: "Build [#${BUILD_NUMBER}](${BUILD_URL}) completed successfully.",
                            footer: [text: "Timestamp: ${timestamp}"]
                        ]]
                    ]

                    sh """
                        curl -X POST -H "Content-Type: application/json" \
                             -d '${groovy.json.JsonOutput.toJson(payload)}' \
                             $DISCORD_WEBHOOK_URL
                    """
                }
            }
        }

        failure {
            withCredentials([string(credentialsId: 'discord-webhook', variable: 'DISCORD_WEBHOOK_URL')]) {
                script {
                    def duration  = currentBuild.durationString ?: "N/A"
                    def userPing  = env.DISC_USER
                    def timestamp = new Date().format("yyyy-MM-dd HH:mm:ss")

                    def payload = [
                        content: "${userPing}",
                        embeds: [[
                            title: "❌ CapsuleBay Deployment Failed",
                            color: 15158332,
                            fields: [
                                [name: "Service", value: "${params.SERVICE}", inline: true],
                                [name: "Environment", value: "${params.ENVIRONMENT}", inline: true],
                                [name: "Duration", value: "${duration}", inline: false]
                            ],
                            description: "Build [#${BUILD_NUMBER}](${BUILD_URL}) failed.",
                            footer: [text: "Timestamp: ${timestamp}"]
                        ]]
                    ]

                    sh """
                        curl -X POST -H "Content-Type: application/json" \
                             -d '${groovy.json.JsonOutput.toJson(payload)}' \
                             $DISCORD_WEBHOOK_URL
                    """
                }
            }
        }
    }
}
