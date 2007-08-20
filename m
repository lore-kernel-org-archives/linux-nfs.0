From: Tom Tucker <tom@opengridcomputing.com>
Subject: [RFC,PATCH 02/10] rdma: sysctl for SVCRDMA transport module
Date: Mon, 20 Aug 2007 11:58:05 -0500
Message-ID: <20070820165805.15938.92400.stgit@dell3.ogc.int>
References: <20070820165635.15938.57184.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1INAZs-0001ug-6q
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:58:08 -0700
Received: from smtp.opengridcomputing.com ([71.42.183.126])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1INAZv-00051E-IA
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 09:58:11 -0700
Received: from dell3.ogc.int (localhost [127.0.0.1])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id AE2D27C79D
	for <nfs@lists.sourceforge.net>; Mon, 20 Aug 2007 11:58:05 -0500 (CDT)
In-Reply-To: <20070820165635.15938.57184.stgit@dell3.ogc.int>
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


Add sysctl flags for SVCRDMA transport module debug messages.

Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
---

 include/linux/sunrpc/debug.h |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/debug.h b/include/linux/sunrpc/debug.h
index 89458df..ea7ae15 100644
--- a/include/linux/sunrpc/debug.h
+++ b/include/linux/sunrpc/debug.h
@@ -52,7 +52,7 @@ #endif
 #define dprintk(args...)	dfprintk(FACILITY, ## args)
 
 #undef ifdebug
-#ifdef RPC_DEBUG			
+#ifdef RPC_DEBUG
 # define ifdebug(fac)		if (unlikely(rpc_debug & RPCDBG_##fac))
 # define dfprintk(fac, args...)	do { ifdebug(fac) printk(args); } while(0)
 # define RPC_IFDEBUG(x)		x
@@ -89,6 +89,19 @@ enum {
 	CTL_MIN_RESVPORT,
 	CTL_MAX_RESVPORT,
 	CTL_TRANSPORTS,
+	CTL_SVCRDMA,
+	CTL_RDMA_MAX_REQUESTS,
+	CTL_RDMA_MAX_REQ_SIZE,
+	CTL_RDMA_ORD,
+	CTL_RDMA_STAT_RECV,
+	CTL_RDMA_STAT_READ,
+	CTL_RDMA_STAT_WRITE,
+	CTL_RDMA_STAT_SQ_STARVE,
+	CTL_RDMA_STAT_RQ_STARVE,
+	CTL_RDMA_STAT_RQ_POLL,
+	CTL_RDMA_STAT_RQ_PROD,
+	CTL_RDMA_STAT_SQ_POLL,
+	CTL_RDMA_STAT_SQ_PROD
 };
 
 #endif /* _LINUX_SUNRPC_DEBUG_H_ */

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
