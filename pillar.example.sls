{% set minion_ips = salt.saltutil.runner('mine.get', tgt='*', fun='network.ip_addrs',  tgt_type='glob') %}

{% set zabbix_server_id = salt['grains.item']('roles:zabbix_server', 'id', 'grain')['id'] %}
{% set zabbix_web_id = salt['grains.item']('roles:zabbix_web', 'id', 'grain')['id'] %}

{% set zabbix_server_ip = minion_ips[zabbix_server_id][0] %}
{% set zabbix_web_ip = minion_ips[zabbix_web_id][0] %}

zabbix3:
  zabbix_server:
    mysql:
      dbname: zabbix
      dbhost: {{ zabbix_server_ip }}
      dbuser: zabbix
      dbpass: zabbix
      user: root
      grants:
        server_zabbix:
          user: zabbix
          password: zabbix
          grants: all privileges
          host: {{ zabbix_server_ip }}
        server_web:
          user: zabbix
          password: zabbix
          grants: all privileges
          host: {{ zabbix_web_ip }}
  zabbix_web:
    mysql:
      dbname: zabbix
      dbhost: {{ zabbix_server_ip }}
      dbuser: zabbix
      dbpass: zabbix
    zabbix_server:
      host: {{ zabbix_server_ip }}
  zabbix_agent:
    zabbix_server:
      host: {{ zabbix_server_ip }}
  connection_user: admin
  connection_password: zabbix
  connection_url: "http://192.168.107.112/zabbix"
  users:
    super_admin_users:
      alias: admin
      psswd: supermdp1234
      usrgrpid: 7
    AlexandreL:
      psswd: toto1234
      usrgrpid: 7
      type: 3 # 1 = zabbix user; 2 = zabbix admin; 3 = zabbix super admin
      
mine_functions:
  network.ip_addrs: [eth1]
