From: "Andrew Theurer" <habanero@us.ibm.com>
Subject: Re: huge number of intr/s on large nfs server
Date: Thu, 17 Oct 2002 08:33:41 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <004401c275e1$cf940170$2a060e09@beavis>
References: <CFEAJJEGMGECBCJFLGDBGEMACFAA.enorwood@effrem.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mg02.austin.ibm.com ([192.35.232.12])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 182AgQ-0000l2-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Oct 2002 06:27:26 -0700
To: "Eff Norwood" <enorwood@effrem.com>
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


> This system in question is a SuperMicro P4DL6 MB with dual Xeon 2.4's and
> 2.0GB of memory. One of the PCI-X slots/busses has a 3ware 7850 IDE RAID
> card that is *not* using its on card raid. Two more of the PCI-X
> slots/busses have Syskonnect SK-9821 copper gigabit cards. I'm using x8
IBM
> Deskstar 120GB drives configured via IBM's EVMS 1.2.0 as software RAID5.
> Distro is Debian 3.0 Woody stable. Kernel is 2.4.19 with all of Neil
Brown's
> latest KNFSD patches from his web site. Syskonnect and 3ware driver are
> those found in the 2.4.19 kernel.

Eff, do you happen to know the cpu utilization for the local mulitple dd
test?  I am concerned that the evms_raid5d is eating up a lot of cpu, which
is fine for the local dd test, but may be too much when nfsd is running.

Andrew Theurer



-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
