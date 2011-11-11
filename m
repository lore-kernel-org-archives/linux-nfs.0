Return-Path: linux-nfs-owner@vger.kernel.org
Received: from forward7.mail.yandex.net ([77.88.61.37]:34427 "EHLO
	forward7.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756777Ab1KKM2C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Nov 2011 07:28:02 -0500
Received: from smtp7.mail.yandex.net (smtp7.mail.yandex.net [77.88.61.55])
	by forward7.mail.yandex.net (Yandex) with ESMTP id 427601C5819
	for <linux-nfs@vger.kernel.org>; Fri, 11 Nov 2011 16:28:00 +0400 (MSK)
Content-Type: text/plain; charset=koi8-r; format=flowed; delsp=yes
Cc: maxim@kramarenko.pro
To: linux-nfs@vger.kernel.org
Date: Fri, 11 Nov 2011 16:27:59 +0400
Subject: error rpc.gssd: No supported encryption types (config file error?)
MIME-Version: 1.0
From: "Kramarenko A. Maksim " <maxim@kramarenko.pro>
Message-ID: <op.v4r7kxgeyb2atr@odmen.sag.local>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!
Tired of fighting with a bunch of Kerberos and NFSv4. Very much I ask for help!

My configuration:
OS:  Server NFS (also known as a client) - Debian 6.0.3, KDC - AD Win2k8 R2.

Server/Client NFS:
ARCHIV ~ # hostname -f
archiv.SAG.local
ARCHIV ~ # grep -v "^#" /etc/krb5.conf
[libdefaults]
         default_realm = SAG.LOCAL
         default_tkt_enctypes = rc4-hmac
         default_tgs_enctypes = rc4-hmac
         permitted_enctypes = rc4-hmac

[realms]

         SAG.LOCAL = {
                 kdc = dc.sag.local
                 admin_server = dc.sag.local
                 default_domain = SAG.LOCAL
         }

[domain_realm]
         .sag.local = SAG.LOCAL
         sag.local = SAG.LOCAL

[logging]
         default = SYSLOG:NOTICE:DAEMON

ARCHIV ~ # dpkg -l | grep krb
ii  krb5-config                        2.2                          Configuration files for Kerberos Version 5
ii  krb5-user                          1.8.3+dfsg-4squeeze2         Basic programs to authenticate using MIT Kerberos
ii  libgssapi-krb5-2                   1.8.3+dfsg-4squeeze2         MIT Kerberos runtime libraries - krb5 GSS-API Mechanism
ii  libkrb5-3                          1.8.3+dfsg-4squeeze2         MIT Kerberos runtime libraries
ii  libkrb53                           1.8.3+dfsg-4squeeze2         transitional package for MIT Kerberos libraries
ii  libkrb5support0                    1.8.3+dfsg-4squeeze2         MIT Kerberos runtime libraries - Support library
ARCHIV ~ # ping -c 4 archiv
PING archiv.SAG.local (10.0.0.6) 56(84) bytes of data.
64 bytes from archiv.SAG.local (10.0.0.6): icmp_req=1 ttl=64 time=0.032 ms
64 bytes from archiv.SAG.local (10.0.0.6): icmp_req=2 ttl=64 time=0.011 ms
64 bytes from archiv.SAG.local (10.0.0.6): icmp_req=3 ttl=64 time=0.011 ms
64 bytes from archiv.SAG.local (10.0.0.6): icmp_req=4 ttl=64 time=0.011 ms

--- archiv.SAG.local ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 2998ms
rtt min/avg/max/mdev = 0.011/0.016/0.032/0.009 ms
ARCHIV ~ # ps xuwa | grep  rpc.
root       905  0.0  0.0      0     0 ?        S    13:06   0:00 [rpciod/0]
root       906  0.0  0.0      0     0 ?        S    13:06   0:00 [rpciod/1]
root      2064  0.0  0.0   3144  1312 ?        Ss   14:20   0:00 /usr/sbin/rpc.svcgssd -vvv
root      2066  0.0  0.0   2108   352 ?        Ss   14:20   0:00 /usr/sbin/rpc.mountd --manage-gids
root      2208  0.0  0.0   2272   520 ?        Ss   14:28   0:00 /usr/sbin/rpc.idmapd
root      2213  0.0  0.0   3112   664 ?        Ss   14:28   0:00 /usr/sbin/rpc.gssd -vvv
root      2222  0.0  0.0   3324   816 pts/0    R+   14:29   0:00 grep --colour=auto rpc.

# Daemons rpc.gssd and rpc.svcgssd with the "-vvv" option running.

ARCHIV ~ # klist -e -k /etc/krb5.keytab
Keytab name: WRFILE:/etc/krb5.keytab
KVNO Principal
---- --------------------------------------------------------------------------
    3 nfs/archiv.sag.local@SAG.LOCAL (DES cbc mode with CRC-32)
    3 nfs/archiv.sag.local@SAG.LOCAL (DES cbc mode with RSA-MD5)
    3 nfs/archiv.sag.local@SAG.LOCAL (ArcFour with HMAC/md5)
    3 nfs/archiv.sag.local@SAG.LOCAL (AES-256 CTS mode with 96-bit SHA-1 HMAC)
    3 nfs/archiv.sag.local@SAG.LOCAL (AES-128 CTS mode with 96-bit SHA-1 HMAC)
ARCHIV ~ # kinit -k nfs/archiv.sag.local@SAG.LOCAL
ARCHIV ~ # klist
Ticket cache: FILE:/tmp/krb5cc_0
Default principal: nfs/archiv.sag.local@SAG.LOCAL

Valid starting     Expires            Service principal
11/11/11 16:12:56  11/12/11 02:12:56  krbtgt/SAG.LOCAL@SAG.LOCAL
         renew until 11/12/11 16:12:56

Using keytab, Kerberos tickets are obtained correctly
The list of exported directories:
ARCHIV ~ # cat /etc/exports
/archiv-big     gss/krb5(rw,fsid=0,sync,no_subtree_check)
ARCHIV ~ # showmount -e
Export list for ARCHIV:
/archiv-big gss/krb5

Server KDC:
On KDC to create the computer account - "archiv" and user account - nfs. And the created keytab:

ktpass /princ nfs/archiv.sag.local@SAG.LOCAL /ptype KRB5_NT_PRINCIPAL /out C:\tmp\archivkeytab /pass mypass /crypto all /mapuser SAG\nfs

And secur transfer to host archiv in file /etc/krb5.keytab .

Problem:
When I try to mount the directory on NFSV4 - I do not get:
ARCHIV ~ # mount -v -t nfs4 -o'sec=krb5' archiv:/archiv-big /mnt
mount.nfs4: timeout set for Fri Nov 11 16:23:57 2011
mount.nfs4: trying text-based options 'sec=krb5,addr=10.0.0.6,clientaddr=10.0.0.6'
mount.nfs4: mount(2): Permission denied
mount.nfs4: access denied by server while mounting archiv:/archiv-big



At this point, the daemon rpc.gssd sends to a log daemon.log messages here are:


Nov 11 16:21:35 archiv mountd[2066]: Caught signal 15, un-registering and exiting.
Nov 11 16:21:35 archiv rpc.svcgssd[2064]: exiting on signal 15
Nov 11 16:21:36 archiv rpc.svcgssd[2386]: rpcsec_gss: debug level is 3
Nov 11 16:21:36 archiv rpc.svcgssd[2387]: entering poll
Nov 11 16:21:57 archiv rpc.gssd[2213]: handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt18)
Nov 11 16:21:57 archiv rpc.gssd[2213]: handle_gssd_upcall: 'mech=krb5 uid=0 '
Nov 11 16:21:57 archiv rpc.gssd[2213]: handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt18)
Nov 11 16:21:57 archiv rpc.gssd[2213]: process_krb5_upcall: service is '<null>'
Nov 11 16:21:57 archiv rpc.gssd[2213]: Full hostname for 'archiv.SAG.local' is 'archiv.sag.local'
Nov 11 16:21:57 archiv rpc.gssd[2213]: Full hostname for 'archiv.sag.local' is 'archiv.sag.local'
Nov 11 16:21:57 archiv rpc.gssd[2213]: Key table entry not found while getting keytab entry for 'root/archiv.sag.local@SAG.LOCAL'
Nov 11 16:21:57 archiv rpc.gssd[2213]: Success getting keytab entry for 'nfs/archiv.sag.local@SAG.LOCAL'
Nov 11 16:21:57 archiv rpc.gssd[2213]: INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_SAG.LOCAL' are good until 1321043604
Nov 11 16:21:57 archiv rpc.gssd[2213]: INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_SAG.LOCAL' are good until 1321043604
Nov 11 16:21:57 archiv rpc.gssd[2213]: using FILE:/tmp/krb5cc_machine_SAG.LOCAL as credentials cache for machine creds
Nov 11 16:21:57 archiv rpc.gssd[2213]: using environment variable to select krb5 ccache FILE:/tmp/krb5cc_machine_SAG.LOCAL
Nov 11 16:21:57 archiv rpc.gssd[2213]: creating context using fsuid 0 (save_uid 0)
Nov 11 16:21:57 archiv rpc.gssd[2213]: creating tcp client for server archiv.SAG.local
Nov 11 16:21:57 archiv rpc.gssd[2213]: DEBUG: port already set to 2049
Nov 11 16:21:57 archiv rpc.gssd[2213]: creating context with server nfs@archiv.SAG.local
Nov 11 16:21:57 archiv rpc.gssd[2213]: in authgss_create_default()
Nov 11 16:21:57 archiv rpc.gssd[2213]: in authgss_create()
Nov 11 16:21:57 archiv rpc.gssd[2213]: authgss_create: name is 0x81dfa70
Nov 11 16:21:57 archiv rpc.gssd[2213]: authgss_create: gd->name is 0x81e23d8
Nov 11 16:21:57 archiv rpc.gssd[2213]: in authgss_refresh()
Nov 11 16:21:57 archiv rpc.gssd[2213]: struct rpc_gss_sec:
Nov 11 16:21:57 archiv rpc.gssd[2213]:      mechanism_OID: { 1 2 134 72 134 247 18 1 2 2 }
Nov 11 16:21:57 archiv rpc.gssd[2213]:      qop: 0
Nov 11 16:21:57 archiv rpc.gssd[2213]:      service: 1
Nov 11 16:21:57 archiv rpc.gssd[2213]:      cred: 0x81dff88
Nov 11 16:21:57 archiv rpc.gssd[2213]:      req_flags: 00000002
Nov 11 16:21:57 archiv rpc.gssd[2213]: rpcsec_gss: gss_init_sec_context: (major) Unspecified GSS failure.  Minor code may provide more information - (minor) No supported encryption types (config file error?)
Nov 11 16:21:57 archiv rpc.gssd[2213]: in authgss_destroy()
Nov 11 16:21:57 archiv rpc.gssd[2213]: in authgss_destroy_context()
Nov 11 16:21:57 archiv rpc.gssd[2213]: authgss_destroy: freeing name 0x81e23d8
Nov 11 16:21:57 archiv rpc.gssd[2213]: authgss_create_default: freeing name 0x81dfa70
Nov 11 16:21:57 archiv rpc.gssd[2213]: WARNING: Failed to create krb5 context for user with uid 0 for server archiv.SAG.local
Nov 11 16:21:57 archiv rpc.gssd[2213]: WARNING: Failed to create machine krb5 context with credentials cache FILE:/tmp/krb5cc_machine_SAG.LOCAL for server archiv.SAG.local
Nov 11 16:21:57 archiv rpc.gssd[2213]: WARNING: Machine cache is prematurely expired or corrupted trying to recreate cache for server archiv.SAG.local
Nov 11 16:21:57 archiv rpc.gssd[2213]: Full hostname for 'archiv.SAG.local' is 'archiv.sag.local'
Nov 11 16:21:57 archiv rpc.gssd[2213]: Full hostname for 'archiv.sag.local' is 'archiv.sag.local'
Nov 11 16:21:57 archiv rpc.gssd[2213]: Key table entry not found while getting keytab entry for 'root/archiv.sag.local@SAG.LOCAL'
Nov 11 16:21:57 archiv rpc.gssd[2213]: Success getting keytab entry for 'nfs/archiv.sag.local@SAG.LOCAL'
Nov 11 16:21:57 archiv rpc.gssd[2213]: INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_SAG.LOCAL' are good until 1321043604
Nov 11 16:21:57 archiv rpc.gssd[2213]: INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_SAG.LOCAL' are good until 1321043604
Nov 11 16:21:57 archiv rpc.gssd[2213]: using FILE:/tmp/krb5cc_machine_SAG.LOCAL as credentials cache for machine creds
Nov 11 16:21:57 archiv rpc.gssd[2213]: using environment variable to select krb5 ccache FILE:/tmp/krb5cc_machine_SAG.LOCAL
Nov 11 16:21:57 archiv rpc.gssd[2213]: creating context using fsuid 0 (save_uid 0)
Nov 11 16:21:57 archiv rpc.gssd[2213]: creating tcp client for server archiv.SAG.local
Nov 11 16:21:57 archiv rpc.gssd[2213]: DEBUG: port already set to 2049
Nov 11 16:21:57 archiv rpc.gssd[2213]: creating context with server nfs@archiv.SAG.local
Nov 11 16:21:57 archiv rpc.gssd[2213]: in authgss_create_default()
Nov 11 16:21:57 archiv rpc.gssd[2213]: in authgss_create()
Nov 11 16:21:57 archiv rpc.gssd[2213]: authgss_create: name is 0x81dff58
Nov 11 16:21:57 archiv rpc.gssd[2213]: authgss_create: gd->name is 0x81e2340
Nov 11 16:21:57 archiv rpc.gssd[2213]: in authgss_refresh()
Nov 11 16:21:57 archiv rpc.gssd[2213]: struct rpc_gss_sec:
Nov 11 16:21:57 archiv rpc.gssd[2213]:      mechanism_OID: { 1 2 134 72 134 247 18 1 2 2 }
Nov 11 16:21:57 archiv rpc.gssd[2213]:      qop: 0
Nov 11 16:21:57 archiv rpc.gssd[2213]:      service: 1
Nov 11 16:21:57 archiv rpc.gssd[2213]:      cred: 0x81db058
Nov 11 16:21:57 archiv rpc.gssd[2213]:      req_flags: 00000002
Nov 11 16:21:57 archiv rpc.gssd[2213]: rpcsec_gss: gss_init_sec_context: (major) Unspecified GSS failure.  Minor code may provide more information - (minor) No supported encryption types (config file error?)
Nov 11 16:21:57 archiv rpc.gssd[2213]: in authgss_destroy()
Nov 11 16:21:57 archiv rpc.gssd[2213]: in authgss_destroy_context()
Nov 11 16:21:57 archiv rpc.gssd[2213]: authgss_destroy: freeing name 0x81e2340
Nov 11 16:21:57 archiv rpc.gssd[2213]: authgss_create_default: freeing name 0x81dff58
Nov 11 16:21:57 archiv rpc.gssd[2213]: WARNING: Failed to create krb5 context for user with uid 0 for server archiv.SAG.local
Nov 11 16:21:57 archiv rpc.gssd[2213]: WARNING: Failed to create machine krb5 context with credentials cache FILE:/tmp/krb5cc_machine_SAG.LOCAL for server archiv.SAG.local
Nov 11 16:21:57 archiv rpc.gssd[2213]: WARNING: Failed to create machine krb5 context with any credentials cache for server archiv.SAG.local
Nov 11 16:21:57 archiv rpc.gssd[2213]: doing error downcall
Nov 11 16:21:57 archiv rpc.gssd[2213]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt18


As I understand it, the main problem expressed in the message:
Nov 11 16:21:57 archiv rpc.gssd[2213]: rpcsec_gss: gss_init_sec_context: (major) Unspecified GSS failure.  Minor code may provide more information - (minor) No supported encryption types (config file error?)
But why this happens, if kinit work out correctly?

Best regards,
Maxim
