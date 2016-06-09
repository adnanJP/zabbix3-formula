{% set minion_ips = salt.saltutil.runner('mine.get', tgt='*', fun='network.ip_addrs',  tgt_type='glob') %}

{% set linux_ips = salt.saltutil.runner('mine.get', tgt='kernel:Linux', fun='network.ip_addrs',  tgt_type='grain') %}

{% set windows_ips = salt.saltutil.runner('mine.get', tgt='kernel:Windows', fun='network.ip_addrs',  tgt_type='grain') %}


{% set web_ips = salt.saltutil.runner('mine.get',tgt='roles:zabbix_web', fun='network.ip_addrs',  tgt_type='grain') %}
{% set server_ips = salt.saltutil.runner('mine.get',tgt='roles:zabbix_server', fun='network.ip_addrs',  tgt_type='grain') %}

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

##########################
## update Zabbix Server ##
##########################
{% for srv in server_ips %}
{% set zabbix_server_ip = server_ips[srv][0] %}

zabbix3_config_host_enable_Zabbix server:
  module.run:
    - name: jp_zabbix.host_enable
    - host: "Zabbix server"  
    - kwargs:
        status: 0
        ip: {{ zabbix_server_ip }}

{% endfor %}

##############
## TEMPLATE ##
##############

## Template OS Linux
zabbix_config_template_link_Template OS Linux:
  module.run:
    - name: jp_zabbix.template_massadd
    - templatename: "Template OS Linux"
    - hostnames:
{% for id in linux_ips %}
        - {{ id }}
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

{% if param.sendto is defined %}
zabbix3_config_user_addmedia_{{ user }}:
  module.run:
    - name: jp_zabbix.user_addmedia
    - alias: {{ user }}
    - kwargs:
        medias:
          mediatypeid: "1"
          sendto: "{{ param.sendto }}"
          active: "0"
          severity: "63"
          period: "1-7,00:00-24:00"
    - require:
      - module: zabbix3_config_user_create_{{ user }}
{% endif %}

{% endfor %}


###########
## MEDIA ##
###########
zabbix3_config_media_disable_jabber:
  module.run:
    - name: jp_zabbix.mediatype_update
    - kwargs:
        mediatypeid: 2
        status: 1

zabbix3_config_media_disable_sms:
  module.run:
    - name: jp_zabbix.mediatype_update
    - kwargs:
        mediatypeid: 3
        status: 1


zabbix3_config_media_mail:
  module.run:
    - name: jp_zabbix.mediatype_update
    - kwargs:
        mediatypeid: 1
        smtp_port: 587
        smtp_server: auth.smtp.1and1.fr
        smtp_email: send1@johnpaul.com
        smtp_helo: johnpaul.com
        smtp_authentication: 1
        smtp_username: send1@johnpaul.com
        username: send1@johnpaul.com
        passwd: 1234567

############
## ACTION ##
############

zabbix3_config_action_enable:
  module.run:
    - name: jp_zabbix.action_update
    - kwargs:
        actionid: 3
        status: 0
