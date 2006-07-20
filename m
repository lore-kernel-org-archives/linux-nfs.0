From: Mario Storti <mstorti@intec.unl.edu.ar>
Subject: Re: NFS synchronization problems on Beowulf cluster
Date: 20 Jul 2006 08:35:40 -0300
Message-ID: <m1lkqopkz7.fsf@minerva.ceride.gov.ar>
References: <m1hd1gksev.fsf@minerva.ceride.gov.ar>
	<1153162159.13961.3.camel@localhost>
	<m1ejwjtb2t.fsf@minerva.ceride.gov.ar>
	<1153230531.22180.7.camel@localhost>
	<m1y7uopn3i.fsf@minerva.ceride.gov.ar>
	<1153393464.5856.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3Wqs-0008KN-1x
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 04:37:58 -0700
Received: from [200.9.237.134] (helo=intec.unl.edu.ar)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1G3Wqq-00079R-Ot
	for nfs@lists.sourceforge.net; Thu, 20 Jul 2006 04:37:58 -0700
Received: from minerva.ceride.gov.ar.ceride.gov.ar (localhost [127.0.0.1])
	by intec.unl.edu.ar (8.12.8/8.12.8) with ESMTP id k6KC8hm6017331
	for <nfs@lists.sourceforge.net>; Thu, 20 Jul 2006 09:08:44 -0300
To: nfs@lists.sourceforge.net
In-Reply-To: <1153393464.5856.12.camel@localhost>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


>>>>> On Thu, 20 Jul 2006 07:04:24 -0400, 
>>>>>      Trond Myklebust <trond.myklebust@fys.uio.no> said:

> On Thu, 2006-07-20 at 07:49 -0300, Mario Storti wrote:
>> I tried to do a `ls -l' of the directory and the contents of the files
>> are still out of sync. (I assume that `ls -l' does an `opendir()' call.)
>> 
>> Perhaps these questions are too basic for this list. In that case,
>> please redirect me to the appropriated list or newsgroup. 

> 'ls' does an opendir(), and should normally check that the cache is up
> to date. If that is not working, then something is indeed broken.

> Which mount options are you seeing this with? What kind of server are
> you using (if it is a Linux server, please could you specify the kernel
> version and the filesystem).

> Also please could you tell us if you can reproduce the problem on a more
> recent kernel version (2.6.9 is several years old).

Initially we built a Warewulf cluster built on Linux Fedora Core
3 (kernel 2.6.15). The cluster is disk-less (nodes don't have hard
disks). On the server the filesystem was XFS with Raid. On Warewulf
systems NFS traffic is reduced by using VNFS filesystems (RAM disks
containing /bin, /lib, etc...) at the nodes. 

As we detected the problem, we first suspected from XFS and Raid, so
we built a second system with FC3 but plain ext3 instead of XFS and no
RAID. The problem persisted. 

Then we switched to Scientific Linux 4.2 (It is equivalent to Red Hat
Enterprise Linux (RHEL) 4.2). Error persisted. 

Also we suspected of the Warewulf VNFS system (the RAM disks) and
plainly installed one server and two slave nodes but with disks at the
nodes, and the problem persisted. 

Also tried NFS version 2, and version 3 with TCP only, and UDP only. 

At this moment we are not using any mount options but we tried before
to use `acregmax=0,acdirmax=0,noac,nocto' at the nodes with no
effect. Also tried `async/sync' at the server side (we don't think
this would work, though). 

The cluster is for intensive numerical computations but all the
problems persist even when there is no computing load, neither network
traffic. Also we tried with only two slave nodes. 

There are no errors on the network, as reported by `ifconfig'. The
network is Gigabit Ethernet with 3Com switches and cards. The driver
is `sk98lin' version 8-31. 

Thanks for your time, 

Mario


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
