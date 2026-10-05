\# Terraform Playbook: Nginx + Network Load Balancer в Yandex Cloud



\## 📋 Описание задания



С помощью Terraform создать в Yandex Cloud:

\- 2 идентичные виртуальные машины с Nginx (через аргумент `count = 2`);

\- целевую группу, в которую помещены обе ВМ;

\- сетевой балансировщик нагрузки, слушающий порт 80, отправляющий трафик на порт 80 ВМ и выполняющий HTTP healthcheck на порт 80.



\## 📁 Структура проекта



```

terraform-yc-lb/

├── provider.tf      # Провайдер Yandex Cloud

├── variables.tf     # Переменные (токен, cloud\_id, folder\_id)

├── terraform.tfvars # Значения переменных (не в Git!)

├── main.tf          # Описание инфраструктуры

├── outputs.tf       # Вывод IP балансировщика

├── .gitignore       # Исключения для Git

└── screenshots/     # Скриншоты для отчёта

```



\## 🚀 Запуск



```bash

terraform init

terraform plan

terraform apply

```



\## 🔍 Проверка



```bash

\# Запрос к балансировщику

curl http://158.160.209.102

```



\## 🛠️ Используемые ресурсы Terraform



| Ресурс | Назначение |

|--------|------------|

| `yandex\_vpc\_network` | Сеть |

| `yandex\_vpc\_subnet` | Подсеть в зоне `ru-central1-a` |

| `yandex\_vpc\_security\_group` | Security Group с правилами для портов 22 и 80 |

| `yandex\_compute\_instance.web` | 2 ВМ с Nginx (аргумент `count = 2`) |

| `yandex\_lb\_target\_group` | Целевая группа с обеими ВМ |

| `yandex\_lb\_network\_load\_balancer` | Сетевой балансировщик на порту 80 с HTTP healthcheck |



\## 📸 Скриншоты



\### 1. Сетевой балансировщик `nginx-network-balancer` в статусе Active



!\[Статус балансировщика Active](screenshots/lb-active.png)



\### 2. Целевая группа `nginx-target-group`: обе ВМ в статусе Healthy



!\[Целевая группа Healthy](screenshots/target-group-healthy.png)



\### 3. Настройки healthcheck балансировщика



!\[Healthcheck балансировщика](screenshots/lb-healthcheck.png)



\### 4. Ответ Nginx через балансировщик (VM-1)



!\[Страница Nginx VM-1](screenshots/nginx-page1.png)



\### 5. Ответ Nginx через балансировщик (VM-2)



!\[Страница Nginx VM-2](screenshots/nginx-page2.png)



\## ✅ Результаты



\- Балансировщик \*\*`nginx-network-balancer`\*\* — статус \*\*Active\*\*;

\- Обе ВМ в целевой группе — статус \*\*Healthy\*\*;

\- Nginx успешно установлен и работает на порту 80 на обеих ВМ;

\- Балансировщик распределяет трафик между двумя ВМ: при обращении к `http://158.160.209.102` поочерёдно отдаются страницы `Welcome to Nginx-VM-1!` и `Welcome to Nginx-VM-2!`.



\## 💡 Примечания



\- В образе Ubuntu 18.04 LTS предустановлен Apache2, который занимает порт 80. В `user-data` добавлена его остановка, также выполнено ручное удаление пакета (`sudo apt-get remove --purge -y apache2`).

\- Сетевой балансировщик Yandex Cloud работает на 4-м уровне модели OSI (TCP), поэтому при использовании HTTP keep-alive все запросы от одного клиента могут идти на одну и ту же ВМ. Для проверки распределения нужно закрывать TCP-соединение после каждого запроса (`curl -H "Connection: close"`).

\- Для просмотра актуальной страницы в браузере используйте режим инкогнито или добавляйте параметр к URL (`?v=1`), чтобы обойти кеш.

