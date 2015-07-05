Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:51031 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752786AbbGEXWA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Jul 2015 19:22:00 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH V3 1/5] RDMA/core: Transport-independent access flags
To: dledford@redhat.com
Cc: sagig@mellanox.com, ogerlitz@mellanox.com, roid@mellanox.com,
        linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, bfields@fieldses.org
Date: Sun, 05 Jul 2015 18:22:00 -0500
Message-ID: <20150705232158.12029.25472.stgit@build2.ogc.int>
In-Reply-To: <20150705231831.12029.80307.stgit@build2.ogc.int>
References: <20150705231831.12029.80307.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The semantics for MR access flags are not consistent across RDMA
protocols.  So rather than have applications try and glean what they
need, have them pass in the intended roles and attributes for the MR to
be allocated and let the RDMA core select the appropriate access flags
given the roles, attributes, and device capabilities.

We introduce rdma_mr_roles and rdma_mr_attributes that enumerate the
possible roles and attributes for a MR.  These are documented in the
enums themselves.

New services exported:

rdma_device_access_flags() - given the intended MR roles and attributes
passed in, return the ib_access_flags bits for the device.

rdma_get_dma_mr() - allocate a dma mr using the applications intended
MR roles and MR attributes.  This uses rdma_device_access_flags().

rdma_fast_reg_access_flags() - return the ib_access_flags bits needed
for a fast register WR given the applications intended MR roles and
MR attributes.  This uses rdma_device_access_flags().

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/core/verbs.c |   30 +++++++++++
 include/rdma/ib_verbs.h         |  106 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 136 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/core/verbs.c b/drivers/infiniband/core/verbs.c
index bac3fb4..f42595c 100644
--- a/drivers/infiniband/core/verbs.c
+++ b/drivers/infiniband/core/verbs.c
@@ -1144,6 +1144,36 @@ struct ib_mr *ib_get_dma_mr(struct ib_pd *pd, int mr_access_flags)
 }
 EXPORT_SYMBOL(ib_get_dma_mr);
 
+int rdma_device_access_flags(struct ib_pd *pd, int roles, int attrs)
+{
+	int access_flags = attrs;
+
+	if (roles & RDMA_MRR_RECV)
+		access_flags |= IB_ACCESS_LOCAL_WRITE;
+
+	if (roles & RDMA_MRR_WRITE_DEST)
+		access_flags |= IB_ACCESS_LOCAL_WRITE | IB_ACCESS_REMOTE_WRITE;
+
+	if (roles & RDMA_MRR_READ_DEST) {
+		access_flags |= IB_ACCESS_LOCAL_WRITE;
+		if (rdma_protocol_iwarp(pd->device,
+					rdma_start_port(pd->device)))
+			access_flags |= IB_ACCESS_REMOTE_WRITE;
+	}
+
+	if (roles & RDMA_MRR_READ_SOURCE)
+		access_flags |= IB_ACCESS_REMOTE_READ;
+
+	if (roles & RDMA_MRR_ATOMIC_DEST)
+		access_flags |= IB_ACCESS_LOCAL_WRITE | IB_ACCESS_REMOTE_ATOMIC;
+
+	if (roles & RDMA_MRR_MW_BIND)
+		access_flags |= IB_ACCESS_MW_BIND;
+
+	return access_flags;
+}
+EXPORT_SYMBOL(rdma_device_access_flags);
+
 struct ib_mr *ib_reg_phys_mr(struct ib_pd *pd,
 			     struct ib_phys_buf *phys_buf_array,
 			     int num_phys_buf,
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 986fddb..da1eadf 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -2494,6 +2494,112 @@ static inline int ib_req_ncomp_notif(struct ib_cq *cq, int wc_cnt)
 struct ib_mr *ib_get_dma_mr(struct ib_pd *pd, int mr_access_flags);
 
 /**
+ * rdma_mr_roles - possible roles an RDMA MR will be used for
+ *
+ * This allows a transport independent RDMA application to
+ * create MRs that are usable for all the desired roles w/o
+ * having to understand which access rights are needed.
+ */
+enum {
+
+	/* lkey used in a ib_recv_wr sge */
+	RDMA_MRR_RECV			= 1,
+
+	/* lkey used for IB_WR_SEND* ops in the ib_send_wr sge */
+	RDMA_MRR_SEND			= (1<<1),
+
+	/* rkey used for IB_WR_RDMA_READ* ops in ib_send_wr wr.rdma.rkey */
+	RDMA_MRR_READ_SOURCE		= (1<<2),
+
+	/* lkey used for IB_WR_RDMA_READ* ops in the ib_send_wr sge */
+	RDMA_MRR_READ_DEST		= (1<<3),
+
+	/* lkey used for IB_WR_RDMA_WRITE* ops in the ib_send_wr sge */
+	RDMA_MRR_WRITE_SOURCE		= (1<<4),
+
+	/* rkey used for IB_WR_RDMA_WRITE* ops in ib_send_wr wr.rdma.rkey */
+	RDMA_MRR_WRITE_DEST		= (1<<5),
+
+	/*
+	 * lkey used for IB_WR_ATOMIC/MASKED_ATOMIC* ops in the ib_send_wr sge
+	 */
+	RDMA_MRR_ATOMIC_SOURCE		= (1<<6),
+
+	/*
+	 * rkey used for IB_WR_ATOMIC/MASKED_ATOMIC* ops in ib_send_wr
+	 * wr.atomic.rkey
+	 */
+	RDMA_MRR_ATOMIC_DEST		= (1<<7),
+
+	/* MR used for a IB_WR_MW_BIND in ib_send_wr wr.bind_mw.bind_info.mr */
+	RDMA_MRR_MW_BIND		= (1<<8),
+};
+
+/**
+ * rdma_mr_attributes - attributes for rdma memory regions
+ */
+enum {
+	RDMA_MRA_ZERO_BASED		= IB_ZERO_BASED,
+	RDMA_MRA_ACCESS_ON_DEMAND	= IB_ACCESS_ON_DEMAND,
+};
+
+/**
+ * rdma_device_access_flags - Returns the device-specific MR access flags.
+ * @pd: The protection domain associated with the memory region.
+ * @roles: The intended roles of the MR
+ * @attrs: The desired attributes of the MR
+ *
+ * Use the intended roles from @roles along with @attrs and the device
+ * capabilities to generate the needed access rights.
+ *
+ * Return: the ib_access_flags value needed to allocate the MR.
+ */
+int rdma_device_access_flags(struct ib_pd *pd, int roles, int attrs);
+
+/**
+ * rdma_get_dma_mr - Returns a memory region for system memory that is
+ * usable for DMA.
+ * @pd: The protection domain associated with the memory region.
+ * @roles: The intended roles of the MR
+ * @attrs: The desired attributes of the MR
+ *
+ * Use the intended roles from @roles along with @attrs and the device
+ * capabilities to define the needed access rights, and call
+ * ib_get_dma_mr() to allocate the MR.
+ *
+ * Note that the ib_dma_*() functions defined below must be used
+ * to create/destroy addresses used with the Lkey or Rkey returned
+ * by ib_get_dma_mr().
+ *
+ * Return: struct ib_mr pointer upon success, or a pointer encoded errno upon
+ * failure.
+ */
+static inline struct ib_mr *rdma_get_dma_mr(struct ib_pd *pd, int roles,
+					    int attrs)
+{
+	return ib_get_dma_mr(pd, rdma_device_access_flags(pd, roles, attrs));
+}
+
+/**
+ * rdma_fast_reg_access_flags - Returns the access flags needed for a fast
+ * register operation.
+ * @pd: The protection domain associated with the memory region.
+ * @roles: The intended roles of the MR
+ * @attrs: The desired attributes of the MR
+ *
+ * Use the intended roles from @roles along with @attrs and the device
+ * capabilities to define the needed access rights for a fast registration
+ * work request.
+ *
+ * Return: the ib_access_flags value needed for fast registration.
+ */
+static inline int rdma_fast_reg_access_flags(struct ib_pd *pd, int roles,
+					     int attrs)
+{
+	return rdma_device_access_flags(pd, roles, attrs);
+}
+
+/**
  * ib_dma_mapping_error - check a DMA addr for error
  * @dev: The device for which the dma_addr was created
  * @dma_addr: The DMA address to check

