Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp1.wa.amnet.net.au ([203.161.124.50]:45903 "EHLO
	smtp1.wa.amnet.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105Ab1JSIla convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Oct 2011 04:41:30 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by smtp1.wa.amnet.net.au (Postfix) with ESMTP id 424357D935
	for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 16:41:28 +0800 (WST)
Received: from smtp1.wa.amnet.net.au ([127.0.0.1])
	by localhost (smtp1.wa.amnet.net.au [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id pPYv86b3J4KO for <linux-nfs@vger.kernel.org>;
	Wed, 19 Oct 2011 16:41:27 +0800 (WST)
Received: from mail.percipient.com.au (202-89-178-196.static.dsl.amnet.net.au [202.89.178.196])
	(using TLSv1 with cipher AES128-SHA (128/128 bits))
	(No client certificate requested)
	by smtp1.wa.amnet.net.au (Postfix) with ESMTP id 3C60D7D967
	for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 16:41:26 +0800 (WST)
From: "Jamie S. Morrison" <JMorrison@percipient.com.au>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: idmapd not mapping realm to domain and not resolving gid
Date: Wed, 19 Oct 2011 08:41:28 +0000
Message-ID: <218E09F5AEFE074B83505CE8CD5E06975E674EBE@PCDC1.Percipient.local>
References: <218E09F5AEFE074B83505CE8CD5E06975E66C80F@PCDC1.Percipient.local>
In-Reply-To: <218E09F5AEFE074B83505CE8CD5E06975E66C80F@PCDC1.Percipient.local>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One step further... the NetApp options nfs.v4.id.domain had been entered in uppercase.

Then although gssd gets the right uid, idmapd calls nss_getpwnam twice and fails to get the correct uid

Oct 19 15:08:04 rhel61 rpc.idmapd[1595]: nss_getpwnam: name 'jmorrison@domain.com' domain 'domain.com': resulting localname 'jmorrison'
Oct 19 15:08:04 rhel61 rpc.idmapd[1595]: nss_getpwnam: name 'jmorrison' not found in domain 'domain.com'

This was resolved via the following setting in http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=500778

/etc/idmapd.conf
[General]
Cache-Expiration = 10

Now I'm just left with the gid not resolving:

Oct 19 15:44:27 rhel61 rpc.idmapd[2306]: nfs4_name_to_uid: calling nsswitch->name_to_uid
Oct 19 15:44:27 rhel61 rpc.idmapd[2306]: nss_getpwnam: name 'jmorrison@domain.com' domain 'domain.com': resulting localname 'jmorrison'
Oct 19 15:44:27 rhel61 rpc.idmapd[2306]: nfs4_name_to_uid: nsswitch->name_to_uid returned 0
Oct 19 15:44:27 rhel61 rpc.idmapd[2306]: nfs4_name_to_uid: final return value is 0
Oct 19 15:44:27 rhel61 rpc.idmapd[2306]: Client 0: (user) name "jmorrison@domain.com" -> id "20002"
Oct 19 15:45:43 rhel61 rpc.idmapd[2306]: nfs4_uid_to_name: calling nsswitch->uid_to_name
Oct 19 15:45:43 rhel61 rpc.idmapd[2306]: nfs4_uid_to_name: nsswitch->uid_to_name returned 0
Oct 19 15:45:43 rhel61 rpc.idmapd[2306]: nfs4_uid_to_name: final return value is 0
Oct 19 15:45:43 rhel61 rpc.idmapd[2306]: Client 0: (user) id "20002" -> name "jmorrison@domain.com"
Oct 19 15:45:43 rhel61 rpc.idmapd[2306]: nfs4_gid_to_name: calling nsswitch->gid_to_name
Oct 19 15:45:43 rhel61 rpc.idmapd[2306]: nfs4_gid_to_name: nsswitch->gid_to_name returned 0
Oct 19 15:45:43 rhel61 rpc.idmapd[2306]: nfs4_gid_to_name: final return value is 0
Oct 19 15:45:43 rhel61 rpc.idmapd[2306]: Client 0: (group) id "99" -> name "nobody@domain.com"

$ ls -l
total 32
drwx------. 2 jmorrison nobody 4096 Oct 19 16:09 Desktop
drwx------. 2 jmorrison nobody 4096 Oct 19 16:09 Documents
drwx------. 2 jmorrison nobody 4096 Oct 19 16:09 Downloads
drwx------. 2 jmorrison nobody 4096 Oct 19 16:09 Music
drwx------. 2 jmorrison nobody 4096 Oct 19 16:09 Pictures
drwx------. 2 jmorrison nobody 4096 Oct 19 16:09 Public
drwx------. 2 jmorrison nobody 4096 Oct 19 16:09 Templates
drwx------. 2 jmorrison nobody 4096 Oct 19 16:09 Videos

Any help appreciated.

Regards,


Jamie Morrison.

-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Jamie S. Morrison
Sent: Monday, 17 October 2011 4:05 PM
To: linux-nfs@vger.kernel.org
Subject: idmapd not mapping realm to domain and not resolving gid

Hi,

I have an issue where the /etc/krb5.conf [libdefaults] default_realm does not seem to be mapped successfully by rpc.idmapd. When I change the idmapd.conf [General] Domain to be the same as the kerberos realm (uppercase
domain) I can successfully map the uid, but never see the gid map to anything other than nobody. This is using NFS4, kerberos, pam_krb5, pam_ldap, nss-pam-ldapd, LDAPS with Active Directory 2008 R2 and NetApp storage. This is reproducible across a number of distributions including Red Hat Enterprise Linux 6.1, Fedora Core 14 & 15, Ubuntu 10.04.

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
-rwx------.  1 nobody nobody  149 Oct 17 14:50 .bash_history drwx------.  3 nobody nobody 4096 Oct 17 09:41 .cache drwx------.  4 nobody nobody 4096 Oct 17 09:36 .config


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
-rwx------.  1 jmorrison nobody  149 Oct 17 14:50 .bash_history drwx------.  3 jmorrison nobody 4096 Oct 17 09:41 .cache drwx------.  4 jmorrison nobody 4096 Oct 17 09:36 .config


Other configuration

/etc/krb5.conf
[logging]
default = FILE:/var/log/krb5libs.log
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmind.log [libdefaults] default_realm = DOMAIN.COM default_tgs_enctypes = des-cbc-crc des-cbc-md5 default_tkt_enctypes = des-cbc-crc des-cbc-md5 allow_weak_crypto = true dns_lookup_realm = true dns_lookup_kdc = true ticket_lifetime = 24h renew_lifetime = 7d forwardable = true [realms] DOMAIN.COM = {
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
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
