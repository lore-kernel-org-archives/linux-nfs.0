From: James Lentini <jlentini@netapp.com>
Subject: [RFC][PATCH] SUNRPC xptrdma: simplify build configuration
Date: Wed, 12 Dec 2007 11:03:16 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0712121059260.12638@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tom Tucker <tom@opengridcomputing.com>,
	Thomas Talpey <talpey@netapp.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49593 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753517AbXLLQDe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Dec 2007 11:03:34 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


During the review of Tom Tucker's server RPC/RDMA transport patchset, 
we receive a request to simplify the RPC/RDMA client and server build 
configuration.

To simplify the configuration, we propose to make XPRT_RDMA a hidden 
config option that continues to depend on SUNRPC and INFINIBAND. The 
value of XPRT_RDMA will be

 - N if either SUNRPC or INFINIBAND are N
 - M if both SUNRPC and INFINIBAND are on (M or Y) and at least one is M
 - Y if both SUNRPC and INFINIBAND are Y

In the next server RPC/RDMA transport patchset, we will group all the 
RPC/RDMA related files in net/sunrpc/xprtrdma and update the 
net/sunrpc/xprtrdma/Makefile to build both the client and server 
RPC/RDMA support using this config option.

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
