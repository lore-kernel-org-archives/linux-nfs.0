From: Chris Penney <cpenney@gmail.com>
Subject: Re: NFS tuning - high performance throughput.
Date: Tue, 14 Jun 2005 17:04:16 -0400
Message-ID: <111aefd050614140472f81157@mail.gmail.com>
References: <20050610031144.4B9CA12F8C@sc8-sf-spam2.sourceforge.net>
	 <42AF3B6C.6070901@sohovfx.com>
Reply-To: penney@msu.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DiIa4-0007pO-QZ
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 14:04:20 -0700
Received: from wproxy.gmail.com ([64.233.184.192])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DiIa2-0002cS-90
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 14:04:20 -0700
Received: by wproxy.gmail.com with SMTP id 71so98132wra
        for <nfs@lists.sourceforge.net>; Tue, 14 Jun 2005 14:04:16 -0700 (PDT)
To: "M. Todd Smith" <todd@sohovfx.com>
In-Reply-To: <42AF3B6C.6070901@sohovfx.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>  Local RW is ~135Mbytes/sec

That seems slow for LSI disks.  I use LSI disk (STK rebrand) and have
one HBA connected to controller A and the other HBA to controller B.=20
I then have two 1TB luns primary on A and B (so a total of 4 TB).  I
get ~300MB/s.  I'm wondering if you are striping across controllers
and what file system you use (I use JFS).

How are you chaining the luns into one volume?  I use the device
mapper (4 multipath devices =3D> 1 linear).

> I have read most of the tuning guides I can find on the net and
> attempted just about everything I can get my hands on (I have not tried
> jumbo frames yet, still waiting for some downtime to attempt that).  My
> problem is that no matter how I tune the machines I can get at max
> 45Mb/ps throughput on NFS.=20

That is pretty low, esp. if you are talking about reads, which I can
get >100MB/s with only a single e1000 card.  I use the following mount
options:

Client: nosuid,rw,bg,hard,intr,vers=3D3,proto=3Dtcp,rsize=3D32768,wsize=3D3=
2768
Server: rw,sync,no_subtree_check,no_root_squash

I use 128 NFS threads (which in SuSE is set in /etc/sysconfig/nfs).

In /etc/sysctl.conf I have (can't say how well tuned these are):
net.core.rmem_default =3D 262144
net.core.wmem_default =3D 262144
net.core.rmem_max =3D 8388608
net.core.wmem_max =3D 8388608
net.ipv4.tcp_rmem =3D 4096 87380 8388608
net.ipv4.tcp_wmem =3D 4096 65536 8388608
net.ipv4.tcp_mem =3D 8388608 8388608 8388608

I've also found that enabling hyperthreading is a good thing for NFS.=20
Under load using etheral I show an improvement in write/read/commit
latency using HT.  I'm also using SLES 9.

   Chris


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
