Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52740 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754000AbbG3Hdd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jul 2015 03:33:33 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org,
        target-devel@vger.kernel.org
Subject: [PATCH for-4.3 06/15] xprtrdma, svcrdma: Convert to ib_alloc_mr
Date: Thu, 30 Jul 2015 10:32:39 +0300
Message-Id: <1438241568-3685-7-git-send-email-sagig@mellanox.com>
In-Reply-To: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
References: <1438241568-3685-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
---
 net/sunrpc/xprtrdma/frwr_ops.c           | 6 +++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 63f282e..d6653f5 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -117,7 +117,7 @@ __frwr_recovery_worker(struct work_struct *work)
 	if (ib_dereg_mr(r->r.frmr.fr_mr))
 		goto out_fail;
 
-	r->r.frmr.fr_mr = ib_alloc_fast_reg_mr(pd, depth);
+	r->r.frmr.fr_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG, depth);
 	if (IS_ERR(r->r.frmr.fr_mr))
 		goto out_fail;
 
@@ -148,7 +148,7 @@ __frwr_init(struct rpcrdma_mw *r, struct ib_pd *pd, struct ib_device *device,
 	struct rpcrdma_frmr *f = &r->r.frmr;
 	int rc;
 
-	f->fr_mr = ib_alloc_fast_reg_mr(pd, depth);
+	f->fr_mr = ib_alloc_mr(pd, IB_MR_TYPE_MEM_REG, depth);
 	if (IS_ERR(f->fr_mr))
 		goto out_mr_err;
 	f->fr_pgl = ib_alloc_fast_reg_page_list(device, depth);
@@ -158,7 +158,7 @@ __frwr_init(struct rpcrdma_mw *r, struct ib_pd *pd, struct ib_device *device,
 
 out_mr_err:
 	rc = PTR_ERR(f->fr_mr);
-	dprintk("RPC:       %s: ib_alloc_fast_reg_mr status %i\n",
+	dprintk("RPC:       %s: ib_alloc_mr status %i\n",
 		__func__, rc);
 	return rc;
 
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 6b36279..adcf904 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -738,7 +738,7 @@ static struct svc_rdma_fastreg_mr *rdma_alloc_frmr(struct svcxprt_rdma *xprt)
 	if (!frmr)
 		goto err;
 
-	mr = ib_alloc_fast_reg_mr(xprt->sc_pd, RPCSVC_MAXPAGES);
+	mr = ib_alloc_mr(xprt->sc_pd, IB_MR_TYPE_MEM_REG, RPCSVC_MAXPAGES);
 	if (IS_ERR(mr))
 		goto err_free_frmr;
 
-- 
1.8.4.3

