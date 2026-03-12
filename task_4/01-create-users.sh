#!/bin/bash
set -e

CLUSTER_NAME=minikube
CA_CERT=~/.minikube/ca.crt
CA_KEY=~/.minikube/ca.key
CERTS_DIR=./certs

mkdir -p ${CERTS_DIR}

declare -A USERS
USERS=(
  [data-analyst]=data
  [devops-user]=devops
  [security-officer]=security
  [crm-developer]=crm-dev
)

for USER in "${!USERS[@]}"; do
  GROUP=${USERS[$USER]}

  echo "=== Создание пользователя: ${USER} (группа: ${GROUP}) ==="

  # 1. Генерация закрытого ключа
  openssl genrsa -out ${CERTS_DIR}/${USER}.key 2048

  # 2. Создание CSR с указанием CN (имя пользователя) и O (группа)
  openssl req -new \
    -key ${CERTS_DIR}/${USER}.key \
    -out ${CERTS_DIR}/${USER}.csr \
    -subj "/CN=${USER}/O=${GROUP}"

  # 3. Подписание сертификата CA кластера
  openssl x509 -req \
    -in ${CERTS_DIR}/${USER}.csr \
    -CA ${CA_CERT} \
    -CAkey ${CA_KEY} \
    -CAcreateserial \
    -out ${CERTS_DIR}/${USER}.crt \
    -days 365

  # 4. Удаление CSR — больше не нужен
  rm -f ${CERTS_DIR}/${USER}.csr

  # 5. Регистрация пользователя в kubeconfig
  kubectl config set-credentials ${USER} \
    --client-certificate=${CERTS_DIR}/${USER}.crt \
    --client-key=${CERTS_DIR}/${USER}.key

  # 6. Создание контекста для пользователя
  kubectl config set-context ${USER}-context \
    --cluster=${CLUSTER_NAME} \
    --user=${USER}

  echo "Пользователь ${USER} создан и добавлен в kubeconfig."
  echo ""
done

echo "=== Все пользователи успешно созданы ==="
echo "Для переключения контекста используйте:"
echo "  kubectl config use-context <имя>-context"