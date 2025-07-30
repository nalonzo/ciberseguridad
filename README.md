# ciberseguridad
Contenedores para implementar un laboratorio de ciberseguridad
# Laboratorio de Pentesting

## Contenedores Desplegados
| Servicio          | URL/Credenciales                     |
|-------------------|--------------------------------------|
| Kali Linux        | `docker exec -it kali_lab bash`      |
| DVWA              | http://localhost:8080 (admin/password) |
| Juice Shop        | http://localhost:3000                |
| WebGoat           | http://localhost:8082/WebGoat        |
| MySQL Vulnerable  | `mysql -h 127.0.0.1 -P 3307 -u root -p` (root/root123) |

## Comandos Útiles
- Reiniciar todo: `./deploy.sh --clean && ./deploy.sh`
- Ver logs: `docker-compose logs -f`
#Conectarse a un docker

docker ps
docker exec -it kali_lab /bin/bash

docker exec -it kali_lab /home/pentester/start.sh
