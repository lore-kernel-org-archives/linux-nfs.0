From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Fri, 18 Oct 2002 01:26:18 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021018.012618.74755132.taka@valinux.co.jp>
References: <003301c275e1$0bf76810$2a060e09@beavis>
	<20021017.222602.48536782.taka@valinux.co.jp>
	<001301c275e6$f31d5970$2a060e09@beavis>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, davem@redhat.com,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 182DaS-0002xe-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Oct 2002 09:33:28 -0700
To: habanero@us.ibm.com
In-Reply-To: <001301c275e6$f31d5970$2a060e09@beavis>
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

Hi,

> > How about IP datagrams?  You can see the IP fields in /proc/net/snmp
> > IP layer may also discard them.
> 
> Server:
> 
> Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors ForwDatagrams
> InUnknownProtos InDiscards InDelivers OutRequests OutDiscards OutNoRoutes
> ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails FragCreates
> Ip: 1 64 4088714 0 0 720 0 0 4086393 12233109 2 0 0 0 0 0 0 0 6000000
> 
> A Client:
> 
> Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors ForwDatagrams
> InUnknownProtos InDiscards InDelivers OutRequests OutDiscards OutNoRoutes
> ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails FragCreates
> Ip: 2 64 2115252 0 0 0 0 0 1115244 646510 0 0 0 1200000 200008 0 0 0 0

It looks fine.  
Hmmm....  What version of linux do you use?

Congestion avoidance mechanism of NFS clients might cause this situation.
I think the congestion window size is not enough for high end machines.
You can make the window be larger as a test.


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
