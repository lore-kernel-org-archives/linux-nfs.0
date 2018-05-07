Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:51896 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752721AbeEGT2W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 May 2018 15:28:22 -0400
Subject: [PATCH v1 17/19] svcrdma: Simplify svc_rdma_send()
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 07 May 2018 15:28:20 -0400
Message-ID: <20180507192820.4608.73544.stgit@klimt.1015granger.net>
In-Reply-To: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
References: <20180507192126.4608.63295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: No current caller of svc_rdma_send's passes in a chained
WR. The logic that counts the chain length can be replaced with a
constant (1).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 0ebdc0c..edfeca4 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -253,41 +253,41 @@ static void svc_rdma_wc_send(struct ib_cq *cq, struct ib_wc *wc)
 	svc_xprt_put(&rdma->sc_xprt);
 }
 
+/**
+ * svc_rdma_send - Post a single Send WR
+ * @rdma: transport on which to post the WR
+ * @wr: prepared Send WR to post
+ *
+ * Returns zero the Send WR was posted successfully. Otherwise, a
+ * negative errno is returned.
+ */
 int svc_rdma_send(struct svcxprt_rdma *rdma, struct ib_send_wr *wr)
 {
-	struct ib_send_wr *bad_wr, *n_wr;
-	int wr_count;
-	int i;
+	struct ib_send_wr *bad_wr;
 	int ret;
 
-	wr_count = 1;
-	for (n_wr = wr->next; n_wr; n_wr = n_wr->next)
-		wr_count++;
+	might_sleep();
 
 	/* If the SQ is full, wait until an SQ entry is available */
 	while (1) {
-		if ((atomic_sub_return(wr_count, &rdma->sc_sq_avail) < 0)) {
+		if ((atomic_dec_return(&rdma->sc_sq_avail) < 0)) {
 			atomic_inc(&rdma_stat_sq_starve);
 			trace_svcrdma_sq_full(rdma);
-			atomic_add(wr_count, &rdma->sc_sq_avail);
+			atomic_inc(&rdma->sc_sq_avail);
 			wait_event(rdma->sc_send_wait,
-				   atomic_read(&rdma->sc_sq_avail) > wr_count);
+				   atomic_read(&rdma->sc_sq_avail) > 1);
 			if (test_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags))
 				return -ENOTCONN;
 			trace_svcrdma_sq_retry(rdma);
 			continue;
 		}
-		/* Take a transport ref for each WR posted */
-		for (i = 0; i < wr_count; i++)
-			svc_xprt_get(&rdma->sc_xprt);
 
-		/* Bump used SQ WR count and post */
+		svc_xprt_get(&rdma->sc_xprt);
 		ret = ib_post_send(rdma->sc_qp, wr, &bad_wr);
 		trace_svcrdma_post_send(wr, ret);
 		if (ret) {
 			set_bit(XPT_CLOSE, &rdma->sc_xprt.xpt_flags);
-			for (i = 0; i < wr_count; i++)
-				svc_xprt_put(&rdma->sc_xprt);
+			svc_xprt_put(&rdma->sc_xprt);
 			wake_up(&rdma->sc_send_wait);
 		}
 		break;

