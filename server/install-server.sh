#!/bin/bash

N1=$'\n'

# Make repo dir
mkdir -p /root/repo

# Download rest-server and install
cd /root
wget https://github.com/restic/rest-server/releases/download/v0.10.0/rest-server_0.10.0_linux_amd64.tar.gz

if [[ ! -f /root/rest-server_0.10.0_linux_amd64.tar.gz ]];then
    rm rest-server_0.10.0_linux_amd64.tar.gz
fi

tar zxfv rest-server_0.10.0_linux_amd64.tar.gz
mv rest-server_0.10.0_linux_amd64/rest-server /usr/local/bin
rm -rf rest-server_0.10.0_linux_amd64

cp OT-Smoothbrain-Backup/server/rest-server.service /lib/systemd/system/

echo "Installing daily clean-up cronjob at noon servertime"
(crontab -l 2>/dev/null; echo "0 12 * * * /root/OT-Smoothbrain-Backup/restic-cleanup.sh") | crontab -


# Download additional tools

apt install apache2-utils apg -y

# Create certificate

read -p "Would you like to create a certificate for the server to encrypt the login credentials? Enter y/n: " ANSWER
if [[ $ANSWER == "y" ]]; then

    read -p "Enter the FULL domain name for the backup server: " DOMAIN_NAME

    if [[ -f /root/private_key ]]; then

        echo "Deleting existing keys"
        rm /root/private_key
        rm /root/public_key
        rm -rf /etc/letsencrypt/live/$DOMAIN_NAME*
        rm -rf /etc/letsencrypt/archive/$DOMAIN_NAME*
        rm -rf /etc/letsencrypt/renewal/$DOMAIN_NAME*
    fi

    ufw allow 80 && ufw allow 443 && ufw allow 8000 && yes | ufw enable

    apt install software-properties-common -y
    add-apt-repository universe
    apt update && apt install certbot -y

    certbot certonly --standalone -d $DOMAIN_NAME

    cp /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem /root/private_key
    cp /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem /root/public_key

    ufw delete allow 80 && ufw delete allow 443
else
    read -p "What is the IP address for the backup server: " IP_ADDRESS
    sed -i 's|ExecStart=/usr/local/bin/rest-server --path /root --tls|ExecStart=/usr/local/bin/rest-server --path /root|' /lib/systemd/system/rest-server.service
fi

# Create user account

USER=$(apg -a 1 -m 32 -n 1 -M NCL)
PASS=$(apg -a 1 -m 32 -n 1 -M NCL)

echo "${N1}****************************************"
echo "Creating user account and pass.."
echo "User: $USER"
echo "Pass: $PASS"
echo "These credentials will be in /root/smoothbrain-server-credentials"
echo "****************************************${N1}"
echo "User: $USER" >> /root/smoothbrain-server-credentials
echo "Pass: $PASS" >> /root/smoothbrain-server-credentials

if [[ -f /root/.htpasswd ]];then
    rm /root/.htpasswd
    htpasswd -B -c -b .htpasswd $USER $PASS
else
    htpasswd -B -c -b .htpasswd $USER $PASS
fi

systemctl daemon-reload

echo "Enabling backup server on boot${N1}"
systemctl enable rest-server

echo "Starting backup server${N1}"
systemctl start rest-server

echo "Installation is complete! Edit the RESTIC_REPOSITORY line on each of your servers /root/OT-Settings/config.sh to the following:${N1}"
if [[ $ANSWER == "y" ]];then
    echo "RESTIC_REPOSITORY="rest:https://$USER:$PASS@$DOMAIN_NAME:8000/repo${N1}""
else
    echo "RESTIC_REPOSITORY="rest:http://$USER:$PASS@$IP_ADDRESS:8000/repo${N1}""
fi