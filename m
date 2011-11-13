Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm12.bullet.mail.ird.yahoo.com ([77.238.189.65]:44705 "HELO
	nm12.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753120Ab1KMBDx convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 12 Nov 2011 20:03:53 -0500
References: <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com> <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com> <06799B7D-54CD-41D8-934A-F9C78B23677C@oracle.com> <1320450001.87605.YahooMailNeo@web24706.mail.ird.yahoo.com> <1320455965.2750.9.camel@lade.trondhjem.org> <1320459252.59518.YahooMailNeo@web24716.mail.ird.yahoo.com> <1320460311.2750.21.camel@lade.trondhjem.org> <1320465106.61111.YahooMailNeo@web24710.mail.ird.yahoo.com> <20111105130517.GA16090@umich.edu> <1321097734.7117.YahooMailNeo@web24701.mail.ird.yahoo.com> <20111112184804.GA25581@umich.edu> <1E7FF4C1-B7BA-4429-92ED-DC90D6B269C4@oracle.com>
Message-ID: <1321146230.5436.YahooMailNeo@web24710.mail.ird.yahoo.com>
Date: Sun, 13 Nov 2011 01:03:50 +0000 (GMT)
From: Lukas Razik <linux@razik.name>
Reply-To: Lukas Razik <linux@razik.name>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
To: Chuck Lever <chuck.lever@oracle.com>, Jim Rees <rees@umich.edu>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <1E7FF4C1-B7BA-4429-92ED-DC90D6B269C4@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever <chuck.lever@oracle.com> wrote:

> On Nov 12, 2011, at 1:49 PM, Jim Rees wrote:
> 
>>  The question for us is how long should an nfsroot client wait for the 
> server
>>  to reply.  It sounds like the client used to wait longer than it does now.
> 
> Before, the client performed the GETPORT(NFS) step synchronously, first.  This 
> took 30 seconds or so to timeout.  When it did, the client decided to proceed 
> with port 2049.  Then it went on to do the other mount tasks, and at the point 
> had waited long enough that these tasks did not time out while waiting for the 
> switch port.
> 
>>  It seems to me the client should wait at least 90 seconds so that the
>>  situation you're in (servers on non-portfast ports) will work.  I would
>>  think they should wait indefinitely, since there's not much else they 
> can
>>  do.
> 
> It should be simple to wrap the (MNT(mnt), NFS(getroot)) steps in a while(true) 
> loop.  Would mount_root_nfs() be the right place for this?
> 

I thought it would be harder and I had no time to look inside the kernel but now I wrote a patch:
The kernel tries to create the MNT RPC client not once as before but three times - then it gives up.
Third time lucky... ;-)
In my case the 2. MNT request is successful:
---
[   71.594744] ADDRCONF(NETDEV_UP): eth0: link is not ready
[   72.617007] IP-Config: Complete:
[   72.617077]      device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=137.226.167.225,
[   72.617278]      host=137.226.167.242, domain=, nis-domain=(none),
[   72.617393]      bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
[   72.617741] Root-NFS: nfsroot=/srv/nfs/cluster2
[   72.618010] NFS: nfs mount opts='udp,nolock,addr=137.226.167.241'
[   72.618147] NFS:   parsing nfs mount option 'udp'
[   72.618187] NFS:   parsing nfs mount option 'nolock'
[   72.618233] NFS:   parsing nfs mount option 'addr=137.226.167.241'
[   72.618301] NFS: MNTPATH: '/srv/nfs/cluster2'
[   72.618335] NFS: sending MNT request for 137.226.167.241:/srv/nfs/cluster2
[   72.618383] NFS: 1. MNT request
[   73.691872] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
[   73.711988] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  107.697332] NFS: 2. MNT request
[  107.704591] NFS: received 1 auth flavors
[  107.704653] NFS:   auth flavor[0]: 1
[  107.704834] NFS: MNT request succeeded
[  107.704897] NFS: using auth flavor 1
[  107.711857] VFS: Mounted root (nfs filesystem) on device 0:13.
INIT: version 2.88 booting
---

So many thanks again for your help and your very helpful hints!

Regards,
Lukas


PS: That's what I've done:
--- linux-2.6.39.4/fs/nfs/mount_clnt.c  2011-08-03 21:43:28.000000000 +0200
+++ linux-2.6.39.4-fix/fs/nfs/mount_clnt.c      2011-11-13 01:58:13.000000000 +0100
@@ -164,6 +164,7 @@
        };
        struct rpc_clnt         *mnt_clnt;
        int                     status;
+       int                     attempt = 0;
 
        dprintk("NFS: sending MNT request for %s:%s\n",
                (info->hostname ? info->hostname : "server"),
@@ -172,7 +173,13 @@
        if (info->noresvport)
                args.flags |= RPC_CLNT_CREATE_NONPRIVPORT;
 
-       mnt_clnt = rpc_create(&args);
+       do {
+               attempt++;
+               dprintk("NFS: %d. MNT request\n", attempt);
+               mnt_clnt = rpc_create(&args);
+       } while (IS_ERR(mnt_clnt) && attempt < 3);
+
+
        if (IS_ERR(mnt_clnt))
                goto out_clnt_err;
--
