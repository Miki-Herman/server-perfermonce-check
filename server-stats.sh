#!/bin/bash

# connects to any server via ssh
echo "#############################################"
echo "Welcome to remote server performance checker!"
echo "#############################################"

read -r -p "Please enter username: " USER
read -r -p "Please enter host name or ip: " HOST
read -r -p "Please enter server port: " PORT
read -r -sp "Please enter password: " PASSWORD

echo "Connecting to remote server..."
# connect via sshpass
sshpass -p "$PASSWORD" ssh -p $PORT "$USER@$HOST" << EOF
echo "Running commands remotely..."

# Checks for needed tools to display server statistics
if ! command -v sshpass; then
  echo "sshpass is not installed!"
  echo "Installing sshpass"
  sudo apt-get install sshpass
fi

if ! command -v mpstat; then
  echo "sysstat is not installed!"
  echo "Installing sysstat..."
fi


# Get CPU usage remotely
mpstat | tail -n 1 | awk -F " " '{printf "CPU Usage: %.2f%%\n", 100 - \$12}'

# Get memory usage remotely
free | sed -n "2 p" | awk -F " " '{printf "MEM Usage: %.2f%%\n", \$3/\$2 * 100}'

# Get memory free remotely
free | sed -n "2 p" | awk -F " " '{printf "MEM Free: %.2f%%\n", \$4/\$2 * 100}'

# Get disk usage remotely
df -h / | tail -n 1 | awk -F " " '{gsub("%", "", \$5); printf "Disk Free: %.2f%%\n", \$5 }'
df -h / | tail -n 1 | awk -F " " '{gsub("%", "", \$5); printf "Disk Free: %.2f%%\n", 100 - \$5 }'

echo "Top CPU Usage:"
for i in {2..7};do
  ps aux --sort=-%cpu| sed -n "\$i p"| awk -F " " '{printf "Process num %s: CPU Usage: %.2f%%\n", \$11, \$3}'
done

echo "Top Memory Usage:"
for i in {2..7};do
  ps aux --sort=-%mem| sed -n "\$i p"| awk -F " " '{printf "Process %s: Usage: %.2f%%\n", \$11, \$4}'
done

echo "Done..."
EOF
