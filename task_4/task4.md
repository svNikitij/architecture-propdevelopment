| Роль | Тип | Права | Группы пользователей | Обоснование |
| :--- | :--- | :--- | :--- | :--- |
| cluster-viewer | ClusterRole | get, list, watch на все ресурсы во всех namespace | Аналитики (data), Аудиторы | Принцип минимальных привилегий: read-only для мониторинга |
| cluster-operator | ClusterRole | CRUD на pods, deployments, services, replicasets, statefulsets, daemonsets, configmaps, PVC, ingresses; read-only на events, namespaces | DevOps-инженеры (devops) | Управление развёртыванием без доступа к секретам и RBAC |
| secrets-reader | Role (ns: prod) | get, list, watch на secrets только в namespace prod | Офицеры безопасности (security) | Контролируемый доступ к секретам в среде с ПДн (п. I.6, II.1 проверочного листа) |
| crm-namespace-developer | Role (ns: crm) | CRUD на pods, deployments, services, replicasets, configmaps; read на pods/log в namespace crm | Разработчики CRM (crm-dev) | Организационное разграничение по подразделениям PropDevelopment |
| cluster-admin (встроенная) | ClusterRole | Полный доступ ко всем ресурсам | Системные администраторы | Используется встроенная роль Kubernetes, не пересоздаётся |