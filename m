Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f195.google.com ([209.85.166.195]:56302 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726353AbeJBBFf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 21:05:35 -0400
Subject: [PATCH v2 16/20] xprtrdma: Move rb_flags initialization
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:26:29 -0400
Message-ID: <20181001182629.18578.92430.stgit@manet.1015granger.net>
In-Reply-To: <20181001182005.18578.57544.stgit@manet.1015granger.net>
References: <20181001182005.18578.57544.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: rb_flags might be used for other things besides
RPCRDMA_BUF_F_EMPTY_SCQ, so initialize it in a generic spot
instead of in a send-completion-queue-related helper.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 9e04453..cfaab5e 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -918,7 +918,6 @@ static int rpcrdma_sendctxs_create(struct rpcrdma_xprt *r_xprt)
 		sc->sc_xprt = r_xprt;
 		buf->rb_sc_ctxs[i] = sc;
 	}
-	buf->rb_flags = 0;
 
 	return 0;
 
@@ -1146,6 +1145,7 @@ struct rpcrdma_req *
 	struct rpcrdma_buffer *buf = &r_xprt->rx_buf;
 	int i, rc;
 
+	buf->rb_flags = 0;
 	buf->rb_max_requests = r_xprt->rx_data.max_requests;
 	buf->rb_bc_srv_max_requests = 0;
 	spin_lock_init(&buf->rb_mrlock);
