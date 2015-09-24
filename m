Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41930 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757380AbbIXRgh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2015 13:36:37 -0400
From: Sagi Grimberg <sagig@mellanox.com>
To: linux-rdma@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: [PATCH v2 01/26] IB/core: Introduce new fast registration API
Date: Thu, 24 Sep 2015 20:34:53 +0300
Message-Id: <1443116118-10730-2-git-send-email-sagig@mellanox.com>
In-Reply-To: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
References: <1443116118-10730-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new fast registration  verb ib_map_mr_sg receives a scatterlist
and converts it to a page list under the verbs API thus hiding
the specific HW mapping details away from the consumer.

The provider drivers are provided with a generic helper ib_sg_to_pages
that converts a scatterlist into a vector of page addresses. The
drivers can still perform any HW specific page address setting
by passing a set_page function pointer which will be invoked for
each page address. This allows drivers to avoid keeping a shadow
page vectors and convert them to HW specific translations by doing
extra copies.

This API will allow ULPs to remove the duplicated code of constructing
a page vector from a given sg list.

The send work request ib_reg_wr also shrinks as it will contain only
mr, key and access flags in addition.

Signed-off-by: Sagi Grimberg <sagig@mellanox.com>
Tested-by: Christoph Hellwig <hch@lst.de>
Tested-by: Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 drivers/infiniband/core/verbs.c | 107 ++++++++++++++++++++++++++++++++++++++++
 include/rdma/ib_verbs.h         |  44 +++++++++++++++++
 2 files changed, 151 insertions(+)

diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index e1f2c9887f3f..b84d168f6e21 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -1469,3 +1469,110 @@ int ib_check_mr_status(struct ib_mr *mr, u32 check_mask,
 		mr->device->check_mr_status(mr, check_mask, mr_status) : -ENOSYS;
 }
 EXPORT_SYMBOL(ib_check_mr_status);
+
+/**
+ * ib_map_mr_sg() - Map the largest prefix of a dma mapped SG list
+ *     and set it the memory region.
+ * @mr:            memory region
+ * @sg:            dma mapped scatterlist
+ * @sg_nents:      number of entries in sg
+ * @page_size:     page vector desired page size
+ *
+ * Constraints:
+ * - The first sg element is allowed to have an offset.
+ * - Each sg element must be aligned to page_size (or physically
+ *   contiguous to the previous element). In case an sg element has a
+ *   non contiguous offset, the mapping prefix will not include it.
+ * - The last sg element is allowed to have length less than page_size.
+ * - If sg_nents total byte length exceeds the mr max_num_sge * page_size
+ *   then only max_num_sg entries will be mapped.
+ *
+ * Returns the number of sg elements that were mapped to the memory region.
+ *
+ * After this completes successfully, the  memory region
+ * is ready for registration.
+ */
+int ib_map_mr_sg(struct ib_mr *mr,
+		 struct scatterlist *sg,
+		 unsigned int sg_nents,
+		 unsigned int page_size)
+{
+	if (unlikely(!mr->device->map_mr_sg))
+		return -ENOSYS;
+
+	mr->page_size = page_size;
+
+	return mr->device->map_mr_sg(mr, sg, sg_nents);
+}
+EXPORT_SYMBOL(ib_map_mr_sg);
+
+/**
+ * ib_sg_to_pages() - Convert the largest prefix of a sg list
+ *     to a page vector
+ * @mr:            memory region
+ * @sgl:           dma mapped scatterlist
+ * @sg_nents:      number of entries in sg
+ * @set_page:      driver page assignment function pointer
+ *
+ * Core service helper for drivers to covert the largest
+ * prefix of given sg list to a page vector. The sg list
+ * prefix converted is the prefix that meet the requirements
+ * of ib_map_mr_sg.
+ *
+ * Returns the number of sg elements that were assigned to
+ * a page vector.
+ */
+int ib_sg_to_pages(struct ib_mr *mr,
+		   struct scatterlist *sgl,
+		   unsigned int sg_nents,
+		   int (*set_page)(struct ib_mr *, u64))
+{
+	struct scatterlist *sg;
+	u64 last_end_dma_addr = 0, last_page_addr = 0;
+	unsigned int last_page_off = 0;
+	u64 page_mask = ~((u64)mr->page_size - 1);
+	int i;
+
+	mr->iova = sg_dma_address(&sgl[0]);
+	mr->length = 0;
+
+	for_each_sg(sgl, sg, sg_nents, i) {
+		u64 dma_addr = sg_dma_address(sg);
+		unsigned int dma_len = sg_dma_len(sg);
+		u64 end_dma_addr = dma_addr + dma_len;
+		u64 page_addr = dma_addr & page_mask;
+
+		if (i && page_addr != dma_addr) {
+			if (last_end_dma_addr != dma_addr) {
+				/* gap */
+				goto done;
+
+			} else if (last_page_off + dma_len < mr->page_size) {
+				/* chunk this fragment with the last */
+				mr->length += dma_len;
+				last_end_dma_addr += dma_len;
+				last_page_off += dma_len;
+				continue;
+			} else {
+				/* map starting from the next page */
+				page_addr = last_page_addr + mr->page_size;
+				dma_len -= mr->page_size - last_page_off;
+			}
+		}
+
+		do {
+			if (unlikely(set_page(mr, page_addr)))
+				goto done;
+			page_addr += mr->page_size;
+		} while (page_addr < end_dma_addr);
+
+		mr->length += dma_len;
+		last_end_dma_addr = end_dma_addr;
+		last_page_addr = end_dma_addr & page_mask;
+		last_page_off = end_dma_addr & ~page_mask;
+	}
+
+done:
+	return i;
+}
+EXPORT_SYMBOL(ib_sg_to_pages);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index edf02908a0fd..f9a3436702c8 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -737,6 +737,7 @@ enum ib_wc_opcode {
 	IB_WC_LSO,
 	IB_WC_LOCAL_INV,
 	IB_WC_FAST_REG_MR,
+	IB_WC_REG_MR,
 	IB_WC_MASKED_COMP_SWAP,
 	IB_WC_MASKED_FETCH_ADD,
 /*
@@ -1029,6 +1030,7 @@ enum ib_wr_opcode {
 	IB_WR_RDMA_READ_WITH_INV,
 	IB_WR_LOCAL_INV,
 	IB_WR_FAST_REG_MR,
+	IB_WR_REG_MR,
 	IB_WR_MASKED_ATOMIC_CMP_AND_SWP,
 	IB_WR_MASKED_ATOMIC_FETCH_AND_ADD,
 	IB_WR_BIND_MW,
@@ -1161,6 +1163,18 @@ static inline struct ib_fast_reg_wr *fast_reg_wr(struct ib_send_wr *wr)
 	return container_of(wr, struct ib_fast_reg_wr, wr);
 }
 
+struct ib_reg_wr {
+	struct ib_send_wr	wr;
+	struct ib_mr		*mr;
+	u32			key;
+	int			access;
+};
+
+static inline struct ib_reg_wr *reg_wr(struct ib_send_wr *wr)
+{
+	return container_of(wr, struct ib_reg_wr, wr);
+}
+
 struct ib_bind_mw_wr {
 	struct ib_send_wr	wr;
 	struct ib_mw		*mw;
@@ -1373,6 +1387,9 @@ struct ib_mr {
 	struct ib_uobject *uobject;
 	u32		   lkey;
 	u32		   rkey;
+	u64		   iova;
+	u32		   length;
+	unsigned int	   page_size;
 	atomic_t	   usecnt; /* count number of MWs */
 };
 
@@ -1757,6 +1774,9 @@ struct ib_device {
 	struct ib_mr *		   (*alloc_mr)(struct ib_pd *pd,
 					       enum ib_mr_type mr_type,
 					       u32 max_num_sg);
+	int                        (*map_mr_sg)(struct ib_mr *mr,
+						struct scatterlist *sg,
+						unsigned int sg_nents);
 	struct ib_fast_reg_page_list * (*alloc_fast_reg_page_list)(struct ib_device *device,
 								   int page_list_len);
 	void			   (*free_fast_reg_page_list)(struct ib_fast_reg_page_list *page_list);
@@ -3062,4 +3082,28 @@ struct net_device *ib_get_net_dev_by_params(struct ib_device *dev, u8 port,
 					    u16 pkey, const union ib_gid *gid,
 					    const struct sockaddr *addr);
 
+int ib_map_mr_sg(struct ib_mr *mr,
+		 struct scatterlist *sg,
+		 unsigned int sg_nents,
+		 unsigned int page_size);
+
+static inline int
+ib_map_mr_sg_zbva(struct ib_mr *mr,
+		  struct scatterlist *sg,
+		  unsigned int sg_nents,
+		  unsigned int page_size)
+{
+	int n;
+
+	n = ib_map_mr_sg(mr, sg, sg_nents, page_size);
+	mr->iova = 0;
+
+	return n;
+}
+
+int ib_sg_to_pages(struct ib_mr *mr,
+		   struct scatterlist *sgl,
+		   unsigned int sg_nents,
+		   int (*set_page)(struct ib_mr *, u64));
+
 #endif /* IB_VERBS_H */
-- 
1.8.4.3

