Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp3.mail.completel.net ([213.245.2.34]:43067 "EHLO
	smtp3.mail.completel.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422679Ab3FUO0e convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Jun 2013 10:26:34 -0400
Received: from mail.noveltis.fr (mail.noveltis.fr [92.103.160.203])
	by smtp3.mail.completel.net (Postfix) with ESMTP id 0F28D7009
	for <linux-nfs@vger.kernel.org>; Fri, 21 Jun 2013 16:26:32 +0200 (CEST)
From: Thierry Lamoureux <thierry.lamoureux@noveltis.fr>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: NFS4 + KERB + AD 2008 Troubles
Date: Fri, 21 Jun 2013 14:26:31 +0000
Message-ID: <2182E21644AEEF4BAC775CC0609AE30C1E2AF5D1@GLORFINDEL.noveltis.loc>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,


I try to configure NFSv4 + Kerberos + Active Directory since several days without any success.
I think I've read all documentation I could and it still doesn't work...

Here is my configuration :
- One Active Directory server under MS Server 2008 R2, which provide a DOMAIN.LOC directory
- One linux NFS Server under Debian Squeeze, named nfsserver
- One linux NFS Client under Debian Squeeze, named nfsclient


Here are all the steps I performed :

On Linux Server (nfsserver)

Package installation
- nfs-common
- nfs-kernel-server
- winbind


Package configuration

/etc/samba/smb.conf
[global]
netbios name = nfsserver
interfaces = 192.168.1.0/24 192.168.10.0/24 127.0.0.1/32
bind interfaces only = yes
workgroup = DOMAIN
realm = DOMAIN.LOC
server string = Server %h
dns proxy = no
log file = /var/log/samba/log.%m
max log size = 100
log level = 3
syslog = 0
security     = ADS
local master = no
domain master = no
prefered master = no
idmap backend = tdb
idmap uid = 10000-49999
idmap gid = 10000-49999
idmap config DOMAIN : backend  = rid
idmap config DOMAIN : range    = 10000-49999
idmap config DOMAIN : base_rid = 0
winbind enum users = yes
winbind enum groups = yes
winbind offline logon = yes
winbind nested groups = yes
winbind refresh tickets = yes
winbind use default domain = yes
encrypt passwords = yes
password server = 192.168.1.11 192.168.1.14
client use spnego = Yes
kerberos method = secrets and keytab
dedicated keytab file = /etc/krb5.keytab
winbind refresh tickets = true
template shell = /bin/bash
template homedir  = /DOMAIN/%U
name resolve order = lmhosts host

/etc/krb5.conf
[libdefaults]
        ticket_lifetime = 24000
        default_realm = DOMAIN.LOC
        dns_lookup_realm = false
        dns_lookup_kdc = false
        default_tgs_enctypes = RC4-HMAC DES-CBC-MD5 DES-CBC-CRC
        default_tkt_enctypes = RC4-HMAC DES-CBC-MD5 DES-CBC-CRC
        preferred_enctypes = RC4-HMAC DES-CBC-MD5 DES-CBC-CRC
        default_keytab_name = FILE:/etc/krb5.keytab
[realms]
        DOMAIN.LOC = {
        kdc = dc1.domain.loc:88
        kdc = dc2.domain.loc:88
        admin_server = dc1.domain.loc:749
        admin_server = dc2.domain.loc:749
        kpasswd_server = dc1.domain.loc:464
        kpasswd_server = dc2.domain.loc:464
        kpasswd_protocol = SET_CHANGE
        default_domain = domain.loc
        }
[domain_realm]
        *.domain.loc = DOMAIN.LOC
        .domain.loc = DOMAIN.LOC
        domain.loc = DOMAIN.LOC
[logging]
        default = FILE:/var/krb5/kdc.log
        kdc = FILE:/var/krb5/kdc.log


To automatically get a kerberos ticket, Winbind is configured in /etc/pam.d/common-auth :
auth    [success=3 default=ignore]      pam_unix.so
auth    [success=1 default=ignore]      pam_winbind.so krb5_auth krb5_ccache_type=FILE cached_login use_first_pass
auth    requisite                       pam_deny.so
auth    optional                        pam_mount.so
auth    required                        pam_group.so
auth    required                        pam_permit.so

/etc/idmapd.conf
[General]
Verbosity = 3
Pipefs-Directory = /var/lib/nfs/rpc_pipefs
Domain = domain.loc
[Mapping]
Nobody-User = nobody
Nobody-Group = nogroup

/etc/default/nfs-common
NEED_STATD=yes
STATDOPTS=
NEED_IDMAPD=yes
NEED_GSSD=yes
RPCGSSDOPTS="-vvv"

/etc/default/nfs-kernel-server
RPCNFSDCOUNT=8
RPCNFSDPRIORITY=0
RPCMOUNTDOPTS="--manage-gids"
NEED_SVCGSSD=yes
RPCSVCGSSDOPTS=" -vvv "
RPCNFSDOPTS=

Join machine to the domain
# net ads join createupn=nfs/nfsserver.domain.loc -U Administrator
Using short domain name -- DOMAIN
Joined 'NFSSERVER' to realm 'domain.loc'

Check :
# wbinfo -t
checking the trust secret for domain DOMAIN via RPC calls succeeded


# id toto
uid=10000(toto) gid=10000(domain users) groups=10000(domain users)

Login with a domain user :
# klist
Ticket cache: FILE:/tmp/krb5cc_11147
Default principal: toto@DOMAIN.LOC
Valid starting     Expires            Service principal
06/19/13 16:13:44  06/20/13 02:13:44  krbtgt/DOMAIN.LOC@DOMAIN.LOC
        renew until 06/26/13 16:13:44
06/19/13 16:13:44  06/20/13 02:13:44  NFSSERVER$@DOMAIN.LOC
        renew until 06/26/13 16:13:44
06/19/13 16:13:44  06/20/13 02:13:44  NFSSERVER@DOMAIN.LOC
        renew until 06/26/13 16:13:44

Login back with root and create a nfs service principal:
# net ads keytab add nfs -U Administrator[/code]

/etc/exports
/srv/nfs4        gss/krb5(rw,sync,fsid=0,crossmnt,no_subtree_check)
/srv/nfs4/share  gss/krb5(rw,sync,no_subtree_check)

Restart NFS Service
# /etc/init.d/nfs-common restart
# /etc/init.d/nfs-kernel-server restart


View nfs exports 
# exportfs
/srv/nfs4            gss/krb5
/srv/nfs4/share        gss/krb5

On Linux Client (nfsclient)

Package installation
- nfs-common
- winbind

Package configuration
Exactly the same configuration than nfsserver except the nfs-kernel-server and exports parts which is empty.

Mounting the FS

Now I try to mount my nfs volume :
# mount -t nfs4 -o sec=krb5 nfsserver:/share /mnt -vvv
mount: fstab path: "/etc/fstab"
mount: mtab path:  "/etc/mtab"
mount: lock path:  "/etc/mtab~"
mount: temp path:  "/etc/mtab.tmp"
mount: UID:        0
mount: eUID:       0
mount: spec:  "nfsserver:/share"
mount: node:  "/mnt"
mount: types: "nfs4"
mount: opts:  "sec=krb5"
mount: external mount: argv[0] = "/sbin/mount.nfs4"
mount: external mount: argv[1] = "nfsserver:/share"
mount: external mount: argv[2] = "/mnt"
mount: external mount: argv[3] = "-v"
mount: external mount: argv[4] = "-o"
mount: external mount: argv[5] = "rw,sec=krb5"
mount.nfs4: timeout set for Wed Jun 19 16:31:01 2013
mount.nfs4: trying text-based options 'sec=krb5,addr=192.168.1.140,clientaddr=192.168.10.63'
mount.nfs4: mount(2): Permission denied
mount.nfs4: access denied by server while mounting nfsserver:/share

And in syslog of nfsclient I have:
Jun 19 16:33:13 vm-pxe rpc.idmapd[4839]: New client: 59
Jun 19 16:33:13 vm-pxe rpc.idmapd[4839]: Opened /var/lib/nfs/rpc_pipefs/nfs/clnt59/idmap
Jun 19 16:33:13 vm-pxe rpc.idmapd[4839]: New client: 5a
Jun 19 16:33:13 vm-pxe rpc.gssd[4843]: handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt59)
Jun 19 16:33:13 vm-pxe rpc.gssd[4843]: handle_gssd_upcall: 'mech=krb5 uid=0 '
Jun 19 16:33:13 vm-pxe rpc.gssd[4843]: handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt59)
Jun 19 16:33:13 vm-pxe rpc.gssd[4843]: process_krb5_upcall: service is '<null>'
Jun 19 16:33:13 vm-pxe rpc.gssd[4843]: Full hostname for 'nfsserver.domain.loc' is 'nfsserver.domain.loc'
Jun 19 16:33:13 vm-pxe rpc.gssd[4843]: Full hostname for 'nfsclient.domain.loc' is 'nfsclient.domain.loc'
Jun 19 16:33:13 vm-pxe rpc.gssd[4843]: Key table entry not found while getting keytab entry for 'root/nfsclient.domain.loc@DOMAIN.LOC'
Jun 19 16:33:13 vm-pxe rpc.gssd[4843]: Success getting keytab entry for 'nfs/nfsclient.domain.loc@DOMAIN.LOC'
Jun 19 16:33:13 vm-pxe rpc.gssd[4843]: WARNING: Client not found in Kerberos database while getting initial ticket for principal 'nfs/nfsclient.domain.loc@DOMAIN.LOC' using keytab 'WRFILE:/etc/krb5.keytab'
Jun 19 16:33:13 vm-pxe rpc.gssd[4843]: ERROR: No credentials found for connection to server nfsserver.domain.loc
Jun 19 16:33:13 vm-pxe rpc.gssd[4843]: doing error downcall
Jun 19 16:33:13 vm-pxe rpc.idmapd[4839]: Stale client: 5a
Jun 19 16:33:13 vm-pxe rpc.idmapd[4839]: #011-> closed /var/lib/nfs/rpc_pipefs/nfs/clnt5a/idmap
Jun 19 16:33:13 vm-pxe rpc.idmapd[4839]: Stale client: 59
Jun 19 16:33:13 vm-pxe rpc.idmapd[4839]: #011-> closed /var/lib/nfs/rpc_pipefs/nfs/clnt59/idmap
Jun 19 16:33:13 vm-pxe rpc.gssd[4843]: destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt59

I don't know what to do more... If you have an advice or just an idea, please help me  

Thierry.

