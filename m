Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:38371 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751346AbdH1TGQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Aug 2017 15:06:16 -0400
Subject: [PATCH 2/3] rdma core: Add rdma_rw_mr_payload()
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 28 Aug 2017 15:06:14 -0400
Message-ID: <20170828190614.13285.16215.stgit@klimt.1015granger.net>
In-Reply-To: <20170828190229.13285.76410.stgit@klimt.1015granger.net>
References: <20170828190229.13285.76410.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The amount of payload per MR depends on device capabilities and
the memory registration mode in use. The new rdma_rw API hides both,
making it difficult for ULPs to determine how large their transport
send queues need to be.

Expose the MR payload information via a new API.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Acked-by: Doug Ledford <dledford@redhat.com>
---
 drivers/infiniband/core/rw.c |   24 ++++++++++++++++++++++++
 include/rdma/rw.h            |    2 ++
 2 files changed, 26 insertions(+)

diff --git a/drivers/infiniband/core/rw.c b/drivers/infiniband/core/rw.c
index dbfd854..6ca607e 100644
--- a/drivers/infiniband/core/rw.c
+++ b/drivers/infiniband/core/rw.c
@@ -643,6 +643,30 @@ void rdma_rw_ctx_destroy_signature(struct rdma_rw_ctx *ctx, struct ib_qp *qp,
 }
 EXPORT_SYMBOL(rdma_rw_ctx_destroy_signature);
 
+/**
+ * rdma_rw_mr_factor - return number of MRs required for a payload
+ * @device:	device handling the connection
+ * @port_num:	port num to which the connection is bound
+ * @maxpages:	maximum payload pages per rdma_rw_ctx
+ *
+ * Returns the number of MRs the device requires to move @maxpayload
+ * bytes. The returned value is used during transport creation to
+ * compute max_rdma_ctxts and the size of the transport's Send and
+ * Send Completion Queues.
+ */
+unsigned int rdma_rw_mr_factor(struct ib_device *device, u8 port_num,
+			       unsigned int maxpages)
+{
+	unsigned int mr_pages;
+
+	if (rdma_rw_can_use_mr(device, port_num))
+		mr_pages = rdma_rw_fr_page_list_len(device);
+	else
+		mr_pages = device->attrs.max_sge_rd;
+	return DIV_ROUND_UP(maxpages, mr_pages);
+}
+EXPORT_SYMBOL(rdma_rw_mr_factor);
+
 void rdma_rw_init_qp(struct ib_device *dev, struct ib_qp_init_attr *attr)
 {
 	u32 factor;
diff --git a/include/rdma/rw.h b/include/rdma/rw.h
index 377d865..a3cbbc7 100644
--- a/include/rdma/rw.h
+++ b/include/rdma/rw.h
@@ -81,6 +81,8 @@ struct ib_send_wr *rdma_rw_ctx_wrs(struct rdma_rw_ctx *ctx, struct ib_qp *qp,
 int rdma_rw_ctx_post(struct rdma_rw_ctx *ctx, struct ib_qp *qp, u8 port_num,
 		struct ib_cqe *cqe, struct ib_send_wr *chain_wr);
 
+unsigned int rdma_rw_mr_factor(struct ib_device *device, u8 port_num,
+		unsigned int maxpages);
 void rdma_rw_init_qp(struct ib_device *dev, struct ib_qp_init_attr *attr);
 int rdma_rw_init_mrs(struct ib_qp *qp, struct ib_qp_init_attr *attr);
 void rdma_rw_cleanup_mrs(struct ib_qp *qp);

