From: "Eff Norwood" <enorwood@effrem.com>
Subject: RE: huge number of intr/s on large nfs server
Date: Wed, 16 Oct 2002 19:49:38 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFEAJJEGMGECBCJFLGDBGEMACFAA.enorwood@effrem.com>
References: <20021016222854.C27038@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cynaptic.com ([128.121.116.181])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1820jO-0008Sl-00
	for <nfs@lists.sourceforge.net>; Wed, 16 Oct 2002 19:49:50 -0700
To: "Benjamin LaHaise" <bcrl@redhat.com>
In-Reply-To: <20021016222854.C27038@redhat.com>
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

> What NIC are you using?  High numbers of interrupts per second are not
> necessarily the problem, but reducing it may be possible.  Diagnosing
> these kinds of performance issues is near impossible without a complete
> description of the system, and the identity of the NIC/driver is
> essential.

Hi Ben,

This system in question is a SuperMicro P4DL6 MB with dual Xeon 2.4's and
2.0GB of memory. One of the PCI-X slots/busses has a 3ware 7850 IDE RAID
card that is *not* using its on card raid. Two more of the PCI-X
slots/busses have Syskonnect SK-9821 copper gigabit cards. I'm using x8 IBM
Deskstar 120GB drives configured via IBM's EVMS 1.2.0 as software RAID5.
Distro is Debian 3.0 Woody stable. Kernel is 2.4.19 with all of Neil Brown's
latest KNFSD patches from his web site. Syskonnect and 3ware driver are
those found in the 2.4.19 kernel.

Switch is a Foundry BigIron and clients are 30 x SuperMicro SuperServer
6010H with dual PIII 1.0Ghz, 1024MB of RAM, and Syskonnect SK-9821 copper
gigabit cards also running Debian 3.0 Stable with kernel 2.4.19 and all of
Trond's latest NFS client patches.

Thanks!

Eff




-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
