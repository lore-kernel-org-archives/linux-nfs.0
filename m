Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:47973 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126AbaEVA4C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2014 20:56:02 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v4 12/24] xprtrmda: Reduce lock contention in completion
	handlers
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Wed, 21 May 2014 20:55:56 -0400
Message-ID: <20140522005556.27190.55959.stgit@manet.1015granger.net>
In-Reply-To: <20140522004505.27190.58897.stgit@manet.1015granger.net>
References: <20140522004505.27190.58897.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Skip the ib_poll_cq() after re-arming, if the provider knows there
are no additional items waiting. (Have a look at commit ed23a727 for
more details).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/verbs.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index af2d097..c7d5281 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -192,8 +192,11 @@ rpcrdma_sendcq_upcall(struct ib_cq *cq, void *cq_context)
 		return;
 	}
 
-	rc = ib_req_notify_cq(cq, IB_CQ_NEXT_COMP);
-	if (rc) {
+	rc = ib_req_notify_cq(cq,
+			IB_CQ_NEXT_COMP | IB_CQ_REPORT_MISSED_EVENTS);
+	if (rc == 0)
+		return;
+	if (rc < 0) {
 		dprintk("RPC:       %s: ib_req_notify_cq failed: %i\n",
 			__func__, rc);
 		return;
@@ -272,8 +275,11 @@ rpcrdma_recvcq_upcall(struct ib_cq *cq, void *cq_context)
 		return;
 	}
 
-	rc = ib_req_notify_cq(cq, IB_CQ_NEXT_COMP);
-	if (rc) {
+	rc = ib_req_notify_cq(cq,
+			IB_CQ_NEXT_COMP | IB_CQ_REPORT_MISSED_EVENTS);
+	if (rc == 0)
+		return;
+	if (rc < 0) {
 		dprintk("RPC:       %s: ib_req_notify_cq failed: %i\n",
 			__func__, rc);
 		return;

