zabbix_agent_service:
  service.running:
    - name: zabbix-agent
    - enable: True

zabbix_apache_service:
  service.running:
    - name: apache2
    - enable: True
