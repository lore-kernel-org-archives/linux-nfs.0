Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:38329 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940AbcD1PP2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Apr 2016 11:15:28 -0400
Subject: [PATCH 07/10] svcrdma: Eliminate code duplication in
 svc_rdma_recvfrom()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Thu, 28 Apr 2016 11:15:26 -0400
Message-ID: <20160428151526.13068.26423.stgit@klimt.1015granger.net>
In-Reply-To: <20160428150915.13068.94602.stgit@klimt.1015granger.net>
References: <20160428150915.13068.94602.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   26 +++++---------------------
 1 file changed, 5 insertions(+), 21 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 12e7899..1b72f35 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -508,11 +508,10 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 	return ret;
 }
 
-static int rdma_read_complete(struct svc_rqst *rqstp,
-			      struct svc_rdma_op_ctxt *head)
+static void rdma_read_complete(struct svc_rqst *rqstp,
+			       struct svc_rdma_op_ctxt *head)
 {
 	int page_no;
-	int ret;
 
 	/* Copy RPC pages */
 	for (page_no = 0; page_no < head->count; page_no++) {
@@ -548,23 +547,6 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
 	rqstp->rq_arg.tail[0] = head->arg.tail[0];
 	rqstp->rq_arg.len = head->arg.len;
 	rqstp->rq_arg.buflen = head->arg.buflen;
-
-	/* Free the context */
-	svc_rdma_put_context(head, 0);
-
-	/* XXX: What should this be? */
-	rqstp->rq_prot = IPPROTO_MAX;
-	svc_xprt_copy_addrs(rqstp, rqstp->rq_xprt);
-
-	ret = rqstp->rq_arg.head[0].iov_len
-		+ rqstp->rq_arg.page_len
-		+ rqstp->rq_arg.tail[0].iov_len;
-	dprintk("svcrdma: deferred read ret=%d, rq_arg.len=%u, "
-		"rq_arg.head[0].iov_base=%p, rq_arg.head[0].iov_len=%zu\n",
-		ret, rqstp->rq_arg.len,	rqstp->rq_arg.head[0].iov_base,
-		rqstp->rq_arg.head[0].iov_len);
-
-	return ret;
 }
 
 /* By convention, backchannel calls arrive via rdma_msg type
@@ -622,7 +604,8 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 				  dto_q);
 		list_del_init(&ctxt->dto_q);
 		spin_unlock_bh(&rdma_xprt->sc_rq_dto_lock);
-		return rdma_read_complete(rqstp, ctxt);
+		rdma_read_complete(rqstp, ctxt);
+		goto complete;
 	} else if (!list_empty(&rdma_xprt->sc_rq_dto_q)) {
 		ctxt = list_entry(rdma_xprt->sc_rq_dto_q.next,
 				  struct svc_rdma_op_ctxt,
@@ -680,6 +663,7 @@ int svc_rdma_recvfrom(struct svc_rqst *rqstp)
 		return 0;
 	}
 
+complete:
 	ret = rqstp->rq_arg.head[0].iov_len
 		+ rqstp->rq_arg.page_len
 		+ rqstp->rq_arg.tail[0].iov_len;

