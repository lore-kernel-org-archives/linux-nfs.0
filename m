Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm14.bullet.mail.ird.yahoo.com ([77.238.189.67]:47778 "HELO
	nm14.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750813Ab1KDBAF convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 21:00:05 -0400
References: <1320349396.90614.YahooMailNeo@web24707.mail.ird.yahoo.com> <1320353685.18396.119.camel@lade.trondhjem.org> <20111103211100.GA8393@umich.edu> <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com> <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com> <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com> <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com> <20111103235922.GA12527@umich.edu>
Message-ID: <1320368399.51438.YahooMailNeo@web24715.mail.ird.yahoo.com>
Date: Fri, 4 Nov 2011 00:59:59 +0000 (GMT)
From: Lukas Razik <linux@razik.name>
Reply-To: Lukas Razik <linux@razik.name>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
To: Jim Rees <rees@umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <20111103235922.GA12527@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I suspect some kind of timing problem, where the network interface hasn't

> come up yet at the time the portmap request is made.  What does your nfsroot
> kernel option look like?  What happens if you add ",port=2049" to the 
> end of
> your nfsroot kernel option?

That's my kernel line (and it's exactly the same for all kernel versions I used):
root=/dev/nfs rw nfsroot=137.226.167.241:/srv/nfs/cluster2 ip=137.226.167.242::137.226.167.225:255.255.255.224:cluster2:eth0:off nfsrootdebug
(I know that nfsrootdebug isn't available in older kernels but it doesn't matter...)

With ",port=2049" I get this from linux-2.6.29.4:
[  252.932407] IP-Config: Complete:
[  252.932476]      device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=137.226.167.225,
[  252.932680]      host=cluster2, domain=, nis-domain=(none),
[  252.932794]      bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
[  252.933230] Root-NFS: nfsroot=/srv/nfs/cluster2,port=2049
[  252.933523] NFS: nfs mount opts='udp,port=2049,nolock,addr=137.226.167.241'
[  252.933583] NFS:   parsing nfs mount option 'udp'
[  252.933621] NFS:   parsing nfs mount option 'port=2049'
[  252.933675] NFS:   parsing nfs mount option 'nolock'
[  252.933722] NFS:   parsing nfs mount option 'addr=137.226.167.241'
[  252.933787] NFS: MNTPATH: '/srv/nfs/cluster2'
[  252.933823] NFS: sending MNT request for 137.226.167.241:/srv/nfs/cluster2
[  254.038874] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
[  254.059251] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[  288.023684] NFS: failed to create MNT RPC client, status=-60
[  288.023793] NFS: unable to mount server 137.226.167.241, error -60
[  288.023929] VFS: Unable to mount root fs via NFS, trying floppy.
[  288.024092] VFS: Insert root floppy and press ENTER

So the result is the same as before...
In the past I also tried higher "timeo" and I think higher "retrans" values but also without a positive effect...
