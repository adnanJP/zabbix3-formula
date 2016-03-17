{% set zabbix3 = salt['pillar.get']('zabbix3') %}

zabbix3_database_present:
  mysql_database.present:
    - name: {{ salt['pillar.get']('zabbix3.mysql.dbname', 'zabbix') }}
    - connection_user: {{ zabbix3.mysql.user }}
    - connection_pass: {{ zabbix3.mysql.pass }}

{% for srv, config in salt['pillar.get']('zabbix3:mysql:grants', {}).iteritems() %}
zabbix3_mysql_user_{{ srv }}:
  mysql_user.present:
    - name: {{ config.user }}
    - host: {{ config.host }}
    - password: {{ config.password }}
    - connection_user: {{ zabbix3.mysql.user }}
    - connection_pass: {{ zabbix3.mysql.pass }}

zabbix_mysql_grants_{{ srv }}:
  mysql_grants.present:
    - grant: {{ config.grants }}
    - database: '{{ salt['pillar.get']('zabbix3.mysql.dbname', 'zabbix') }}.*'
    - user: {{ config.user }}
    - host: {{ config.host }}
    - connection_user: {{ zabbix3.mysql.user }}
    - connection_pass: {{ zabbix3.mysql.pass }}
    - require:
      - mysql_user: zabbix3_mysql_user_{{ srv }}

{% endfor %}

zabbix3_mysql_filedb:
  file.managed:
    - name: /tmp/zabbix.sql.gz
    - source: {{ salt['pillar.get']('zabbix3:mysql:database_path', 'salt://zabbix3/files/create.sql.gz') }}
    - onchanges:
      - mysql_database: zabbix3_database_present

zabbix3_create_database:
  cmd.run:
    - name: |
        zcat /tmp/zabbix.sql.gz | mysql -u{{ zabbix3.mysql.user }} -p{{ zabbix3.mysql.pass }} zabbix
        rm /tmp/zabbix.sql.gz
    - onchanges:
      - file: zabbix3_mysql_filedb

zabbix3_mysql_conf:
  file.replace:
    - name: /etc/mysql/my.cnf
    - pattern: "bind-address.*"
    - repl: "bind-address = 0.0.0.0"
    - listen_in:
      - service: zabbix_mysql_service
    - require:
      - cmd: zabbix3_create_database

zabbix_mysql_service:
  service.running:
    - name: mysql
    - enable: True
