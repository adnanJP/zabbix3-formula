zabbix3-install-agent:
  pkg.installed:
    - name: zabbix-agent

zabbix3-install-sender:
  pkg.installed:
    - name: zabbix-sender
