zabbix_agent_conf:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.conf
    - source: salt://zabbix3/files/zabbix_agentd.conf
    - template: jinja
    - listen_in:
      - service: zabbix_agent_service
    - require:
        - pkg: zabbix3-install-agent

{% if 'webserver' in salt['grains.get']('roles') %}

zabbix_agent_install_zapache:
  file.managed:
    - name: /var/lib/zabbixsrv/externalscripts/zapache
    - source: salt://zabbix3/files/zapache/zapache
    - makedirs: True
    - mode: 0755

zabbix_agent_conf_http-server-status:
  file.managed:
    - name: /etc/apache2/sites-enabled/httpd-server-status.conf
    - source: salt://zabbix3/files/zapache/httpd-server-status.conf.sample
    - mode: 0644
    - listen_in:
      - service: zabbix_apache_service

zabbix_agent_conf_userparameter_zapache:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.d/userparameter_zapache.conf
    - source: salt://zabbix3/files/zapache/userparameter_zapache.conf.sample
    - mode: 0644
    - listen_in:
      - service: zabbix_agent_service
    - require:
        - pkg: zabbix3-install-agent

{% endif %}