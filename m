From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH] remove NFS/RDMA client's binary sysctls
Date: Mon, 26 Nov 2007 13:59:05 -0500
Message-ID: <EXNANE01tSgcOrBLSAQ00000a1c@exnane01.hq.netapp.com>
References: <Pine.LNX.4.64.0711261234400.7142@jlentini-linux.nane.netapp.com> <Pine.LNX.4.64.0711261234400.7142@jlentini-linux.nane.netap
 p.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net, linux-nfs@vger.kernel.org
To: James Lentini <jlentini@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6765 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753253AbXKZS7e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2007 13:59:34 -0500
In-Reply-To: <Pine.LNX.4.64.0711261234400.7142-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZeBImoM+uyKU@public.gmane.org
 p.com>
References: <Pine.LNX.4.64.0711261234400.7142-5zmYZXM8ymTNoO61VEKW3MYxy48AqY0ZOQ4dku92ua4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 12:42 PM 11/26/2007, James Lentini wrote:
>
>Support for binary sysctls is being deprecated in 2.6.24. Since there 
>are no applications using the NFS/RDMA client's binary sysctls, it 
>makes sense to remove them. The patch below does this while leaving 
>the /proc/sys interface unchanged.
>
>Please consider this for 2.6.24.

... as it produces a nasty warning when the NFS/RDMA client is loaded in
a post-24-rc2 kernel. :-)

Acked-by: Tom Talpey <tmt@netapp.com>

Tom.


>
>Signed-off-by: James Lentini <jlentini@netapp.com>
>
> include/linux/sunrpc/debug.h    |    5 -----
> net/sunrpc/xprtrdma/transport.c |   10 +++++-----
> 2 files changed, 5 insertions(+), 10 deletions(-)
>
>--- a/include/linux/sunrpc/debug.h
>+++ b/include/linux/sunrpc/debug.h
>@@ -88,11 +88,6 @@
> 	CTL_SLOTTABLE_TCP,
> 	CTL_MIN_RESVPORT,
> 	CTL_MAX_RESVPORT,
>-	CTL_SLOTTABLE_RDMA,
>-	CTL_RDMA_MAXINLINEREAD,
>-	CTL_RDMA_MAXINLINEWRITE,
>-	CTL_RDMA_WRITEPADDING,
>-	CTL_RDMA_MEMREG,
> };
> 
> #endif /* _LINUX_SUNRPC_DEBUG_H_ */
>--- a/net/sunrpc/xprtrdma/transport.c
>+++ b/net/sunrpc/xprtrdma/transport.c
>@@ -89,7 +89,7 @@
> 
> static ctl_table xr_tunables_table[] = {
> 	{
>-		.ctl_name	= CTL_SLOTTABLE_RDMA,
>+		.ctl_name       = CTL_UNNUMBERED,
> 		.procname	= "rdma_slot_table_entries",
> 		.data		= &xprt_rdma_slot_table_entries,
> 		.maxlen		= sizeof(unsigned int),
>@@ -100,7 +100,7 @@
> 		.extra2		= &max_slot_table_size
> 	},
> 	{
>-		.ctl_name	= CTL_RDMA_MAXINLINEREAD,
>+		.ctl_name       = CTL_UNNUMBERED,
> 		.procname	= "rdma_max_inline_read",
> 		.data		= &xprt_rdma_max_inline_read,
> 		.maxlen		= sizeof(unsigned int),
>@@ -109,7 +109,7 @@
> 		.strategy	= &sysctl_intvec,
> 	},
> 	{
>-		.ctl_name	= CTL_RDMA_MAXINLINEWRITE,
>+		.ctl_name       = CTL_UNNUMBERED,
> 		.procname	= "rdma_max_inline_write",
> 		.data		= &xprt_rdma_max_inline_write,
> 		.maxlen		= sizeof(unsigned int),
>@@ -118,7 +118,7 @@
> 		.strategy	= &sysctl_intvec,
> 	},
> 	{
>-		.ctl_name	= CTL_RDMA_WRITEPADDING,
>+		.ctl_name       = CTL_UNNUMBERED,
> 		.procname	= "rdma_inline_write_padding",
> 		.data		= &xprt_rdma_inline_write_padding,
> 		.maxlen		= sizeof(unsigned int),
>@@ -129,7 +129,7 @@
> 		.extra2		= &max_padding,
> 	},
> 	{
>-		.ctl_name	= CTL_RDMA_MEMREG,
>+		.ctl_name       = CTL_UNNUMBERED,
> 		.procname	= "rdma_memreg_strategy",
> 		.data		= &xprt_rdma_memreg_strategy,
> 		.maxlen		= sizeof(unsigned int),
