Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from plasma6.jpberlin.de ([80.241.56.68]:51904 "EHLO
	plasma6.jpberlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754335AbbK3QaR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Nov 2015 11:30:17 -0500
Received: from gerste.heinlein-support.de (gerste.heinlein-support.de [91.198.250.173])
	by plasma.jpberlin.de (Postfix) with ESMTP id 3DD84AEA10
	for <linux-nfs@vger.kernel.org>; Mon, 30 Nov 2015 17:20:25 +0100 (CET)
Received: from plasma.jpberlin.de ([91.198.250.140])
	by gerste.heinlein-support.de (gerste.heinlein-support.de [91.198.250.173]) (amavisd-new, port 10030)
	with ESMTP id QWBpYSHezuWM for <linux-nfs@vger.kernel.org>;
	Mon, 30 Nov 2015 17:20:24 +0100 (CET)
Received: from [192.168.0.86] (unknown [95.91.241.123])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: p.thurner@blunix.org)
	by plasma.jpberlin.de (Postfix) with ESMTPSA id DDEADAE91B
	for <linux-nfs@vger.kernel.org>; Mon, 30 Nov 2015 17:20:23 +0100 (CET)
To: linux-nfs@vger.kernel.org
From: Peter Thurner <p.thurner@blunix.org>
Subject: NFS Kernel Panics
Message-ID: <565C7747.1080703@blunix.org>
Date: Mon, 30 Nov 2015 17:20:23 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi guys,

I'm running the following Setup on Ubuntu 14.04 for both Server and Clients:


== NFS Server with /etc/exports:

/var/www/ 172.16.1.254(rw,no_root_squash,sync,no_subtree_check)
172.16.1.184(rw,no_root_squash,sync,no_subtree_check)
172.16.0.120(rw,no_root_squash,sync,no_subtree_check)
172.16.0.193(rw,no_root_squash,sync,no_subtree_check)

Version: 1:1.2.8-6ubuntu1.2


== Four NFS Clients with fstab:

alpha:/var/www        /var/www    nfs4   
nosharecache,fsc=example_web,noatime,tcp,bg,nosuid,rsize=32768,wsize=32768,soft,proto=tcp   
0 0

On the Clients i'm using cachefilesd:

/var/cache/cachefilesd/loopimage.img       
/var/cache/cachefilesd/srv    ext4   
loop,rw,relatime,errors=continue,user_xattr,acl,barrier=1,data=ordered    0
0

root@web1:~# cat /etc/cachefilesd.conf
dir /var/cache/cachefilesd/srv
tag nfs_filesystem_cache
brun 20%
frun 10%
bcull 10%
fcull 7%
bstop 5%
fstop 3%


== Problem

Both server and clients experience random kernel Panics. Of the five
machines, around one dies per die. They all run on Amazon AWS as
m4.large instances. When I set

rpcdebug -m nfsd -s all
rpcdebug -m rpc -s all

The messages before the crash (this time on the NFS server) are:

```
Nov 30 13:49:54 nfs-master kernel: [38232.649545] nfsd_dispatch: vers 4
proc 1
Nov 30 13:49:54 nfs-master kernel: [38232.649547] nfsv4 compound op
#1/3: 22 (OP_PUTFH)
Nov 30 13:49:54 nfs-master kernel: [38232.649548] nfsd: fh_verify(32:
81060001 0c7791ab ab46dd87 663ae28a 6877949f 2802898e)
Nov 30 13:49:54 nfs-master kernel: [38232.649552] nfsv4 compound op
ffff8802026c8080 opcnt 3 #1: 22: status 0
Nov 30 13:49:54 nfs-master kernel: [38232.649553] nfsv4 compound op
#2/3: 4 (OP_CLOSE)
Nov 30 13:49:54 nfs-master kernel: [38232.649554] NFSD: nfsd4_close on
file objectLinksShadow.png
Nov 30 13:49:54 nfs-master kernel: [38232.649556] NFSD:
nfs4_preprocess_seqid_op: seqid=818421 stateid =
(565bb0a0/00000001/00083f05/00000001)
Nov 30 13:49:54 nfs-master kernel: [38232.649557] renewing client
(clientid 565bb0a0/00000001)
Nov 30 13:49:54 nfs-master kernel: [38232.649558] NFSD:
move_to_close_lru nfs4_openowner ffff8800373b8000
Nov 30 13:49:54 nfs-master kernel: [38232.649559] nfsv4 compound op
ffff8802026c8080 opcnt 3 #2: 4: status 0
Nov 30 13:49:54 nfs-master kernel: [38232.649560] nfsv4 compound op
#3/3: 9 (OP_GETATTR)
Nov 30 13:49:54 nfs-master kernel: [38232.649562] nfsd: fh_verify(32:
81060001 0c7791ab ab46dd87 663ae28a 6877949f 2802898e)
Nov 30 13:49:54 nfs-master kernel: [38232.649564] nfsv4 compound op
ffff8802026c8080 opcnt 3 #3: 9: status 0
Nov 30 13:49:54 nfs-master kernel: [38232.649565] nfsv4 compound returned 0
Nov 30 13:49:54 nfs-master kernel: [38232.649570] svc: socket
ffff8800e929d000 sendto([ffff8801e07ae000 136... ], 136) = 136 (addr
172.16.0.120, port=958)
Nov 30 13:49:54 nfs-master kernel: [38232.649571] svc: server
ffff880202142000 waiting for data (to = 900000)
Nov 30 13:49:54 nfs-master rsyslogd: [origin software="rsyslogd"
swVersion="7.4.4" x-pid="939" x-info="http://www.rsyslog.com"] exiting
on signal 15.

Server is rebooting here

Nov 30 13:50:34 nfs-master rsyslogd: [origin software="rsyslogd"
swVersion="7.4.4" x-pid="951" x-info="http://www.rsyslog.com"] start
Nov 30 13:50:34 nfs-master rsyslogd-2307: warning: ~ action is
deprecated, consider using the 'stop' statement instead [try
http://www.rsyslog.com/e/2307 ]
Nov 30 13:50:34 nfs-master rsyslogd: rsyslogd's groupid changed to 104
Nov 30 13:50:34 nfs-master rsyslogd: rsyslogd's userid changed to 101
Nov 30 13:50:34 nfs-master kernel: [    0.000000] Initializing cgroup
subsys cpuset
Nov 30 13:50:34 nfs-master kernel: [    0.000000] Initializing cgroup
subsys cpu
Nov 30 13:50:34 nfs-master kernel: [    0.000000] Initializing cgroup
subsys cpuacct

```








