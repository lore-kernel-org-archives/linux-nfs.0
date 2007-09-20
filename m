From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 15/19] RPCRDMA: Kconfig and header file
	with	rpcrdma protocol definitions
Date: Thu, 20 Sep 2007 16:55:05 -0400
Message-ID: <1190321705.6763.140.camel@heimdal.trondhjem.org>
References: <EXNANE013MBhe3WYIgo000004be@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYT3Z-0008DM-Sw
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 13:55:31 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IYT3c-0001ir-9w
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 13:55:34 -0700
In-Reply-To: <EXNANE013MBhe3WYIgo000004be@exnane01.hq.netapp.com>
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

On Mon, 2007-09-10 at 13:49 -0400, Talpey, Thomas wrote:

> +config SUNRPC_XPRT_RDMA
> +	tristate "RDMA transport for sunrpc (EXPERIMENTAL)"
> +	depends on SUNRPC && EXPERIMENTAL
> +	default m
> +	help
> +	  Adds a client RPC transport for supporting kernel NFS over RDMA
> +	  mounts, including Infiniband and iWARP. Experimental.
> +

Hmm... There is a dependency on the Infiniband code that is missing
here. I'm getting the following compile errors:

ERROR: "ib_dealloc_pd" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "ib_dealloc_mw" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_destroy_id" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "ib_alloc_mw" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "ib_modify_qp" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_connect" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "ib_unmap_fmr" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "ib_alloc_pd" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "ib_get_dma_mr" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "ib_query_device" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_destroy_qp" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_create_id" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "ib_destroy_cq" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_create_qp" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_resolve_route" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "ib_dealloc_fmr" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_disconnect" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "ib_alloc_fmr" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "ib_query_qp" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "ib_dereg_mr" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "ib_reg_phys_mr" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "rdma_resolve_addr" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
ERROR: "ib_create_cq" [net/sunrpc/xprtrdma/xprtrdma.ko] undefined!
make[2]: *** [__modpost] Error 1
make[1]: *** [modules] Error 2
make: *** [modules] Error 2

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
