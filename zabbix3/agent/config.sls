zabbix_agent_conf:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.conf
    - source: salt://zabbix3/files/zabbix_agentd.conf
    - template: jinja
    - listen_in:
      - service: zabbix_agent_service