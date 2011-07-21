Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59284 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751419Ab1GURtF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2011 13:49:05 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p6LHn48P016265
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 21 Jul 2011 13:49:04 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p6LHn3Xh025549
	for <linux-nfs@vger.kernel.org>; Thu, 21 Jul 2011 13:49:04 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] RDMA: Increasing RPCRDMA_MAX_DATA_SEGS
Date: Thu, 21 Jul 2011 13:49:02 -0400
Message-Id: <1311270542-2021-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Our performance team has noticed that increasing
RPCRDMA_MAX_DATA_SEGS from 8 to 64 significantly
increases throughput when using the RDMA transport.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index cae761a..5d1cfe5 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -109,7 +109,7 @@ struct rpcrdma_ep {
  */
 
 /* temporary static scatter/gather max */
-#define RPCRDMA_MAX_DATA_SEGS	(8)	/* max scatter/gather */
+#define RPCRDMA_MAX_DATA_SEGS	(64)	/* max scatter/gather */
 #define RPCRDMA_MAX_SEGS 	(RPCRDMA_MAX_DATA_SEGS + 2) /* head+tail = 2 */
 #define MAX_RPCRDMAHDR	(\
 	/* max supported RPC/RDMA header */ \
-- 
1.7.6

