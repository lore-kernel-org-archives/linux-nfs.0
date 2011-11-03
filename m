Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm12.bullet.mail.ird.yahoo.com ([77.238.189.65]:28834 "HELO
	nm12.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750792Ab1KCTtM convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 15:49:12 -0400
Message-ID: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com>
Date: Thu, 3 Nov 2011 19:43:16 +0000 (GMT)
From: Lukas Razik <linux@razik.name>
Reply-To: Lukas Razik <linux@razik.name>
Subject: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello together!

My OS: Debian 6.0.3 (squeeze)
Machines: SUN Enterprise T5120 (USPARC64)
---
Issue description:

I've an NFS
server (cluster1=137.226.167.241) and a
client (cluster2=137.226.167.242) which should mount it's nfsroot from cluster1.

The linux-2.6.32 kernel on cluster2 shows this during startup:
[ 528.982985] IP-Config: Complete:
[ 528.983049] device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=137.226.167.225,
[ 528.983299] host=cluster2, domain=, nis-domain=(none),
[ 528.983383] bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
[ 528.983633] Looking up port of RPC 100003/2 on 137.226.167.241
[ 530.037059] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
[ 530.056881] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[ 564.002113] rpcbind: server 137.226.167.241 not responding, timed out
[ 564.002295] Root-NFS: Unable to get nfsd port number from server, using default
[ 564.002412] Looking up port of RPC 100005/1 on 137.226.167.241
[ 564.104137] VFS: Mounted root (nfs filesystem) on device 0:15.

It can mount the nfsroot finally.

But if I use kernel linux-2.6.39.4 on cluster2 it can't mount it's nfsroot.
(I've added "nfsdebug" to the kernel arguments for more debug info):
[ 407.571521] IP-Config: Complete:
[ 407.571589] device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=137.226.167.225,
[ 407.571793] host=cluster2, domain=, nis-domain=(none),
[ 407.571907] bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
[ 407.572332] Root-NFS: nfsroot=/srv/nfs/cluster2
[ 407.572726] NFS: nfs mount opts='udp,nolock,addr=137.226.167.241'
[ 407.572927] NFS: parsing nfs mount option 'udp'
[ 407.572995] NFS: parsing nfs mount option 'nolock'
[ 407.573071] NFS: parsing nfs mount option 'addr=137.226.167.241'
[ 407.573139] NFS: MNTPATH: '/srv/nfs/cluster2'
[ 407.573203] NFS: sending MNT request for 137.226.167.241:/srv/nfs/cluster2
[ 408.617894] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
[ 408.638319] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[ 442.666622] NFS: failed to create MNT RPC client, status=-60
[ 442.666732] NFS: unable to mount server 137.226.167.241, error -60
[ 442.666868] VFS: Unable to mount root fs via NFS, trying floppy.
[ 442.667032] VFS: Insert root floppy and press ENTER


The NFS _server_ is always the same.
In 2.6.32, 2.6.33, 2.6.35, 2,6.36 and 2.6.36.4 an NFS mount for nfsroot works fine.
I've tested these kernels where the issue occurs: 2.6.37, 2.6.38, 2.6.39.4.
So there's a break between 2.6.36.4 and 2.6.37.

If you need more information - please ask!
The problem is that I need a kernel >= 2.6.37 because of some other issues...
So I'm very thankful for each help and I provide all needed information very fast.


Regards,
Lukas


PS:
My kernel-configs:
http://net.razik.de/linux/T5120/

And here the NFS parts:
linux-2.6.36.4# grep NFS .config
 CONFIG_NFS_FS=y
 CONFIG_NFS_V3=y
 CONFIG_NFS_V3_ACL=y
 CONFIG_NFS_V4=y
 # CONFIG_NFS_V4_1 is not set
 CONFIG_ROOT_NFS=y
 # CONFIG_NFS_USE_LEGACY_DNS is not set
 CONFIG_NFS_USE_KERNEL_DNS=y
 CONFIG_NFSD=m
 CONFIG_NFSD_V2_ACL=y
 CONFIG_NFSD_V3=y
 CONFIG_NFSD_V3_ACL=y
 CONFIG_NFSD_V4=y
 CONFIG_NFS_ACL_SUPPORT=y
 CONFIG_NFS_COMMON=y
 CONFIG_NCPFS_NFS_NS=y


linux-2.6.37# grep NFS .config
 CONFIG_NFS_FS=y
 CONFIG_NFS_V3=y
 CONFIG_NFS_V3_ACL=y
 CONFIG_NFS_V4=y
 # CONFIG_NFS_V4_1 is not set
 CONFIG_ROOT_NFS=y
 # CONFIG_NFS_USE_LEGACY_DNS is not set
 CONFIG_NFS_USE_KERNEL_DNS=y
 # CONFIG_NFS_USE_NEW_IDMAPPER is not set
 CONFIG_NFSD=m
 CONFIG_NFSD_DEPRECATED=y
 CONFIG_NFSD_V2_ACL=y
 CONFIG_NFSD_V3=y
 CONFIG_NFSD_V3_ACL=y
 CONFIG_NFSD_V4=y
 CONFIG_NFS_ACL_SUPPORT=y
 CONFIG_NFS_COMMON=y
 CONFIG_NCPFS_NFS_NS=y
