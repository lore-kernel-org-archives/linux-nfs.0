From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH supplemental 15/19] Add RDMA dependency
	to	SUNRPC_XPRT_RDMA
Date: Thu, 20 Sep 2007 18:00:15 -0400
Message-ID: <1190325615.6763.169.camel@heimdal.trondhjem.org>
References: <EXNANE01OSQeSOzNCWb00000575@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYU4L-0006MO-DZ
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 15:00:21 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IYU4O-00021t-RT
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 15:00:26 -0700
In-Reply-To: <EXNANE01OSQeSOzNCWb00000575@exnane01.hq.netapp.com>
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

On Thu, 2007-09-20 at 17:37 -0400, Talpey, Thomas wrote:
> RPCRDMA: Kconfig RDMA dependency
> 
> Add a dependency on RDMA before enabling SUNRPC_XPRT_RDMA
> Yes, "INFINIBAND" also turns on iWARP and other RDMA support.
> 
> Signed-off-by: Tom Talpey <talpey@netapp.com>

Thanks Tom!

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
