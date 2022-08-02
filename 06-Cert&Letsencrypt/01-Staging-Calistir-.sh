#!/bin/bash
echo "Staging TLS Calistirmaya Başlıyorum :)"

sleep 1
echo ""
kubectl apply -f ./01-Techakademi/01-Staging/01-Cluster-Issuer-Staging.yml -f ./01-Techakademi/01-Staging/02-Staging-Sertifika.yml -f ./01-Techakademi/01-Staging/03-Ithost-Stack-Staging.yml
sleep 1

echo ""
kubectl apply -f ./02-Merhaba-Dunya/01-Staging/01-Cluster-Issuer-Staging.yml -f ./02-Merhaba-Dunya/01-Staging/02-Staging-Sertifika.yml -f ./02-Merhaba-Dunya/01-Staging/03-Merhaba-Stack-Staging.yml
sleep 1

echo ""
kubectl apply -f ./03-Whoami/01-Staging/01-Cluster-Issuer-Staging.yml -f ./03-Whoami/01-Staging/02-Staging-Sertifika.yml -f ./03-Whoami/01-Staging/03-Whoami-Stack-Staging.yml
sleep 1

echo ""
kubectl apply -f ./04-Rancher/01-Staging/01-Cluster-Issuer-Staging.yml -f ./04-Rancher/01-Staging/02-Staging-Sertifika.yml -f ./04-Rancher/01-Staging/03-Rancher-Stack-Staging.yml
sleep 1

echo ""
kubectl apply -f ./05-Havadurumu/01-Staging/01-Cluster-Issuer-Staging.yml -f ./05-Havadurumu/01-Staging/02-Staging-Sertifika.yml -f ./05-Havadurumu/01-Staging/03-Havadurumu-Stack-Staging.yml
sleep 1

echo ""
kubectl apply -f ./06-Cldzone/01-Staging/01-Cluster-Issuer-Staging.yml -f ./06-Cldzone/01-Staging/02-Staging-Sertifika.yml -f ./06-Cldzone/01-Staging/03-Cldzone-Stack-Staging.yml
sleep 1

echo "Calisma Tamamlandı :)"