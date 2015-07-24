Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:50970 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754367AbbGXQSn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jul 2015 12:18:43 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH V6 5/9] RDMA/isert: Limit read depth based on the device
	max_sge_rd capability
To: dledford@redhat.com
Cc: infinipath@intel.com, sagig@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Date: Fri, 24 Jul 2015 11:18:43 -0500
Message-ID: <20150724161842.25617.8145.stgit@build2.ogc.int>
In-Reply-To: <20150724161331.25617.8475.stgit@build2.ogc.int>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the device's max_sge_rd capability to compute the target's read sge
depth.  Save both the read and write max_sge values in the isert_conn
struct, and use these when creating RDMA_WRITE/READ work requests.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/ulp/isert/ib_isert.c |   24 ++++++++++++++++--------
 drivers/infiniband/ulp/isert/ib_isert.h |    3 ++-
 2 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/infiniband/ulp/isert/ib_isert.c b/drivers/infiniband/ulp/isert/ib_isert.c
index 7717009..6af3dd4 100644
--- a/drivers/infiniband/ulp/isert/ib_isert.c
+++ b/drivers/infiniband/ulp/isert/ib_isert.c
@@ -165,7 +165,9 @@ isert_create_qp(struct isert_conn *isert_conn,
 	 * outgoing control PDU responses.
 	 */
 	attr.cap.max_send_sge = max(2, device->dev_attr.max_sge - 2);
-	isert_conn->max_sge = attr.cap.max_send_sge;
+	isert_conn->max_write_sge = attr.cap.max_send_sge;
+	isert_conn->max_read_sge = min_t(u32, device->dev_attr.max_sge_rd,
+					 attr.cap.max_send_sge);
 
 	attr.cap.max_recv_sge = 1;
 	attr.sq_sig_type = IB_SIGNAL_REQ_WR;
@@ -2392,7 +2394,7 @@ isert_put_text_rsp(struct iscsi_cmd *cmd, struct iscsi_conn *conn)
 static int
 isert_build_rdma_wr(struct isert_conn *isert_conn, struct isert_cmd *isert_cmd,
 		    struct ib_sge *ib_sge, struct ib_send_wr *send_wr,
-		    u32 data_left, u32 offset)
+		    u32 data_left, u32 offset, u32 max_sge)
 {
 	struct iscsi_cmd *cmd = isert_cmd->iscsi_cmd;
 	struct scatterlist *sg_start, *tmp_sg;
@@ -2403,7 +2405,7 @@ isert_build_rdma_wr(struct isert_conn *isert_conn, struct isert_cmd *isert_cmd,
 
 	sg_off = offset / PAGE_SIZE;
 	sg_start = &cmd->se_cmd.t_data_sg[sg_off];
-	sg_nents = min(cmd->se_cmd.t_data_nents - sg_off, isert_conn->max_sge);
+	sg_nents = min(cmd->se_cmd.t_data_nents - sg_off, max_sge);
 	page_off = offset % PAGE_SIZE;
 
 	send_wr->sg_list = ib_sge;
@@ -2449,8 +2451,9 @@ isert_map_rdma(struct iscsi_conn *conn, struct iscsi_cmd *cmd,
 	struct isert_data_buf *data = &wr->data;
 	struct ib_send_wr *send_wr;
 	struct ib_sge *ib_sge;
-	u32 offset, data_len, data_left, rdma_write_max, va_offset = 0;
+	u32 offset, data_len, data_left, rdma_max_len, va_offset = 0;
 	int ret = 0, i, ib_sge_cnt;
+	u32 max_sge;
 
 	isert_cmd->tx_desc.isert_cmd = isert_cmd;
 
@@ -2472,7 +2475,12 @@ isert_map_rdma(struct iscsi_conn *conn, struct iscsi_cmd *cmd,
 	}
 	wr->ib_sge = ib_sge;
 
-	wr->send_wr_num = DIV_ROUND_UP(data->nents, isert_conn->max_sge);
+	if (wr->iser_ib_op == ISER_IB_RDMA_WRITE)
+		max_sge = isert_conn->max_write_sge;
+	else
+		max_sge =  isert_conn->max_read_sge;
+
+	wr->send_wr_num = DIV_ROUND_UP(data->nents, max_sge);
 	wr->send_wr = kzalloc(sizeof(struct ib_send_wr) * wr->send_wr_num,
 				GFP_KERNEL);
 	if (!wr->send_wr) {
@@ -2482,11 +2490,11 @@ isert_map_rdma(struct iscsi_conn *conn, struct iscsi_cmd *cmd,
 	}
 
 	wr->isert_cmd = isert_cmd;
-	rdma_write_max = isert_conn->max_sge * PAGE_SIZE;
+	rdma_max_len = max_sge * PAGE_SIZE;
 
 	for (i = 0; i < wr->send_wr_num; i++) {
 		send_wr = &isert_cmd->rdma_wr.send_wr[i];
-		data_len = min(data_left, rdma_write_max);
+		data_len = min(data_left, rdma_max_len);
 
 		send_wr->send_flags = 0;
 		if (wr->iser_ib_op == ISER_IB_RDMA_WRITE) {
@@ -2508,7 +2516,7 @@ isert_map_rdma(struct iscsi_conn *conn, struct iscsi_cmd *cmd,
 		}
 
 		ib_sge_cnt = isert_build_rdma_wr(isert_conn, isert_cmd, ib_sge,
-					send_wr, data_len, offset);
+					send_wr, data_len, offset, max_sge);
 		ib_sge += ib_sge_cnt;
 
 		offset += data_len;
diff --git a/drivers/infiniband/ulp/isert/ib_isert.h b/drivers/infiniband/ulp/isert/ib_isert.h
index 9ec23a7..29fde27 100644
--- a/drivers/infiniband/ulp/isert/ib_isert.h
+++ b/drivers/infiniband/ulp/isert/ib_isert.h
@@ -152,7 +152,8 @@ struct isert_conn {
 	u32			responder_resources;
 	u32			initiator_depth;
 	bool			pi_support;
-	u32			max_sge;
+	u32			max_write_sge;
+	u32			max_read_sge;
 	char			*login_buf;
 	char			*login_req_buf;
 	char			*login_rsp_buf;

