From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] SUNRPC xptrdma: simplify build configuration
Date: Mon, 28 Jan 2008 19:14:00 -0500
Message-ID: <20080129001400.GZ16785@fieldses.org>
References: <Pine.LNX.4.64.0801281146160.2989@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Tom Tucker <tom@opengridcomputing.com>,
	Thomas Talpey <talpey@netapp.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42526 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752897AbYA2AOW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 19:14:22 -0500
In-Reply-To: <Pine.LNX.4.64.0801281146160.2989-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 12:09:28PM -0500, James Lentini wrote:
> 
> Trond and Bruce,
> 
> This is a patch for 2.6.25. This is the same version that was sent out 
> on December 12 for review (no comments to date).
> 
> To simplify the RPC/RDMA client and server build configuration, make 
> SUNRPC_XPRT_RDMA a hidden config option that continues to depend on 
> SUNRPC and INFINIBAND. The value of SUNRPC_XPRT_RDMA will be:
> 
>  - N if either SUNRPC or INFINIBAND are N
>  - M if both SUNRPC and INFINIBAND are on (M or Y) and at least one is M
>  - Y if both SUNRPC and INFINIBAND are Y
> 
> In 2.6.25, all of the RPC/RDMA related files are grouped in 
> net/sunrpc/xprtrdma and the net/sunrpc/xprtrdma/Makefile builds both 
> the client and server RPC/RDMA support using this config option.

Makes sense to me.  (Trond?  Could you apply this or do you want me to?)

--b.

> 
> Signed-off-by: James Lentini <jlentini@netapp.com>
> 
>  Kconfig |    7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
> 
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -1782,12 +1782,9 @@
>  	tristate
>  
>  config SUNRPC_XPRT_RDMA
> -	tristate "RDMA transport for sunrpc (EXPERIMENTAL)"
> +	tristate
>  	depends on SUNRPC && INFINIBAND && EXPERIMENTAL
> -	default m
> -	help
> -	  Adds a client RPC transport for supporting kernel NFS over RDMA
> -	  mounts, including Infiniband and iWARP. Experimental.
> +	default SUNRPC && INFINIBAND
>  
>  config SUNRPC_BIND34
>  	bool "Support for rpcbind versions 3 & 4 (EXPERIMENTAL)"
