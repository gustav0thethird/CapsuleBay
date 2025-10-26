pipeline {
    agent any

    parameters {
        // Update these to show which apps you want to deploy — just make sure the service name matches a folder in your repo
        // Each folder should have a small Dockerfile + docker-compose.yml inside
        choice(name: 'SERVICE', choices: ['n8n', 'portainer', 'whoami', 'all'], description: 'Select which stack to deploy')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Target environment')
        choice(name: 'RUN_TYPE', choices: ['Deploy', 'Build and Deploy'], description: 'Deployment type')
    }

    environment {
        INFRA_HOST     = 'infra.example.local'       // <-- Replace with your Proxmox or hypervisor host/IP
        INFRA_CREDS    = 'infra-api-creds'           // <-- Jenkins credentials ID for Proxmox API token or login
        INFRA_NODE     = 'infra-node'                // <-- Replace with the name of your Proxmox node (e.g. pve01)
        REGISTRY       = 'registry.example.local:5000' // <-- Replace with your local/private Docker registry address
        DOCKER_CREDS   = 'registry-creds'            // <-- Jenkins credentials ID for Docker registry auth
        DOCKER_USER    = 'deploy-user'               // <-- SSH username Jenkins uses to connect to the Docker VM
        VMID           = '100'                       // <-- ID of the VM that hosts your Docker environment in Proxmox
        REMOTE_PATH    = '/opt/containers'           // <-- Path on the Docker VM where stacks should be deployed
        VAULT          = 'vault.example.local:8200'  // <-- Vault instance for secrets (optional)
    }

    stages {

        stage('Confirm Selection') {
            steps {
                echo "Selected stack: ${params.SERVICE}"
            }
        }

        // Builds and pushes the selected Docker images ("capsules") to your local registry
        stage('Build & Push Docker Images') {
            when { expression { params['RUN_TYPE'] == 'Build and Deploy' } }
            steps {
                script {
                    def targets = (params.SERVICE == 'all') ? ['n8n', 'portainer', 'whoami'] : [params.SERVICE]

                    def envMap = [
                        dev:      [lan_ip: '10.0.0.11'],  // <-- Replace with LAN IP for dev environment
                        staging:  [lan_ip: '10.0.0.12'],  // <-- Replace with LAN IP for staging environment
                        prod:     [lan_ip: '10.0.0.13']   // <-- Replace with LAN IP for prod environment
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

                        targets.each { svc ->
                            echo "Building and pushing image for ${svc}..."
                            sh """
                                cd ${svc}
                                docker build --build-arg LAN_IP=${LAN_IP} -t ${REGISTRY}/${svc}:latest .
                                docker push ${REGISTRY}/${svc}:latest
                                cd ..
                            """
                        }

                        sh "docker logout ${REGISTRY}"
                    }
                }
            }
        }

        // Checks Proxmox via API to make sure the target Docker VM is running
        stage('Ensure VM is Running') {
            steps {
                echo "Ensuring Docker host VM (${env.VMID}) is running..."
                withCredentials([
                    usernamePassword(
                        credentialsId: env.INFRA_CREDS,   // <-- Jenkins credentials for Proxmox API
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

        // Pulls the image, extracts its embedded docker-compose.yml, and deploys it via SSH
        stage('Pull & Deploy') {
            steps {
                script {
                    def envMap = [
                        dev:      [host: 'dev-host.example.local', creds: 'ssh-dev'],       // <-- Replace with SSH host + Jenkins credential IDs
                        staging:  [host: 'staging-host.example.local', creds: 'ssh-staging'], // <-- Replace with SSH host + Jenkins credential IDs
                        prod:     [host: 'prod-host.example.local', creds: 'ssh-prod']       // <-- Replace with SSH host + Jenkins credential IDs
                    ]

                    def selectedEnv = envMap[params.ENVIRONMENT]
                    def targetHost  = selectedEnv.host
                    def targetCreds = selectedEnv.creds

                    def lanMap = [
                        dev:      [lan_ip: '10.0.0.11'],
                        staging:  [lan_ip: '10.0.0.12'],
                        prod:     [lan_ip: '10.0.0.13']
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
                                echo "Deploying ${svc} stack on remote host..."
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

                                    echo 'Extracting docker-compose.yml from image...'
                                    docker run --rm ${REGISTRY}/${svc}:latest cat /app/docker-compose.yml > ${REMOTE_PATH}/${svc}/docker-compose.yml
                                    
                                    echo 'Hold my beer, I am deploying.'

                                    cd ${REMOTE_PATH}/${svc}

                                    echo 'Stopping and removing existing containers...'
                                    docker compose down --remove-orphans || true
                                    docker ps -aq --filter \\"label=com.docker.compose.project=${svc}\\" | xargs -r docker rm -f || true
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
        success {
            echo "Deployment of ${params.SERVICE} completed successfully."
        }
        failure {
            echo "Deployment of ${params.SERVICE} failed."
        }
    }
}
