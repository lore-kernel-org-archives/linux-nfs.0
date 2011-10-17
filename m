Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp1.wa.amnet.net.au ([203.161.124.50]:54053 "EHLO
	smtp1.wa.amnet.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992Ab1JQI2o convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Oct 2011 04:28:44 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by smtp1.wa.amnet.net.au (Postfix) with ESMTP id F0E727D328
	for <linux-nfs@vger.kernel.org>; Mon, 17 Oct 2011 16:05:28 +0800 (WST)
Received: from smtp1.wa.amnet.net.au ([127.0.0.1])
	by localhost (smtp1.wa.amnet.net.au [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ahvY4azkz1p7 for <linux-nfs@vger.kernel.org>;
	Mon, 17 Oct 2011 16:05:28 +0800 (WST)
Received: from mail.percipient.com.au (202-89-178-196.static.dsl.amnet.net.au [202.89.178.196])
	(using TLSv1 with cipher AES128-SHA (128/128 bits))
	(No client certificate requested)
	by smtp1.wa.amnet.net.au (Postfix) with ESMTP id F357A7D392
	for <linux-nfs@vger.kernel.org>; Mon, 17 Oct 2011 16:05:27 +0800 (WST)
From: "Jamie S. Morrison" <JMorrison@percipient.com.au>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: idmapd not mapping realm to domain and not resolving gid
Date: Mon, 17 Oct 2011 08:05:29 +0000
Message-ID: <218E09F5AEFE074B83505CE8CD5E06975E66C80F@PCDC1.Percipient.local>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have an issue where the /etc/krb5.conf [libdefaults] default_realm does not seem to be mapped successfully by 
rpc.idmapd. When I change the idmapd.conf [General] Domain to be the same as the kerberos realm (uppercase 
domain) I can successfully map the uid, but never see the gid map to anything other than nobody. This is using 
NFS4, kerberos, pam_krb5, pam_ldap, nss-pam-ldapd, LDAPS with Active Directory 2008 R2 and NetApp storage. This 
is reproducible across a number of distributions including Red Hat Enterprise Linux 6.1, Fedora Core 14 & 15, Ubuntu 
10.04.

In summary:

	rpc.idmapd: nss_getpwnam: name 'jmorrison@DOMAIN.COM' does not map into domain 'domain.com'

Option 1: Lowercase Domain

/etc/idmapd.conf
[General]
Domain = domain.com
Local-Realms = DOMAIN.COM
[Mapping]
Nobody-User = nobody
Nobody-Group = nobody
[Translation]
Method = nsswitch

# rpc.idmapd -f -vvv
rpc.idmapd: libnfsidmap: using domain: domain.com
rpc.idmapd: libnfsidmap: Realms list: 'DOMAIN.COM' 
rpc.idmapd: libnfsidmap: processing 'Method' list
rpc.idmapd: libnfsidmap: loaded plugin /usr/lib64/libnfsidmap/nsswitch.so for method nsswitch
rpc.idmapd: Expiration time is 600 seconds.
rpc.idmapd: Opened /proc/net/rpc/nfs4.nametoid/channel
rpc.idmapd: Opened /proc/net/rpc/nfs4.idtoname/channel
rpc.idmapd: New client: 12
rpc.idmapd: Opened /var/lib/nfs/rpc_pipefs//nfs/clnt12/idmap
rpc.idmapd: New client: 13
rpc.idmapd: nss_getpwnam: name 'root@DOMAIN.COM' does not map into domain 'domain.com'
rpc.idmapd: Client 12: (user) name "root@DOMAIN.COM" -> id "99"
rpc.idmapd: New client: 14
rpc.idmapd: Client 12: (group) name "daemon@DOMAIN.COM" -> id "99"
rpc.idmapd: Stale client: 13
rpc.idmapd: 	-> closed /var/lib/nfs/rpc_pipefs//nfs/clnt13/idmap
rpc.idmapd: nss_getpwnam: name 'jmorrison@DOMAIN.COM' does not map into domain 'domain.com'
rpc.idmapd: Client 12: (user) name "jmorrison@DOMAIN.COM" -> id "99"

ssh as domain user:
$ ls -al
total 96
drwx------. 21 nobody nobody 4096 Oct 17 13:01 .
drwx------.  3 nobody nobody 4096 Oct  6 08:59 ..
-rwx------.  1 nobody nobody  149 Oct 17 14:50 .bash_history
drwx------.  3 nobody nobody 4096 Oct 17 09:41 .cache
drwx------.  4 nobody nobody 4096 Oct 17 09:36 .config


Option 2: Uppercase domain (matching kerberos realm)

/etc/idmapd.conf
[General]
Domain = DOMAIN.COM
Local-Realms = DOMAIN.COM
[Mapping]
Nobody-User = nobody
Nobody-Group = nobody
[Translation]
Method = nsswitch

# rpc.idmapd -f -vvv
rpc.idmapd: libnfsidmap: using domain: DOMAIN.COM
rpc.idmapd: libnfsidmap: Realms list: 'DOMAIN.COM' 
rpc.idmapd: libnfsidmap: processing 'Method' list
rpc.idmapd: libnfsidmap: loaded plugin /usr/lib64/libnfsidmap/nsswitch.so for method nsswitch
rpc.idmapd: Expiration time is 600 seconds.
rpc.idmapd: Opened /proc/net/rpc/nfs4.nametoid/channel
rpc.idmapd: Opened /proc/net/rpc/nfs4.idtoname/channel
rpc.idmapd: New client: 9
rpc.idmapd: Opened /var/lib/nfs/rpc_pipefs//nfs/clnt9/idmap
rpc.idmapd: New client: a
rpc.idmapd: Client 9: (user) name "root@DOMAIN.COM" -> id "0"
rpc.idmapd: Client 9: (group) name "nobody" -> id "99"
rpc.idmapd: New client: b
rpc.idmapd: Client 9: (group) name "daemon@DOMAIN.COM" -> id "2"
rpc.idmapd: Stale client: a
rpc.idmapd: 	-> closed /var/lib/nfs/rpc_pipefs//nfs/clnta/idmap
rpc.idmapd: Client 9: (user) name "jmorrison@DOMAIN.COM" -> id "20002"
^C

ssh as domain user:
$ ls -al
total 96
drwx------. 21 root      daemon 4096 Oct 17 13:01 .
drwx------.  3 root      daemon 4096 Oct  6 08:59 ..
-rwx------.  1 jmorrison nobody  149 Oct 17 14:50 .bash_history
drwx------.  3 jmorrison nobody 4096 Oct 17 09:41 .cache
drwx------.  4 jmorrison nobody 4096 Oct 17 09:36 .config


Other configuration

/etc/krb5.conf
[logging]
default = FILE:/var/log/krb5libs.log
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmind.log
[libdefaults]
default_realm = DOMAIN.COM
default_tgs_enctypes = des-cbc-crc des-cbc-md5
default_tkt_enctypes = des-cbc-crc des-cbc-md5
allow_weak_crypto = true
dns_lookup_realm = true
dns_lookup_kdc = true
ticket_lifetime = 24h
renew_lifetime = 7d
forwardable = true
[realms]
DOMAIN.COM = {
	kdc = domain.com
	admin_server = domain.com
	default_domain = DOMAIN.COM
}
[domain_realm]
domain.com = DOMAIN.COM
.domain.com = DOMAIN.COM

/etc/nsswitch.conf
passwd:     files ldap
shadow:     files ldap
group:      files ldap
hosts:      files dns
bootparams: nisplus [NOTFOUND=return] files
ethers:     files
netmasks:   files
networks:   files
protocols:  files
rpc:        files
services:   files
netgroup:   nisplus
publickey:  nisplus
automount:  files
aliases:    files nisplus


LDAP lookups working

# getent passwd jmorrison
jmorrison:*:20002:10000:Jamie Morrison:/home/uniwa/autres/autresx/jmorrison:/bin/sh

# getent group All-Staff
All-Staff:*:10000:jmorrison

# id jmorrison
uid=20002(jmorrison) gid=10000(All-Staff) groups=10000(All-Staff),99008(jmorrisongroup),10002(All-Autres),99043

(All-Autresx)


/home/uniwa/autres mounted via autofs


Please let me know if there are any other details or config you require. Apologies if this is the wrong list for this.

Regards,


Jamie Morrison.
