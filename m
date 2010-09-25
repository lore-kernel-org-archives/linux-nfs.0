Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.asenwelt.de ([89.238.66.139]:54248 "EHLO
	extern.asenwelt.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244Ab0IYWNs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Sep 2010 18:13:48 -0400
Received: from [192.168.6.50] (188-192-68-246-dynip.superkabel.de [188.192.68.246])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by extern.asenwelt.de (Postfix) with ESMTPSA id 1B03B3C964
	for <linux-nfs@vger.kernel.org>; Sat, 25 Sep 2010 22:07:56 +0000 (UTC)
Message-ID: <4C9E72BB.5080000@asenwelt.de>
Date: Sun, 26 Sep 2010 00:07:55 +0200
From: Malte Zacharias <kernel-ml-alias@asenwelt.de>
To: linux-nfs@vger.kernel.org
Subject: NFS+krb5 ID mapping always maps to nobody
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I have been trying to configure an nfsv4 client and server for my
network for some time now, but there is one issue I can't resolve.

I run a small (2-5 clients) network using .local as a domain suffix and
for mDNS resolution. For "historical" reasons, my Kerberos Realm is
TADPOLE. I setup an NFSv4 server and Client that uses Kerberos for
authentication.

My problem is that everytime my client accesses the server, its ID is
mapped to nobody, but I can't find any reason as to why this is
happening. I verified this by creating a file via NFS and it always is
created under user nobody. Test scenarios were:
 - Identical usernames, different UIDs
 - Identical usernames, Identical groupnames, Identical UIDs/GIDs

The result is always the same, the NFS client can only access files with
permissions set to 777. New files, created by the client are created
under user nobody.

My idmap.conf is as follows: (identical on both server and client)
===============================================
[General]

Verbosity = 0
Pipefs-Directory = /var/lib/nfs/rpc_pipefs

Domain = local

[Mapping]

Nobody-User = nobody
Nobody-Group = nogroup
===============================================

my /etc/fstab entry is this:
# NFS mount
iris.local:/	/mnt/nfs	nfs4		defaults,noauto,user,sec=krb5p	0 0

This is a sample command sequence for my problem:
/mnt/nfs/heap is writeable by everyone, /mnt/nfs/nfstest01 only by
nfstest01:
===============================================
nfstest01@desktop:/$ touch /mnt/nfs/heap/test
nfstest01@desktop:/$ touch /mnt/nfs/nfstest01/test
touch: cannot touch `/mnt/nfs/nfstest01/test': Permission denied
nfstest01@desktop:/$ ls -l /mnt/nfs/heap/test
-rw-r--r-- 1 nobody nogroup 0 2010-09-26 00:02 /mnt/nfs/heap/test
nfstest01@desktop:/$ ls -l /mnt/nfs/
drwxr-xrwx  8 malte     users     8192 2010-09-26 00:02 heap
drwxr-x---  2 nfstest01 nfstest01 4096 2010-09-25 22:34 nfstest01
nfstest01@desktop:/$ id
uid=4321(nfstest01) gid=4321(nfstest01) groups=4321(nfstest01)

===============================================

This is what rpc.idmapd -f -vvvvv shows:
===========Server==============================
rpc.idmapd: libnfsidmap: using domain: local
rpc.idmapd: libnfsidmap: loaded plugin /usr/lib/libnfsidmap/nsswitch.so
for method nsswitch
rpc.idmapd: Expiration time is 600 seconds.
rpc.idmapd: Opened /proc/net/rpc/nfs4.nametoid/channel
rpc.idmapd: Opened /proc/net/rpc/nfs4.idtoname/channel
rpc.idmapd: nfsdcb: authbuf=gss/krb5p authtype=user
rpc.idmapd: nfs4_uid_to_name: calling nsswitch->uid_to_name

rpc.idmapd: nfs4_uid_to_name: nsswitch->uid_to_name returned 0

rpc.idmapd: nfs4_uid_to_name: final return value is 0

rpc.idmapd:  Server: (user) id "5555" -> name "malte@local"
rpc.idmapd: nfsdcb: authbuf=gss/krb5p authtype=group
rpc.idmapd: nfs4_gid_to_name: calling nsswitch->gid_to_name

rpc.idmapd: nfs4_gid_to_name: nsswitch->gid_to_name returned 0

rpc.idmapd: nfs4_gid_to_name: final return value is 0

rpc.idmapd:  Server: (group) id "100" -> name "users@local"
rpc.idmapd: nfsdcb: authbuf=gss/krb5p authtype=user
rpc.idmapd: nfs4_uid_to_name: calling nsswitch->uid_to_name

rpc.idmapd: nfs4_uid_to_name: nsswitch->uid_to_name returned 0

rpc.idmapd: nfs4_uid_to_name: final return value is 0

rpc.idmapd:  Server: (user) id "65534" -> name "nobody@local"
rpc.idmapd: nfsdcb: authbuf=gss/krb5p authtype=group
rpc.idmapd: nfs4_gid_to_name: calling nsswitch->gid_to_name

rpc.idmapd: nfs4_gid_to_name: nsswitch->gid_to_name returned 0

rpc.idmapd: nfs4_gid_to_name: final return value is 0

rpc.idmapd:  Server: (group) id "65534" -> name "nogroup@local"
rpc.idmapd: nfsdcb: authbuf=gss/krb5p authtype=user
rpc.idmapd: nfs4_uid_to_name: calling nsswitch->uid_to_name

rpc.idmapd: nfs4_uid_to_name: nsswitch->uid_to_name returned 0

rpc.idmapd: nfs4_uid_to_name: final return value is 0

rpc.idmapd:  Server: (user) id "4321" -> name "nfstest01@local"
===============================================

===========Client==============================
pc.idmapd: libnfsidmap: using domain: local

rpc.idmapd: libnfsidmap: loaded plugin /usr/lib/libnfsidmap/nsswitch.so
for method nsswitch

rpc.idmapd: Expiration time is 600 seconds.
rpc.idmapd: Opened /proc/net/rpc/nfs4.nametoid/channel
rpc.idmapd: Opened /proc/net/rpc/nfs4.idtoname/channel
rpc.idmapd: New client: 0
rpc.idmapd: Opened /var/lib/nfs/rpc_pipefs/nfs/clnt0/idmap
rpc.idmapd: New client: 1
rpc.idmapd: New client: 2
rpc.idmapd: New client: 3
rpc.idmapd: New client: 4
===============================================

I have spent days without any luck resolving this nor finding any
documentation about this point. Nearly every NFSv4 Howto I found so far
just skips Kerberos completely. I think this should definitely work, but
as it appears it doesn't. Additionally all debug output I got so far
wasn't helpful at all, how can I proceed? What further information do
you need?

Best regards
Malte Zacharas
