# -*- coding: utf-8 -*-

"""
A wrapper for disk.usage
"""

from pyzabbix import ZabbixAPI
import logging
import json

log = logging.getLogger(__name__)

####################
##      ZAPI      ##
####################

def _get_zapi(connection_user=None,
              connection_password=None,
              connection_url=None):
    log.debug("JP_ZABBIX: _get_zapi : START")
    if not connection_user:
        connection_user = __pillar__['zabbix3']['configuration']['connection_user']
        connection_password = __pillar__['zabbix3']['configuration']['connection_password']
        connection_url = __pillar__['zabbix3']['configuration']['connection_url']

    zapi = ZabbixAPI(connection_url)
    zapi.login(connection_user, connection_password)

    log.debug("JP_ZABBIX: _get_zapi : START")
    return zapi

####################
##      USER      ##
####################

def user_create(alias,
                psswd,
                usrgrps,
                type,
                **connection_args):
    log.debug('JP_ZABBIX : user_create : START')
    zapi = _get_zapi(**connection_args)
    if not user_exists(alias, **connection_args):
        result = 'User Already exists !!'
        try:
            log.debug('try adding user: ' + alias)
            result = zapi.user.create(alias=alias,
                                      passwd=psswd,
                                      usrgrps=usrgrps,
                                      type=type)
        except Exception as e:
            log.error(str(e))
            pass
    else:
        user_update(alias,
                    psswd,
                    usrgrps,
                    type,
                    **connection_args)
    log.debug('JP_ZABBIX : user_create : END')
    return

def user_update(alias,
                psswd,
                usrgrps,
                type,
                force = False,
                **connection_args):
    log.debug('JP_ZABBIX : user_update : START')
    zapi = _get_zapi(**connection_args)
    result = "ERROR"
    if force or user_exists(alias, **connection_args):
        try:
            log.debug('UPDATING user: ' + alias)
            userid = user_get(alias, **connection_args)[0]['userid']
            log.debug("USERID: "+userid)
            result = zapi.user.update(userid=userid,
                                      passwd=psswd,
                                      usrgrps=usrgrps,
                                      type=type)
        except Exception as e:
            log.warning(str(e))
            pass
    log.debug('JP_ZABBIX : user_update : END')
    return

def user_delete(**connection_args):
    log.debug('JP_ZABBIX : user_delete : START')
    zapi = _get_zapi(**connection_args)

    log.debug('JP_ZABBIX : user_delete : END')
    return

def user_exists(user,
                **connection_args):
    log.debug('JP_ZABBIX : user_exists : START')
    zapi = _get_zapi(**connection_args)
    result = []
    try:
        log.debug('Verify if ' + user + " already exists")
        result = zapi.user.get(filter={"alias":[user]})
        log.debug(result)
    except Exception as e:
        log.error(str(e))
        pass
    log.debug("User " + user + " exists?: " + str(len(result) > 0))
    log.debug('JP_ZABBIX : user_exists : END')
    return len(result) > 0

def user_get(user,
             **connection_args):
    log.debug('JP_ZABBIX : user_get : START')
    zapi = _get_zapi(**connection_args)
    result = []
    try:
        log.debug('Verify if ' + user + " already exists")
        result = zapi.user.get(filter={"alias":[user]})
        log.debug(result)
    except Exception as e:
        log.error(str(e))
        pass
    log.debug('JP_ZABBIX : user_get : END')
    return result


####################
##      HOST      ##
####################

def host_create(host,
                groups,
                interfaces,
                **connection_args):
    log.debug('JP_ZABBIX : host_create : START')
    zapi = _get_zapi(**connection_args)
    if not host_exists(host, **connection_args):
        result = 'Host Already exists !!'
        try:
            log.debug('try adding:')
            log.debug(host)
            log.debug(groups)
            log.debug(interfaces)
            result = zapi.host.create(host=host,
                                      groups=groups,
                                      interfaces=interfaces)
        except Exception as e:
            log.error(str(e))
            pass
        log.debug(result)
    log.debug('JP_ZABBIX : host_create : END')

def host_exists(host,
                **connection_args):
    log.debug('JP_ZABBIX : host_exists : START')
    zapi = _get_zapi(**connection_args)
    result = []
    try:
        log.debug('Verify if ' + host + " already exists")
        result = zapi.host.get(filter={"host":[host]})
        log.debug(result)
    except Exception as e:
        log.error(str(e))
        pass
    log.debug("Host " + host + " exists?: " + str(len(result) > 0))
    log.debug('JP_ZABBIX : host_exists : END')
    return len(result) > 0

def host_delete(**connection_args):
    log.debug('JP_ZABBIX : host_delete : START')
    zapi = _get_zapi(**connection_args)

    log.debug('JP_ZABBIX : host_delete : END')
    return

def host_update(**connection_args):
    log.debug('JP_ZABBIX : host_update : START')
    zapi = _get_zapi(**connection_args)

    log.debug('JP_ZABBIX : host_update : END')
    return

def addhost():
    log.debug('JP_ZABBIX.ADDHOST()')
    if __grains__['kernel'] == 'Linux':
        zapi = ZabbixAPI("http://192.168.107.112/zabbix")
        zapi.login("admin", "zabbix")
        log.debug(__grains__['id'])
        log.debug(__grains__['ip4_interfaces']['eth1'][0])
        result = 'ERROR'
        try:
            zapi.host.create(host=__grains__['id'],
                             groups=[{'groupid':2}],
                             interfaces=[{"type": 1,
                                          "main": 1,
                                          "useip": 1,
                                          "ip": __grains__['ip4_interfaces']['eth1'][0],
                                          "dns": "",
                                          "port": "10050"}])
        except Exception as e:
            log.error(str(e))
            pass

def webscenario():
    log.debug('JP_ZABBIX.WEBSCENARIO()')
    if 'webserver' in __grains__['roles']:
        zapi = ZabbixAPI("http://192.168.107.112/zabbix")
        zapi.login("admin", "zabbix")

        urls = __salt__['cmd.shell']("grep -ri '^[^#]*servername' /etc/apache2/sites-available/ | cut -d':' -f2 | awk '{ sub(/.*(S|s)erverName[[:blank:]]*/, \"\"); print }' | sort", out='json')
        log.debug("RESULTAT URLS = ")
        log.debug(json.dumps(urls))
        for u in urls.replace(' ', '').split('\n'):
            try:
                zapi.httptest.create(name=u,
                                     hostid=zapi.host.get(
                                         filter={'host':__grains__['id']}
                                     )[0]['hostid'],
                                     steps=[{'name':"home page",
                                             'url':'http://'+u,
                                             'status_codes':200,
                                             'no':1}])
            except Exception as e:
                log.error(str(e))
                pass
        return urls.replace(' ', '').split('\n')
        #return zapi.host.get(filter={host:['webdev-01']}

    return ''
