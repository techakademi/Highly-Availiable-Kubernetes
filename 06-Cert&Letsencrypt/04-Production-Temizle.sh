#!/bin/bash
echo "Production TLS Calistirmaya Başlıyorum :)"

sleep 1
echo ""
kubectl delete -f ./01-Techakademi/02-Production/01-Cluster-Issuer-Production.yml -f ./01-Techakademi/02-Production/02-Production-Sertifika.yml -f ./01-Techakademi/02-Production/03-Ithost-Production-Middleware-Stack.yml
sleep 1

echo ""
kubectl delete -f ./02-Merhaba-Dunya/02-Production/01-Cluster-Issuer-Production.yml -f ./02-Merhaba-Dunya/02-Production/02-Production-Sertifika.yml -f ./02-Merhaba-Dunya/02-Production/03-Merhaba-Production-Middleware-Stack.yml
sleep 1

echo ""
kubectl delete -f ./03-Whoami/02-Production/01-Cluster-Issuer-Production.yml -f ./03-Whoami/02-Production/02-Production-Sertifika.yml -f ./03-Whoami/02-Production/03-Whoami-Production-Middleware-Stack.yml
sleep 1

echo ""
kubectl delete -f ./04-Rancher/02-Production/01-Cluster-Issuer-Production.yml -f ./04-Rancher/02-Production/02-Production-Sertifika.yml -f ./04-Rancher/02-Production/03-Rancher-Production-Middleware-Stack-.yml
sleep 1

echo ""
kubectl delete -f ./05-Havadurumu/02-Production/01-Cluster-Issuer-Production.yml -f ./05-Havadurumu/02-Production/02-Production-Sertifika.yml -f ./05-Havadurumu/02-Production/03-Havadurumu-Production-Middleware-Stack.yml
sleep 1

echo ""
kubectl delete -f ./06-Cldzone/02-Production/01-Cluster-Issuer-Production.yml -f ./06-Cldzone/02-Production/02-Production-Sertifika.yml -f ./06-Cldzone/02-Production/03-Cldzone-Production-Middleware-Stack.yml
sleep 1

echo "Calisma Tamamlandı :)"