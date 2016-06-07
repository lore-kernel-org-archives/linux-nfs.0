Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34341 "EHLO
	mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932285AbcFGTqh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 15:46:37 -0400
Subject: [PATCH v1 02/20] xprtrdma: Refactor ->ro_init
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 07 Jun 2016 15:46:35 -0400
Message-ID: <20160607194635.18401.66399.stgit@manet.1015granger.net>
In-Reply-To: <20160607194001.18401.88592.stgit@manet.1015granger.net>
References: <20160607194001.18401.88592.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Now that ALLPHYSICAL is gone, there is some buffer
initialization code that is common to remaining memory registration
modes. Move it into rpcrdma_buffer_create.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c  |    4 ----
 net/sunrpc/xprtrdma/frwr_ops.c |    4 ----
 net/sunrpc/xprtrdma/verbs.c    |    3 +++
 3 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 6326ebe..b8952c7 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -126,10 +126,6 @@ fmr_op_init(struct rpcrdma_xprt *r_xprt)
 	struct rpcrdma_mw *r;
 	int i, rc;
 
-	spin_lock_init(&buf->rb_mwlock);
-	INIT_LIST_HEAD(&buf->rb_mws);
-	INIT_LIST_HEAD(&buf->rb_all);
-
 	i = max_t(int, RPCRDMA_MAX_DATA_SEGS / RPCRDMA_MAX_FMR_SGES, 1);
 	i += 2;				/* head + tail */
 	i *= buf->rb_max_requests;	/* one set for each RPC slot */
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index c094754..6e0e5e8 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -355,10 +355,6 @@ frwr_op_init(struct rpcrdma_xprt *r_xprt)
 	struct ib_pd *pd = r_xprt->rx_ia.ri_pd;
 	int i;
 
-	spin_lock_init(&buf->rb_mwlock);
-	INIT_LIST_HEAD(&buf->rb_mws);
-	INIT_LIST_HEAD(&buf->rb_all);
-
 	i = max_t(int, RPCRDMA_MAX_DATA_SEGS / depth, 1);
 	i += 2;				/* head + tail */
 	i *= buf->rb_max_requests;	/* one set for each RPC slot */
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 7f09162..ecd494a 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -822,6 +822,9 @@ rpcrdma_buffer_create(struct rpcrdma_xprt *r_xprt)
 
 	buf->rb_max_requests = r_xprt->rx_data.max_requests;
 	buf->rb_bc_srv_max_requests = 0;
+	spin_lock_init(&buf->rb_mwlock);
+	INIT_LIST_HEAD(&buf->rb_mws);
+	INIT_LIST_HEAD(&buf->rb_all);
 	spin_lock_init(&buf->rb_lock);
 	atomic_set(&buf->rb_credits, 1);
 

