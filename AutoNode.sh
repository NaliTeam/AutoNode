#!/bin/bash

while true; do
    echo "Do you want to add a new node to Marzban? (Y/N)"
    read choice

    if [ "$choice" == "Y" ] || [ "$choice" == "y" ]; then
        echo "Enter the IP address of the node server:"
        read ip_address

        echo "Enter the certificate of the node in marzban panel. Press Ctrl+D 2 time when finished:"
        # Read the multiline certificate content from the user
        cert_content=$(</dev/stdin)

        # Connect to the server and perform operations
        ssh -o StrictHostKeyChecking=no -o "UserKnownHostsFile=/dev/null" root@$ip_address "
            apt install socat -y && apt install curl socat -y && apt install git -y

            git clone https://github.com/Gozargah/Marzban-node

            cd Marzban-node

            curl -fsSL https://get.docker.com | sh

            docker compose up -d

            # Create the SSL_CLIENT_CERT_FILE if it doesn't exist
            sudo touch /var/lib/marzban-node/ssl_client_cert.pem

            # Uncomment the SSL_CLIENT_CERT_FILE line in the file (if commented)
            sed -i 's/^ *# *SSL_CLIENT_CERT_FILE/      SSL_CLIENT_CERT_FILE/' /root/Marzban-node/docker-compose.yml
            
            # Write the user input into the ssl_client_cert.pem file
            echo \"$cert_content\" | sudo tee /var/lib/marzban-node/ssl_client_cert.pem > /dev/null

            cd /root/Marzban-node
            docker compose restart
        "

        echo "Node addition process completed."
    elif [ "$choice" == "N" ] || [ "$choice" == "n" ]; then
        echo "No new node will be added. Exiting..."
        break
    else
        echo "Invalid choice. Please enter Y/y or N/n."
    fi
done
