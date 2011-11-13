Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm19.bullet.mail.ird.yahoo.com ([77.238.189.76]:47643 "HELO
	nm19.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751825Ab1KMWTQ convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Nov 2011 17:19:16 -0500
References: <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com> <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com> <06799B7D-54CD-41D8-934A-F9C78B23677C@oracle.com> <1320450001.87605.YahooMailNeo@web24706.mail.ird.yahoo.com> <1320455965.2750.9.camel@lade.trondhjem.org> <1320459252.59518.YahooMailNeo@web24716.mail.ird.yahoo.com> <1320460311.2750.21.camel@lade.trondhjem.org> <1320465106.61111.YahooMailNeo@web24710.mail.ird.yahoo.com> <20111105130517.GA16090@umich.edu> <1321097734.7117.YahooMailNeo@web24701.mail.ird.yahoo.com> <20111112184804.GA25581@umich.edu> <1E7FF4C1-B7BA-4429-92ED-DC90D6B269C4@oracle.com> <1321146230.5436.YahooMailNeo@web24710.mail.ird.yahoo.com> <DE923535-CDF1-418D-BDA0-7450E292A272@oracle.com> <1321219739.17997.YahooMailNeo@web24711.mail.ird.yahoo.com>
Message-ID: <1321222753.13412.YahooMailNeo@web24707.mail.ird.yahoo.com>
Date: Sun, 13 Nov 2011 22:19:13 +0000 (GMT)
From: Lukas Razik <linux@razik.name>
Reply-To: Lukas Razik <linux@razik.name>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jim Rees <rees@umich.edu>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <1321219739.17997.YahooMailNeo@web24711.mail.ird.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> [ 1764.189975] ADDRCONF(NETDEV_UP): eth0: link is not ready

> [ 1765.212110] IP-Config: Complete:
> [ 1765.212180]      device=eth0, addr=137.226.167.242, mask=255.255.255.224, 
> gw=137.226.167.225,
> [ 1765.212383]      host=137.226.167.242, domain=, nis-domain=(none),
> [ 1765.212498]      bootserver=255.255.255.255, rootserver=137.226.167.241, 
> rootpath=
> [ 1765.212943] VFS: 1. attempt to mount root fs via NFS.
> [ 1765.212992] Root-NFS: nfsroot=/srv/nfs/cluster2
> [ 1765.213265] NFS: nfs mount opts='udp,nolock,addr=137.226.167.241'
> [ 1765.213315] NFS:   parsing nfs mount option 'udp'
> [ 1765.213353] NFS:   parsing nfs mount option 'nolock'
> [ 1765.213399] NFS:   parsing nfs mount option 'addr=137.226.167.241'
> [ 1765.213467] NFS: MNTPATH: '/srv/nfs/cluster2'
> [ 1765.213501] NFS: sending MNT request for 137.226.167.241:/srv/nfs/cluster2
> [ 1766.298480] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: 
> Rx
> [ 1766.318949] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> [ 1800.284325] NFS: failed to create MNT RPC client, status=-60
> [ 1800.284435] NFS: unable to mount server 137.226.167.241, error -60
> [ 1800.284571] VFS: 2. attempt to mount root fs via NFS.
> [ 1800.284682] Root-NFS: nfsroot=/srv/nfs/cluster2
> [ 1800.285051] NFS: nfs mount 
> opts='udp,nolock,addr=137.226.167.241,nolock,addr=137.226.167.241'
> [ 1800.285167] NFS:   parsing nfs mount option 'udp'
> [ 1800.285233] NFS:   parsing nfs mount option 'nolock'
> [ 1800.285337] NFS:   parsing nfs mount option 'addr=137.226.167.241'
> [ 1800.285455] NFS:   parsing nfs mount option 'nolock'
> [ 1800.285531] NFS:   parsing nfs mount option 'addr=137.226.167.241'

Chuck, I've seen that it's wrong to wrap mount_nfs_root() with while() because then we get a multiple occurrence of some mount options. Hence I've edited mount_nfs_root() itself so that the options will be set only once.
Maybe that's better?
--- linux-2.6.39.4/init/do_mounts.c        2011-08-03 21:43:28.000000000 +0200
+++ linux-2.6.39.4-fix/init/do_mounts.c     2011-11-13 23:05:13.000000000 +0100
@@ -363,12 +363,18 @@
 static int __init mount_nfs_root(void)
 {
        char *root_dev, *root_data;
+       char attempt;
 
        if (nfs_root_data(&root_dev, &root_data) != 0)
                return 0;
-       if (do_mount_root(root_dev, "nfs", root_mountflags, root_data) != 0)
-               return 0;
-       return 1;
+
+       for(attempt = 1; attempt <= 3; attempt++) {
+               printk(KERN_INFO "VFS: %d. attempt to mount root fs via NFS.\n", attempt);
+               if (do_mount_root(root_dev, "nfs", root_mountflags, root_data) == 0)
+                       return 1;
+       }
+
+       return 0;
 }
 #endif

--
Regards,
Lukas


PS: That's the new behaviour:
[ 4416.829621] ADDRCONF(NETDEV_UP): eth0: link is not ready
[ 4417.851657] IP-Config: Complete:
[ 4417.851729]      device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=137.226.167.225,
[ 4417.851931]      host=137.226.167.242, domain=, nis-domain=(none),
[ 4417.852045]      bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
[ 4417.852493] Root-NFS: nfsroot=/srv/nfs/cluster2
[ 4417.852539] VFS: 1. attempt to mount root fs via NFS.
[ 4417.852814] NFS: nfs mount opts='udp,nolock,addr=137.226.167.241'
[ 4417.852893] NFS:   parsing nfs mount option 'udp'
[ 4417.852930] NFS:   parsing nfs mount option 'nolock'
[ 4417.852977] NFS:   parsing nfs mount option 'addr=137.226.167.241'
[ 4417.853073] NFS: MNTPATH: '/srv/nfs/cluster2'
[ 4417.853137] NFS: sending MNT request for 137.226.167.241:/srv/nfs/cluster2
[ 4418.933894] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
[ 4418.954252] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[ 4452.967331] NFS: failed to create MNT RPC client, status=-60
[ 4452.967441] NFS: unable to mount server 137.226.167.241, error -60
[ 4452.967577] VFS: 2. attempt to mount root fs via NFS.
[ 4452.967978] NFS: nfs mount opts='udp,nolock,addr=137.226.167.241'
[ 4452.968085] NFS:   parsing nfs mount option 'udp'
[ 4452.968150] NFS:   parsing nfs mount option 'nolock'
[ 4452.968197] NFS:   parsing nfs mount option 'addr=137.226.167.241'
[ 4452.968333] NFS: MNTPATH: '/srv/nfs/cluster2'
[ 4452.968397] NFS: sending MNT request for 137.226.167.241:/srv/nfs/cluster2
[ 4452.974480] NFS: received 1 auth flavors
[ 4452.974543] NFS:   auth flavor[0]: 1
[ 4452.974723] NFS: MNT request succeeded
[ 4452.974785] NFS: using auth flavor 1
[ 4452.979498] VFS: Mounted root (nfs filesystem) on device 0:13.
INIT: version 2.88 booting
