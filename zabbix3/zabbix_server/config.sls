zabbix_server_mysql_conf:
  file.managed:
    - name: /etc/zabbix/zabbix_server.conf
    - source: salt://zabbix3/files/zabbix_server.conf
    - template: jinja
    - listen_in:
      - service: zabbix_server_service
    - require:
      - pkg: zabbix3-install-server-mysql


###################
### TEMPORAIRE ####
###################
{% for env in salt['grains.get']('environment', {}) %}

{% set dataware = salt['grains.get']('id') %}
{% for job in salt['pillar.get']('zabbix3:zabbix_server:dataware_jobs') %}

/tmp/{{ env }}_{{ job }}_scripts.sh:
  cron.present:
    - user: root
    - minute: '*/1'

zabbix3_config_item_dataware_jobs_{{ env }}_{{ job }}_scripts:
  file.managed:
    - name: /tmp/{{ env }}_{{ job }}_scripts.sh
    - mode: 755
    - contents: |
        #!/usr/bin/env bash
        zabbix_sender -z {{ salt['grains.get']('ip4_interfaces')['eth1'][0] }} -p 10051 -s "{{ dataware }}" -k dataware_{{ env }}_{{ job }} -o "START: $(date '+%D %H:%M:%S')"
        start=`date +%s`
        sleep $(shuf -i 10-20 -n 1)
        end=`date +%s`
        zabbix_sender -z {{ salt['grains.get']('ip4_interfaces')['eth1'][0] }} -p 10051 -s "{{ dataware }}" -k dataware_{{ env }}_{{ job }} -o "END: $(date '+%D %H:%M:%S')"
        zabbix_sender -z {{ salt['grains.get']('ip4_interfaces')['eth1'][0] }} -p 10051 -s "{{ dataware }}" -k dataware_{{ env }}_{{ job }}_time -o $((end-start))
#################

{% endfor %}
{% endfor %}
