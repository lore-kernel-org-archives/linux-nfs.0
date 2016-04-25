Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:36370 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933240AbcDYTWq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2016 15:22:46 -0400
Subject: [PATCH v2 14/18] xprtrdma: Move fr_xprt and fr_worker to struct
 rpcrdma_mw
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2016 15:22:42 -0400
Message-ID: <20160425192242.3566.71335.stgit@manet.1015granger.net>
In-Reply-To: <20160425185956.3566.64142.stgit@manet.1015granger.net>
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In a subsequent patch, the fr_xprt and fr_worker fields will be
needed by another memory registration mode. Move them into the
generic rpcrdma_mw structure that wraps struct rpcrdma_frmr.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c  |   10 +++++-----
 net/sunrpc/xprtrdma/xprt_rdma.h |    4 ++--
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 4e0a5c1..1251a1d 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -150,9 +150,9 @@ static void
 __frwr_recovery_worker(struct work_struct *work)
 {
 	struct rpcrdma_mw *r = container_of(work, struct rpcrdma_mw,
-					    frmr.fr_work);
+					    mw_work);
 
-	__frwr_reset_and_unmap(r->frmr.fr_xprt, r);
+	__frwr_reset_and_unmap(r->mw_xprt, r);
 	return;
 }
 
@@ -162,8 +162,8 @@ __frwr_recovery_worker(struct work_struct *work)
 static void
 __frwr_queue_recovery(struct rpcrdma_mw *r)
 {
-	INIT_WORK(&r->frmr.fr_work, __frwr_recovery_worker);
-	queue_work(frwr_recovery_wq, &r->frmr.fr_work);
+	INIT_WORK(&r->mw_work, __frwr_recovery_worker);
+	queue_work(frwr_recovery_wq, &r->mw_work);
 }
 
 static int
@@ -378,9 +378,9 @@ frwr_op_init(struct rpcrdma_xprt *r_xprt)
 			return rc;
 		}
 
+		r->mw_xprt = r_xprt;
 		list_add(&r->mw_list, &buf->rb_mws);
 		list_add(&r->mw_all, &buf->rb_all);
-		r->frmr.fr_xprt = r_xprt;
 	}
 
 	return 0;
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 0b3aa54..61d5cce 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -227,8 +227,6 @@ struct rpcrdma_frmr {
 	struct ib_cqe			fr_cqe;
 	enum rpcrdma_frmr_state		fr_state;
 	struct completion		fr_linv_done;
-	struct work_struct		fr_work;
-	struct rpcrdma_xprt		*fr_xprt;
 	union {
 		struct ib_reg_wr	fr_regwr;
 		struct ib_send_wr	fr_invwr;
@@ -245,6 +243,8 @@ struct rpcrdma_mw {
 		struct rpcrdma_fmr	fmr;
 		struct rpcrdma_frmr	frmr;
 	};
+	struct work_struct	mw_work;
+	struct rpcrdma_xprt	*mw_xprt;
 	struct list_head	mw_list;
 	struct list_head	mw_all;
 };

