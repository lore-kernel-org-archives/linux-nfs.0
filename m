Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:50987 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754393AbbGXQSy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jul 2015 12:18:54 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH V6 7/9] isert: Use the device's max fastreg page list depth
To: dledford@redhat.com
Cc: infinipath@intel.com, sagig@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Date: Fri, 24 Jul 2015 11:18:54 -0500
Message-ID: <20150724161853.25617.11096.stgit@build2.ogc.int>
In-Reply-To: <20150724161331.25617.8475.stgit@build2.ogc.int>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the device's max_fast_reg_page_list_len attr to size the SQ
and FRMR pool.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/ulp/isert/ib_isert.c |   28 ++++++++++++++++++++++++----
 drivers/infiniband/ulp/isert/ib_isert.h |    1 +
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/ulp/isert/ib_isert.c b/drivers/infiniband/ulp/isert/ib_isert.c
index dcd3c55..8ae9208 100644
--- a/drivers/infiniband/ulp/isert/ib_isert.c
+++ b/drivers/infiniband/ulp/isert/ib_isert.c
@@ -141,6 +141,14 @@ isert_comp_put(struct isert_comp *comp)
 	mutex_unlock(&device_list_mutex);
 }
 
+static int isert_max_send_wrs(struct isert_conn *isert_conn)
+{
+	if (isert_conn->max_frpl_len >= ISCSI_ISER_SG_TABLESIZE)
+		return ISERT_QP_MAX_REQ_DTOS;
+	return ISERT_QP_MAX_REQ_DTOS *
+	       DIV_ROUND_UP(ISCSI_ISER_SG_TABLESIZE, isert_conn->max_frpl_len);
+}
+
 static struct ib_qp *
 isert_create_qp(struct isert_conn *isert_conn,
 		struct isert_comp *comp,
@@ -155,8 +163,6 @@ isert_create_qp(struct isert_conn *isert_conn,
 	attr.qp_context = isert_conn;
 	attr.send_cq = comp->cq;
 	attr.recv_cq = comp->cq;
-	attr.cap.max_send_wr = ISERT_QP_MAX_REQ_DTOS;
-	attr.cap.max_recv_wr = ISERT_QP_MAX_RECV_DTOS + 1;
 	/*
 	 * FIXME: Use devattr.max_sge - 2 for max_send_sge as
 	 * work-around for RDMA_READs with ConnectX-2.
@@ -168,7 +174,13 @@ isert_create_qp(struct isert_conn *isert_conn,
 	isert_conn->max_write_sge = attr.cap.max_send_sge;
 	isert_conn->max_read_sge = min_t(u32, device->dev_attr.max_sge_rd,
 					 attr.cap.max_send_sge);
+	isert_conn->max_frpl_len = device->dev_attr.max_fast_reg_page_list_len;
+	isert_info("max_write_sge %d max_read_sge %d max_frpl_len %d\n",
+		   isert_conn->max_write_sge, isert_conn->max_read_sge,
+		   isert_conn->max_frpl_len);
 
+	attr.cap.max_send_wr = isert_max_send_wrs(isert_conn);
+	attr.cap.max_recv_wr = ISERT_QP_MAX_RECV_DTOS + 1;
 	attr.cap.max_recv_sge = 1;
 	attr.sq_sig_type = IB_SIGNAL_REQ_WR;
 	attr.qp_type = IB_QPT_RC;
@@ -606,12 +618,20 @@ isert_conn_create_fastreg_pool(struct isert_conn *isert_conn)
 	struct se_session *se_sess = isert_conn->conn->sess->se_sess;
 	struct se_node_acl *se_nacl = se_sess->se_node_acl;
 	int i, ret, tag_num;
+
 	/*
 	 * Setup the number of FRMRs based upon the number of tags
-	 * available to session in iscsi_target_locate_portal().
+	 * available to session in iscsi_target_locate_portal(),
+	 * whether pi is supported, and how many FRMRs are needed to
+	 * map the largest possible IO given the rdma device limits.
 	 */
 	tag_num = max_t(u32, ISCSIT_MIN_TAGS, se_nacl->queue_depth);
-	tag_num = (tag_num * 2) + ISCSIT_EXTRA_TAGS;
+	if (isert_conn->pi_support)
+		tag_num *= 2;
+	if (isert_conn->max_frpl_len < ISCSI_ISER_SG_TABLESIZE)
+		tag_num *= DIV_ROUND_UP(ISCSI_ISER_SG_TABLESIZE,
+				       isert_conn->max_frpl_len);
+	tag_num += ISCSIT_EXTRA_TAGS;
 
 	isert_conn->fr_pool_size = 0;
 	for (i = 0; i < tag_num; i++) {
diff --git a/drivers/infiniband/ulp/isert/ib_isert.h b/drivers/infiniband/ulp/isert/ib_isert.h
index 29fde27..11cd662 100644
--- a/drivers/infiniband/ulp/isert/ib_isert.h
+++ b/drivers/infiniband/ulp/isert/ib_isert.h
@@ -154,6 +154,7 @@ struct isert_conn {
 	bool			pi_support;
 	u32			max_write_sge;
 	u32			max_read_sge;
+	u32			max_frpl_len;
 	char			*login_buf;
 	char			*login_req_buf;
 	char			*login_rsp_buf;

