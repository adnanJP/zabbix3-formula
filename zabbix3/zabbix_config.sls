{% set minion_ips = salt.saltutil.runner('mine.get', tgt='*', fun='network.ip_addrs',  tgt_type='glob') %}


{% set web_ips = salt.saltutil.runner('mine.get',tgt='roles:zabbix_web', fun='network.ip_addrs',  tgt_type='grain') %}

###########################
## update admin password ##
###########################
{% for web in web_ips %}

{% set zabbix_web_ip = web_ips[web][0] %}
{% set admin = salt['pillar.get']('zabbix3:configuration:admin') %}

zabbix3_config_user_update_{{ admin.alias }}:
  module.run:
    - name: jp_zabbix.user_update
    - alias: {{ admin.alias }}
    - psswd: {{ admin.psswd }}
    - type: 3
    - usrgrps:
        - usrgrpid: 7
    - force: True
    - connection_args: # optionnel
        connection_user: "admin"
        connection_password: "zabbix"
        connection_url: "http://{{ zabbix_web_ip }}/zabbix"

{% endfor %}

##########################
## add kernel=Liux host ##
##########################
{% set kernel_ips = salt.saltutil.runner('mine.get', tgt='kernel:Linux', fun='network.ip_addrs',  tgt_type='grain') %}

{% for host in kernel_ips %}

zabbix3_config_host_create_{{ host }}:
  module.run:
    - name: jp_zabbix.host_create
    - host: {{ host }}
    - groups:
        - groupid: 2
    - interfaces:
        - type: 1
          main: 1
          useip: 1
          ip: {{ minion_ips[host][0] }}
          dns: ""
          port: 10050

{% endfor %}


#####################
## add/update user ##
#####################
{% for user, param in salt['pillar.get']('zabbix3:configuration:users', {}).iteritems() %}

zabbix3_config_user_create_{{ user }}:
  module.run:
    - name: jp_zabbix.user_create
    - alias: {{ user }}
    - psswd: {{ param.psswd }}
    - type: {{ param.type }}
    - usrgrps:
        - usrgrpid: {{ param.usrgrpid }}

{% endfor %}