Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49837 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754824Ab1KCSWm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 14:22:42 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pA3IMgjT030931
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 3 Nov 2011 14:22:42 -0400
Received: from fathat.boston.devel.redhat.com (fathat.boston.devel.redhat.com [10.16.60.125])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id pA3IMg9v017767
	for <linux-nfs@vger.kernel.org>; Thu, 3 Nov 2011 14:22:42 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] RDMA: RPCRDMA_MAX_DATA_SEGS cause i686 stack to blow.
Date: Thu,  3 Nov 2011 14:52:38 -0400
Message-Id: <1320346359-1515-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 2773395b3 increased RPCRDMA_MAX_DATA_SEGS from 8
to 64 which significantly increases throughput with the
RDMA transport.

Unfortunately making RPCRDMA_MAX_DATA_SEGS that large blows
the stack on i686 builds during compilation. So the
RPCRDMA_MAX_PHYSREG_DATA_SEGS is used to allocated data on
the stack.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 net/sunrpc/xprtrdma/verbs.c     |    6 +++---
 net/sunrpc/xprtrdma/xprt_rdma.h |    1 +
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 28236ba..68ba0fb 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1729,11 +1729,11 @@ rpcrdma_register_default_external(struct rpcrdma_mr_seg *seg,
 	int mem_priv = (writing ? IB_ACCESS_REMOTE_WRITE :
 				  IB_ACCESS_REMOTE_READ);
 	struct rpcrdma_mr_seg *seg1 = seg;
-	struct ib_phys_buf ipb[RPCRDMA_MAX_DATA_SEGS];
+	struct ib_phys_buf ipb[RPCRDMA_MAX_PHYSREG_DATA_SEGS];
 	int len, i, rc = 0;
 
-	if (*nsegs > RPCRDMA_MAX_DATA_SEGS)
-		*nsegs = RPCRDMA_MAX_DATA_SEGS;
+	if (*nsegs > RPCRDMA_MAX_PHYSREG_DATA_SEGS)
+		*nsegs = RPCRDMA_MAX_PHYSREG_DATA_SEGS;
 	for (len = 0, i = 0; i < *nsegs;) {
 		rpcrdma_map_one(ia, seg, writing);
 		ipb[i].addr = seg->mr_dma;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 08c5d5a..8d588f2 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -110,6 +110,7 @@ struct rpcrdma_ep {
 
 /* temporary static scatter/gather max */
 #define RPCRDMA_MAX_DATA_SEGS	(64)	/* max scatter/gather */
+#define RPCRDMA_MAX_PHYSREG_DATA_SEGS	(16)
 #define RPCRDMA_MAX_SEGS 	(RPCRDMA_MAX_DATA_SEGS + 2) /* head+tail = 2 */
 #define MAX_RPCRDMAHDR	(\
 	/* max supported RPC/RDMA header */ \
-- 
1.7.1

