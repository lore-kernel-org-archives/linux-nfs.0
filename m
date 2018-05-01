Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:46274 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756009AbeEAPhQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 May 2018 11:37:16 -0400
Subject: [PATCH v1 1/2] xprtrdma: Fix list corruption / DMAR errors during
 MR recovery
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Tue, 01 May 2018 11:37:14 -0400
Message-ID: <20180501153714.5863.5219.stgit@manet.1015granger.net>
In-Reply-To: <20180501153109.5863.33183.stgit@manet.1015granger.net>
References: <20180501153109.5863.33183.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The ro_release_mr methods check whether mr->mr_list is empty.
Therefore, be sure to always use list_del_init when removing an MR
linked into a list using that field. Otherwise, when recovering from
transport failures or device removal, list corruption can result, or
MRs can get mapped or unmapped an odd number of times, resulting in
IOMMU-related failures.

In general this fix is appropriate back to v4.8. However, code
changes since then make it impossible to apply this patch directly
to stable kernels. The fix would have to be applied by hand or
reworked for kernels earlier than v4.16.

Backport guidance -- there are several cases:
- When creating an MR, initialize mr_list so that using list_empty
  on an as-yet-unused MR is safe.
- When an MR is being handled by the remote invalidation path,
  ensure that mr_list is reinitialized when it is removed from
  rl_registered.
- When an MR is being handled by rpcrdma_destroy_mrs, it is removed
  from mr_all, but it may still be on an rl_registered list. In
  that case, the MR needs to be removed from that list before being
  released.
- Other cases are covered by using list_del_init in rpcrdma_mr_pop.

Fixes: 9d6b04097882 ('xprtrdma: Place registered MWs on a ... ')
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/fmr_ops.c   |    5 +----
 net/sunrpc/xprtrdma/frwr_ops.c  |    9 +++------
 net/sunrpc/xprtrdma/verbs.c     |    5 +++++
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 +-
 4 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/xprtrdma/fmr_ops.c b/net/sunrpc/xprtrdma/fmr_ops.c
index 5cc68a8..f2f6395 100644
--- a/net/sunrpc/xprtrdma/fmr_ops.c
+++ b/net/sunrpc/xprtrdma/fmr_ops.c
@@ -72,6 +72,7 @@ enum {
 	if (IS_ERR(mr->fmr.fm_mr))
 		goto out_fmr_err;
 
+	INIT_LIST_HEAD(&mr->mr_list);
 	return 0;
 
 out_fmr_err:
@@ -102,10 +103,6 @@ enum {
 	LIST_HEAD(unmap_list);
 	int rc;
 
-	/* Ensure MW is not on any rl_registered list */
-	if (!list_empty(&mr->mr_list))
-		list_del(&mr->mr_list);
-
 	kfree(mr->fmr.fm_physaddrs);
 	kfree(mr->mr_sg);
 
diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index c5743a0..c59c5c7 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -110,6 +110,7 @@
 	if (!mr->mr_sg)
 		goto out_list_err;
 
+	INIT_LIST_HEAD(&mr->mr_list);
 	sg_init_table(mr->mr_sg, depth);
 	init_completion(&frwr->fr_linv_done);
 	return 0;
@@ -133,10 +134,6 @@
 {
 	int rc;
 
-	/* Ensure MR is not on any rl_registered list */
-	if (!list_empty(&mr->mr_list))
-		list_del(&mr->mr_list);
-
 	rc = ib_dereg_mr(mr->frwr.fr_mr);
 	if (rc)
 		pr_err("rpcrdma: final ib_dereg_mr for %p returned %i\n",
@@ -195,7 +192,7 @@
 	return;
 
 out_release:
-	pr_err("rpcrdma: FRWR reset failed %d, %p release\n", rc, mr);
+	pr_err("rpcrdma: FRWR reset failed %d, %p released\n", rc, mr);
 	r_xprt->rx_stats.mrs_orphaned++;
 
 	spin_lock(&r_xprt->rx_buf.rb_mrlock);
@@ -476,7 +473,7 @@
 
 	list_for_each_entry(mr, mrs, mr_list)
 		if (mr->mr_handle == rep->rr_inv_rkey) {
-			list_del(&mr->mr_list);
+			list_del_init(&mr->mr_list);
 			trace_xprtrdma_remoteinv(mr);
 			mr->frwr.fr_state = FRWR_IS_INVALID;
 			rpcrdma_mr_unmap_and_put(mr);
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index fe5eaca..c345d36 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1254,6 +1254,11 @@ struct rpcrdma_req *
 		list_del(&mr->mr_all);
 
 		spin_unlock(&buf->rb_mrlock);
+
+		/* Ensure MW is not on any rl_registered list */
+		if (!list_empty(&mr->mr_list))
+			list_del(&mr->mr_list);
+
 		ia->ri_ops->ro_release_mr(mr);
 		count++;
 		spin_lock(&buf->rb_mrlock);
diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 3d3b423..cb41b12 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -380,7 +380,7 @@ enum {
 	struct rpcrdma_mr *mr;
 
 	mr = list_first_entry(list, struct rpcrdma_mr, mr_list);
-	list_del(&mr->mr_list);
+	list_del_init(&mr->mr_list);
 	return mr;
 }
 

