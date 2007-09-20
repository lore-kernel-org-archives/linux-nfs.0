From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 15/19] RPCRDMA: Kconfig and header
	file	with	rpcrdma protocol definitions
Date: Thu, 20 Sep 2007 17:25:50 -0400
Message-ID: <1190323550.6763.157.camel@heimdal.trondhjem.org>
References: <EXNANE013MBhe3WYIgo000004be@exnane01.hq.netapp.com>
	<1190321705.6763.140.camel@heimdal.trondhjem.org>
	<EXNANE01Uor03u9PH3I00000571@exnane01.hq.netapp.com>
	<1190322784.6763.147.camel@heimdal.trondhjem.org>
	<EXNANE01qSkcJse1fTv00000573@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYTX4-0002v2-Jc
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 14:25:58 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IYTX5-0007OR-K3
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 14:26:02 -0700
In-Reply-To: <EXNANE01qSkcJse1fTv00000573@exnane01.hq.netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-09-20 at 17:18 -0400, Talpey, Thomas wrote:

> One reason to prefer "select" is that the option will disappear if
> it "depends on" and INFINIBAND isn't turned on. That's not the
> way RPC over sockets transports is visible. For example, if TCP is
> off you still get SUNRPC.

Not really. If networking isn't defined, then it disappears.

I'd think that it would be fairly obvious to most people that if they
want to see an option to use NFS over RDMA, then they also have to
select an RDMA-capable transport.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
