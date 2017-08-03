Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33507 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751933AbdHCSax (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Aug 2017 14:30:53 -0400
Received: by mail-io0-f194.google.com with SMTP id q64so1832192ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 03 Aug 2017 11:30:53 -0700 (PDT)
Subject: [PATCH v1 7/7] xprtrdma: Clean up XDR decoding in
 rpcrdma_update_granted_credits()
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 03 Aug 2017 14:30:52 -0400
Message-ID: <20170803183052.14672.45308.stgit@manet.1015granger.net>
In-Reply-To: <20170803182623.14672.77636.stgit@manet.1015granger.net>
References: <20170803182623.14672.77636.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Replace C-structure based XDR decoding for consistency
with other areas.

struct rpcrdma_rep is rearranged slightly so that the relevant fields
are in cache when the Receive completion handler is invoked.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c     |    4 ++--
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 5d36c06..c78fb27 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -139,11 +139,11 @@
 static void
 rpcrdma_update_granted_credits(struct rpcrdma_rep *rep)
 {
-	struct rpcrdma_msg *rmsgp = rdmab_to_msg(rep->rr_rdmabuf);
 	struct rpcrdma_buffer *buffer = &rep->rr_rxprt->rx_buf;
+	__be32 *p = rep->rr_rdmabuf->rg_base;
 	u32 credits;
 
-	credits = be32_to_cpu(rmsgp->rm_credit);
+	credits = be32_to_cpup(p + 2);
 	if (credits == 0)
 		credits = 1;	/* don't deadlock */
 	else if (credits > buffer->rb_max_requests)
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index d4a897a..52e73ea 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -220,13 +220,13 @@ struct rpcrdma_rep {
 	struct ib_cqe		rr_cqe;
 	int			rr_wc_flags;
 	u32			rr_inv_rkey;
+	struct rpcrdma_regbuf	*rr_rdmabuf;
 	struct rpcrdma_xprt	*rr_rxprt;
 	struct work_struct	rr_work;
 	struct xdr_buf		rr_hdrbuf;
 	struct xdr_stream	rr_stream;
 	struct list_head	rr_list;
 	struct ib_recv_wr	rr_recv_wr;
-	struct rpcrdma_regbuf	*rr_rdmabuf;
 };
 
 /*

