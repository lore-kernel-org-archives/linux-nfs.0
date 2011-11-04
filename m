Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm11.bullet.mail.ird.yahoo.com ([77.238.189.64]:47126 "HELO
	nm11.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932453Ab1KDPqo convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 11:46:44 -0400
References: <1320353685.18396.119.camel@lade.trondhjem.org> <20111103211100.GA8393@umich.edu> <FB7123DC-86FB-4A19-A1B6-67B23D4B47B9@oracle.com> <1320356241.80563.YahooMailNeo@web24706.mail.ird.yahoo.com> <92DF2E31-FABF-40A5-8F78-89B64363568B@oracle.com> <1320361764.48851.YahooMailNeo@web24708.mail.ird.yahoo.com> <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com> <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com> <20111104132050.GB13788@umich.edu> <01668DEE-43F7-464B-9BCF-6E52DF0B5956@oracle.com> <20111104144617.GB911@umich.edu>
Message-ID: <1320421602.96030.YahooMailNeo@web24707.mail.ird.yahoo.com>
Date: Fri, 4 Nov 2011 15:46:42 +0000 (GMT)
From: Lukas Razik <linux@razik.name>
Reply-To: Lukas Razik <linux@razik.name>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
To: Jim Rees <rees@umich.edu>, Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <20111104144617.GB911@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>   > As for a fix...  we're trying to move away from udp transport 

> anyway.  Maybe
>   > someone should figure out a way to get it to work with tcp?  I have zero
>   > experience with nfs over udp, at least on linux.  Just for fun, have you
>   > tried tcp transport (proto=tcp)?
>   
>   TCP is a real problem in this environment, because it deals poorly with
>   NIC initialization timing issues.  UDP is still the best approach (as long
>   as it is retransmitting appropriately).  To support TCP, ultimately what
>   we need to do is to introduce serialization to make the kernel wait for
>   the NIC to become ready before attempting network activity.
> 
> Agreed, but we're grasping at straws here, and this guy just wants it to
> work.  It's something to try.

I've tried that but "proto=tcp" is no way to change the protocol in linux-2.6.39.4.
It uses the udp protocol and in "Documentation/filesystems/nfs/nfsroot.txt" there's no "proto" option (or something similar).
[11140.866623] IP-Config: Complete:
[11140.866692]      device=eth0, addr=137.226.167.242, mask=255.255.255.224, gw=137.226.167.225,
[11140.866895]      host=cluster2, domain=, nis-domain=(none),
[11140.867008]      bootserver=255.255.255.255, rootserver=137.226.167.241, rootpath=
[11140.867431] Root-NFS: nfsroot=/srv/nfs/cluster2,proto=tcp,retrans=10,timeo=60
[11140.867728] NFS: nfs mount opts='udp,proto=tcp,retrans=10,timeo=60,nolock,addr=137.226.167.241'
[11140.867797] NFS:   parsing nfs mount option 'udp'
[11140.867836] NFS:   parsing nfs mount option 'proto=tcp'
[11140.867895] NFS:   parsing nfs mount option 'retrans=10'
[11140.867946] NFS:   parsing nfs mount option 'timeo=60'
[11140.867996] NFS:   parsing nfs mount option 'nolock'
[11140.868043] NFS:   parsing nfs mount option 'addr=137.226.167.241'
[11140.868106] NFS: MNTPATH: '/srv/nfs/cluster2'
[11140.868142] NFS: sending MNT request for 137.226.167.241:/srv/nfs/cluster2
[11141.912761] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: Rx
[11141.933177] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[11143.873095] NFS: failed to create MNT RPC client, status=-65
[11143.873205] NFS: unable to mount server 137.226.167.241, error -65
[11143.873339] VFS: Unable to mount root fs via NFS, trying floppy.
[11143.873494] VFS: Insert root floppy and press ENTER

Now I'll try the other workaround idea: netboot from tftp (to bring eth0 up) and subsequent nfsroot mount.
Therefore I need a customized (and rather small) kernel...

Regards,
Lukas
