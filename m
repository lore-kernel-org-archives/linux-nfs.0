Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:34315 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754118AbbHCRE6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Aug 2015 13:04:58 -0400
Subject: [PATCH v4 15/16] core: Remove the ib_reg_phys_mr() and
 ib_rereg_phys_mr() verbs
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 03 Aug 2015 13:04:54 -0400
Message-ID: <20150803170454.9115.6141.stgit@manet.1015granger.net>
In-Reply-To: <20150803165807.9115.23842.stgit@manet.1015granger.net>
References: <20150803165807.9115.23842.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The verbs are obsolete. The ib_rereg_phys_mr() verb is not used by
kernel ULPs, and the last ib_reg_phys_mr() call site in the kernel
tree has now been removed.

Two staging tree call sites remain in the Lustre client. The Lustre
team has been notified of the deprecation of reg_phys_mr.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Doug Ledford <dledford@redhat.com>
---
 drivers/infiniband/core/verbs.c |   67 ---------------------------------------
 include/rdma/ib_verbs.h         |   46 ---------------------------
 2 files changed, 113 deletions(-)

diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index bac3fb4..30eb245 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -1144,73 +1144,6 @@ struct ib_mr *ib_get_dma_mr(struct ib_pd *pd, int mr_access_flags)
 }
 EXPORT_SYMBOL(ib_get_dma_mr);
 
-struct ib_mr *ib_reg_phys_mr(struct ib_pd *pd,
-			     struct ib_phys_buf *phys_buf_array,
-			     int num_phys_buf,
-			     int mr_access_flags,
-			     u64 *iova_start)
-{
-	struct ib_mr *mr;
-	int err;
-
-	err = ib_check_mr_access(mr_access_flags);
-	if (err)
-		return ERR_PTR(err);
-
-	if (!pd->device->reg_phys_mr)
-		return ERR_PTR(-ENOSYS);
-
-	mr = pd->device->reg_phys_mr(pd, phys_buf_array, num_phys_buf,
-				     mr_access_flags, iova_start);
-
-	if (!IS_ERR(mr)) {
-		mr->device  = pd->device;
-		mr->pd      = pd;
-		mr->uobject = NULL;
-		atomic_inc(&pd->usecnt);
-		atomic_set(&mr->usecnt, 0);
-	}
-
-	return mr;
-}
-EXPORT_SYMBOL(ib_reg_phys_mr);
-
-int ib_rereg_phys_mr(struct ib_mr *mr,
-		     int mr_rereg_mask,
-		     struct ib_pd *pd,
-		     struct ib_phys_buf *phys_buf_array,
-		     int num_phys_buf,
-		     int mr_access_flags,
-		     u64 *iova_start)
-{
-	struct ib_pd *old_pd;
-	int ret;
-
-	ret = ib_check_mr_access(mr_access_flags);
-	if (ret)
-		return ret;
-
-	if (!mr->device->rereg_phys_mr)
-		return -ENOSYS;
-
-	if (atomic_read(&mr->usecnt))
-		return -EBUSY;
-
-	old_pd = mr->pd;
-
-	ret = mr->device->rereg_phys_mr(mr, mr_rereg_mask, pd,
-					phys_buf_array, num_phys_buf,
-					mr_access_flags, iova_start);
-
-	if (!ret && (mr_rereg_mask & IB_MR_REREG_PD)) {
-		atomic_dec(&old_pd->usecnt);
-		atomic_inc(&pd->usecnt);
-	}
-
-	return ret;
-}
-EXPORT_SYMBOL(ib_rereg_phys_mr);
-
 int ib_query_mr(struct ib_mr *mr, struct ib_mr_attr *mr_attr)
 {
 	return mr->device->query_mr ?
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index b0f898e..43c1cf0 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -2760,52 +2760,6 @@ static inline void ib_dma_free_coherent(struct ib_device *dev,
 }
 
 /**
- * ib_reg_phys_mr - Prepares a virtually addressed memory region for use
- *   by an HCA.
- * @pd: The protection domain associated assigned to the registered region.
- * @phys_buf_array: Specifies a list of physical buffers to use in the
- *   memory region.
- * @num_phys_buf: Specifies the size of the phys_buf_array.
- * @mr_access_flags: Specifies the memory access rights.
- * @iova_start: The offset of the region's starting I/O virtual address.
- */
-struct ib_mr *ib_reg_phys_mr(struct ib_pd *pd,
-			     struct ib_phys_buf *phys_buf_array,
-			     int num_phys_buf,
-			     int mr_access_flags,
-			     u64 *iova_start);
-
-/**
- * ib_rereg_phys_mr - Modifies the attributes of an existing memory region.
- *   Conceptually, this call performs the functions deregister memory region
- *   followed by register physical memory region.  Where possible,
- *   resources are reused instead of deallocated and reallocated.
- * @mr: The memory region to modify.
- * @mr_rereg_mask: A bit-mask used to indicate which of the following
- *   properties of the memory region are being modified.
- * @pd: If %IB_MR_REREG_PD is set in mr_rereg_mask, this field specifies
- *   the new protection domain to associated with the memory region,
- *   otherwise, this parameter is ignored.
- * @phys_buf_array: If %IB_MR_REREG_TRANS is set in mr_rereg_mask, this
- *   field specifies a list of physical buffers to use in the new
- *   translation, otherwise, this parameter is ignored.
- * @num_phys_buf: If %IB_MR_REREG_TRANS is set in mr_rereg_mask, this
- *   field specifies the size of the phys_buf_array, otherwise, this
- *   parameter is ignored.
- * @mr_access_flags: If %IB_MR_REREG_ACCESS is set in mr_rereg_mask, this
- *   field specifies the new memory access rights, otherwise, this
- *   parameter is ignored.
- * @iova_start: The offset of the region's starting I/O virtual address.
- */
-int ib_rereg_phys_mr(struct ib_mr *mr,
-		     int mr_rereg_mask,
-		     struct ib_pd *pd,
-		     struct ib_phys_buf *phys_buf_array,
-		     int num_phys_buf,
-		     int mr_access_flags,
-		     u64 *iova_start);
-
-/**
  * ib_query_mr - Retrieves information about a specific memory region.
  * @mr: The memory region to retrieve information about.
  * @mr_attr: The attributes of the specified memory region.

