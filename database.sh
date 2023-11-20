az vm run-command invoke  --command-id RunShellScript --name petclinic-backend -g WUS  \
    --scripts 'sudo apt update' \
    'sudo apt upgrade -y' \
    'sudo apt install mysql-server -y' \

echo 'Done.'
