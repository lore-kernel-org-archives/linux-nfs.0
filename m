From: "Eff Norwood" <enorwood@effrem.com>
Subject: RE: huge number of intr/s on large nfs server
Date: Tue, 15 Oct 2002 09:50:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFEAJJEGMGECBCJFLGDBMEIACFAA.enorwood@effrem.com>
References: <Pine.LNX.4.44.0210150951240.19850-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>, "Daniel Phillips" <phillips@arcor.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cynaptic.com ([128.121.116.181])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181Utq-0007k7-00
	for <nfs@lists.sourceforge.net>; Tue, 15 Oct 2002 09:50:30 -0700
To: "Bogdan Costescu" <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0210150951240.19850-100000@kenzo.iwr.uni-heidelberg.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> > Also interesting is what UNKNOWN_KERNEL is. ???
>
> Do you have any binary-only modules in the running kernel ?

Not that I am aware of.

> > The server described above has 14 internal IDE disks configured
> as software
> > Raid 5 and connected to the network with one Syskonnect copper
> gigabit card.
>
> Please confirm: you have at least 7 IDE controllers.

No. I have a 3ware card that turns 8 ide disks into 8 SCSI disks for all
intensive purposes.

> If so, how are the
> interrupts associated to them (look in /proc/interrupts) ? Are there
> shared interrupts ? Is the NIC sharing an interrupt line with at
> least one
> IDE controller ?

No, the 3ware card has its own interrupt as do each of the gigabit
interfaces. Each card (3ware, gigabit) is also on its own bus. The
SuperMicro MB I'm using has x4 PCI-X busses and one card is in each.

> However, NFS might not be a good network test in this case, maybe
> ftp - or
> anything TCP based - would have been better.

I agree but I need to use NFS.

> > I used 30 100 base-T connected clients all of which performed sequential
> > writes to one large 1.3TB volume on the file server. They were mounted
> > NFSv2, UDP, 8K r+w size for this run.
>
> Err, you have a GE NIC in the server and FE NICs in the clients.

Correct - connected through a Foundry switch.

> Running
> NFS over UDP might not the best solution in this case; try NFS over TCP.

I tried this and it was *much* worse. NFS over TCP seems pretty broken right
now in terms of throughput. Certainly much worse than UDP.

> > I was able to achieve only 35MB/sec of sustained NFS write throughput.
> > Local disk performance (e.g. dd file)  for sustained writes is *much*
> > higher.
>
> I think that a better disk
> test would
> be to try to do all the 30 writes simultaneously on the server
> itself with
> "dd" or something similar, so that the network is not involved.

This might get us better numbers, but I'm looking to fix the performance
over the network - not on local disk. Yes, my test was to have 30 individual
clients dd 10MB files over NFS to the server.

Thanks,

Eff




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
