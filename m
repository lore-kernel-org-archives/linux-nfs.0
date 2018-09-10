Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:53607 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727772AbeIJUFK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:05:10 -0400
Subject: [PATCH v1 19/22] xprtrdma: Report when there were zero posted
 Receives
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:10:36 -0400
Message-ID: <20180910151036.10564.44123.stgit@manet.1015granger.net>
In-Reply-To: <20180910150040.10564.97487.stgit@manet.1015granger.net>
References: <20180910150040.10564.97487.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To show that a caller did attempt to allocate and post more Receive
buffers, the trace point in rpcrdma_post_recvs() should report when
rpcrdma_post_recvs() was invoked but no new Receive buffers were
posted.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 74f6de3..0c56fe5 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1521,9 +1521,11 @@ struct rpcrdma_regbuf *
 	struct ib_recv_wr *wr, *bad_wr;
 	int needed, count, rc;
 
+	rc = 0;
+	count = 0;
 	needed = buf->rb_credits + (buf->rb_bc_srv_max_requests << 1);
 	if (buf->rb_posted_receives > needed)
-		return;
+		goto out;
 	needed -= buf->rb_posted_receives;
 
 	count = 0;
@@ -1559,7 +1561,7 @@ struct rpcrdma_regbuf *
 		--needed;
 	}
 	if (!count)
-		return;
+		goto out;
 
 	rc = ib_post_recv(r_xprt->rx_ia.ri_id->qp, wr,
 			  (const struct ib_recv_wr **)&bad_wr);
@@ -1573,5 +1575,6 @@ struct rpcrdma_regbuf *
 		}
 	}
 	buf->rb_posted_receives += count;
+out:
 	trace_xprtrdma_post_recvs(r_xprt, count, rc);
 }
