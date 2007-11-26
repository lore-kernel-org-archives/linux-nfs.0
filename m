From: James Lentini <jlentini@netapp.com>
Subject: [PATCH] remove NFS/RDMA client's binary sysctls
Date: Mon, 26 Nov 2007 12:42:44 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0711261234400.7142@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Thomas Talpey <talpey@netapp.com>, nfs@lists.sourceforge.net,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7416 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752064AbXKZRms (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2007 12:42:48 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Support for binary sysctls is being deprecated in 2.6.24. Since there 
are no applications using the NFS/RDMA client's binary sysctls, it 
makes sense to remove them. The patch below does this while leaving 
the /proc/sys interface unchanged.

Please consider this for 2.6.24.

Signed-off-by: James Lentini <jlentini@netapp.com>

 include/linux/sunrpc/debug.h    |    5 -----
 net/sunrpc/xprtrdma/transport.c |   10 +++++-----
 2 files changed, 5 insertions(+), 10 deletions(-)

--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -88,11 +88,6 @@
 	CTL_SLOTTABLE_TCP,
 	CTL_MIN_RESVPORT,
 	CTL_MAX_RESVPORT,
-	CTL_SLOTTABLE_RDMA,
-	CTL_RDMA_MAXINLINEREAD,
-	CTL_RDMA_MAXINLINEWRITE,
-	CTL_RDMA_WRITEPADDING,
-	CTL_RDMA_MEMREG,
 };
 
 #endif /* _LINUX_SUNRPC_DEBUG_H_ */
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -89,7 +89,7 @@
 
 static ctl_table xr_tunables_table[] = {
 	{
-		.ctl_name	= CTL_SLOTTABLE_RDMA,
+		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_slot_table_entries",
 		.data		= &xprt_rdma_slot_table_entries,
 		.maxlen		= sizeof(unsigned int),
@@ -100,7 +100,7 @@
 		.extra2		= &max_slot_table_size
 	},
 	{
-		.ctl_name	= CTL_RDMA_MAXINLINEREAD,
+		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_max_inline_read",
 		.data		= &xprt_rdma_max_inline_read,
 		.maxlen		= sizeof(unsigned int),
@@ -109,7 +109,7 @@
 		.strategy	= &sysctl_intvec,
 	},
 	{
-		.ctl_name	= CTL_RDMA_MAXINLINEWRITE,
+		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_max_inline_write",
 		.data		= &xprt_rdma_max_inline_write,
 		.maxlen		= sizeof(unsigned int),
@@ -118,7 +118,7 @@
 		.strategy	= &sysctl_intvec,
 	},
 	{
-		.ctl_name	= CTL_RDMA_WRITEPADDING,
+		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_inline_write_padding",
 		.data		= &xprt_rdma_inline_write_padding,
 		.maxlen		= sizeof(unsigned int),
@@ -129,7 +129,7 @@
 		.extra2		= &max_padding,
 	},
 	{
-		.ctl_name	= CTL_RDMA_MEMREG,
+		.ctl_name       = CTL_UNNUMBERED,
 		.procname	= "rdma_memreg_strategy",
 		.data		= &xprt_rdma_memreg_strategy,
 		.maxlen		= sizeof(unsigned int),
