gdebi:
  pkg.installed:
    - onlyif:
      - apt-cache show zabbix-agent | grep "Version:" | awk -F ":" '$3 ~ /^3.*$/ { exit 1 }'

/tmp/zabbix-release_3.0-1+trusty_all.deb:
  file.managed:
    - source: salt://zabbix3/files/zabbix-release_3.0-1+trusty_all.deb
    - require:
      - pkg: gdebi
    - onlyif:
      - apt-cache show zabbix-agent | grep "Version:" | awk -F ":" '$3 ~ /^3.*$/ { exit 1 }'

gdebi -n /tmp/zabbix-release_3.0-1+trusty_all.deb:
  cmd.run:
    - require:
      - pkg: gdebi
    - onlyif:
      - apt-cache show zabbix-agent | grep "Version:" | awk -F ":" '$3 ~ /^3.*$/ { exit 1 }'

apt-get update:
  cmd.run:
    - onlyif:
      - apt-cache show zabbix-agent | grep "Version:" | awk -F ":" '$3 ~ /^3.*$/ { exit 1 }'
