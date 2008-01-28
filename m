From: James Lentini <jlentini@netapp.com>
Subject: [PATCH] SUNRPC xptrdma: simplify build configuration
Date: Mon, 28 Jan 2008 12:09:28 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0801281146160.2989@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Thomas Talpey <talpey@netapp.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14729 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754934AbYA1RJc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 12:09:32 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Trond and Bruce,

This is a patch for 2.6.25. This is the same version that was sent out 
on December 12 for review (no comments to date).

To simplify the RPC/RDMA client and server build configuration, make 
SUNRPC_XPRT_RDMA a hidden config option that continues to depend on 
SUNRPC and INFINIBAND. The value of SUNRPC_XPRT_RDMA will be:

 - N if either SUNRPC or INFINIBAND are N
 - M if both SUNRPC and INFINIBAND are on (M or Y) and at least one is M
 - Y if both SUNRPC and INFINIBAND are Y

In 2.6.25, all of the RPC/RDMA related files are grouped in 
net/sunrpc/xprtrdma and the net/sunrpc/xprtrdma/Makefile builds both 
the client and server RPC/RDMA support using this config option.

Signed-off-by: James Lentini <jlentini@netapp.com>

 Kconfig |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1782,12 +1782,9 @@
 	tristate
 
 config SUNRPC_XPRT_RDMA
-	tristate "RDMA transport for sunrpc (EXPERIMENTAL)"
+	tristate
 	depends on SUNRPC && INFINIBAND && EXPERIMENTAL
-	default m
-	help
-	  Adds a client RPC transport for supporting kernel NFS over RDMA
-	  mounts, including Infiniband and iWARP. Experimental.
+	default SUNRPC && INFINIBAND
 
 config SUNRPC_BIND34
 	bool "Support for rpcbind versions 3 & 4 (EXPERIMENTAL)"
