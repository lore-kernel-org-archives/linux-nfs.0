Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:51000 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753511AbbGXQTA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jul 2015 12:19:00 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH V6 8/9] isert: Use local_dma_lkey whenever possible.
To: dledford@redhat.com
Cc: infinipath@intel.com, sagig@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Date: Fri, 24 Jul 2015 11:18:59 -0500
Message-ID: <20150724161859.25617.17286.stgit@build2.ogc.int>
In-Reply-To: <20150724161331.25617.8475.stgit@build2.ogc.int>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No need to allocate a dma_mr if the device provides a local_dma_lkey.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/ulp/isert/ib_isert.c |   47 ++++++++++++++++++-------------
 drivers/infiniband/ulp/isert/ib_isert.h |    1 +
 2 files changed, 28 insertions(+), 20 deletions(-)

diff --git a/drivers/infiniband/ulp/isert/ib_isert.c b/drivers/infiniband/ulp/isert/ib_isert.c
index 8ae9208..47bb790 100644
--- a/drivers/infiniband/ulp/isert/ib_isert.c
+++ b/drivers/infiniband/ulp/isert/ib_isert.c
@@ -249,7 +249,7 @@ isert_alloc_rx_descriptors(struct isert_conn *isert_conn)
 		rx_sg = &rx_desc->rx_sg;
 		rx_sg->addr = rx_desc->dma_addr;
 		rx_sg->length = ISER_RX_PAYLOAD_SIZE;
-		rx_sg->lkey = device->mr->lkey;
+		rx_sg->lkey = device->local_dma_lkey;
 	}
 
 	isert_conn->rx_desc_head = 0;
@@ -375,8 +375,9 @@ isert_create_device_ib_res(struct isert_device *device)
 	if (ret)
 		return ret;
 
-	/* asign function handlers */
+	/* assign function handlers */
 	if (dev_attr->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS &&
+	    dev_attr->device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY &&
 	    dev_attr->device_cap_flags & IB_DEVICE_SIGNATURE_HANDOVER) {
 		device->use_fastreg = 1;
 		device->reg_rdma_mem = isert_reg_frmr_pi;
@@ -399,12 +400,17 @@ isert_create_device_ib_res(struct isert_device *device)
 		goto out_cq;
 	}
 
-	device->mr = ib_get_dma_mr(device->pd, IB_ACCESS_LOCAL_WRITE);
-	if (IS_ERR(device->mr)) {
-		ret = PTR_ERR(device->mr);
-		isert_err("failed to create dma mr, device %p, ret=%d\n",
-			  device, ret);
-		goto out_mr;
+	if (device->use_fastreg)
+		device->local_dma_lkey = device->ib_device->local_dma_lkey;
+	else {
+		device->mr = ib_get_dma_mr(device->pd, IB_ACCESS_LOCAL_WRITE);
+		if (IS_ERR(device->mr)) {
+			ret = PTR_ERR(device->mr);
+			isert_err("failed to create dma mr, device %p, ret=%d\n",
+				  device, ret);
+			goto out_mr;
+		}
+		device->local_dma_lkey = device->mr->lkey;
 	}
 
 	/* Check signature cap */
@@ -425,7 +431,8 @@ isert_free_device_ib_res(struct isert_device *device)
 {
 	isert_info("device %p\n", device);
 
-	ib_dereg_mr(device->mr);
+	if (!device->use_fastreg)
+		ib_dereg_mr(device->mr);
 	ib_dealloc_pd(device->pd);
 	isert_free_comps(device);
 }
@@ -1108,8 +1115,8 @@ isert_create_send_desc(struct isert_conn *isert_conn,
 	tx_desc->num_sge = 1;
 	tx_desc->isert_cmd = isert_cmd;
 
-	if (tx_desc->tx_sg[0].lkey != device->mr->lkey) {
-		tx_desc->tx_sg[0].lkey = device->mr->lkey;
+	if (tx_desc->tx_sg[0].lkey != device->local_dma_lkey) {
+		tx_desc->tx_sg[0].lkey = device->local_dma_lkey;
 		isert_dbg("tx_desc %p lkey mismatch, fixing\n", tx_desc);
 	}
 }
@@ -1132,7 +1139,7 @@ isert_init_tx_hdrs(struct isert_conn *isert_conn,
 	tx_desc->dma_addr = dma_addr;
 	tx_desc->tx_sg[0].addr	= tx_desc->dma_addr;
 	tx_desc->tx_sg[0].length = ISER_HEADERS_LEN;
-	tx_desc->tx_sg[0].lkey = device->mr->lkey;
+	tx_desc->tx_sg[0].lkey = device->local_dma_lkey;
 
 	isert_dbg("Setup tx_sg[0].addr: 0x%llx length: %u lkey: 0x%x\n",
 		  tx_desc->tx_sg[0].addr, tx_desc->tx_sg[0].length,
@@ -1165,7 +1172,7 @@ isert_rdma_post_recvl(struct isert_conn *isert_conn)
 	memset(&sge, 0, sizeof(struct ib_sge));
 	sge.addr = isert_conn->login_req_dma;
 	sge.length = ISER_RX_LOGIN_SIZE;
-	sge.lkey = isert_conn->device->mr->lkey;
+	sge.lkey = isert_conn->device->local_dma_lkey;
 
 	isert_dbg("Setup sge: addr: %llx length: %d 0x%08x\n",
 		sge.addr, sge.length, sge.lkey);
@@ -1215,7 +1222,7 @@ isert_put_login_tx(struct iscsi_conn *conn, struct iscsi_login *login,
 
 		tx_dsg->addr	= isert_conn->login_rsp_dma;
 		tx_dsg->length	= length;
-		tx_dsg->lkey	= isert_conn->device->mr->lkey;
+		tx_dsg->lkey	= isert_conn->device->local_dma_lkey;
 		tx_desc->num_sge = 2;
 	}
 	if (!login->login_failed) {
@@ -1734,6 +1741,7 @@ isert_unmap_lkey(struct isert_cmd *isert_cmd, struct isert_conn *isert_conn)
 
 	if (wr->send_wr) {
 		isert_dbg("Cmd %p free send_wr\n", isert_cmd);
+		wr->send_wr_num = 0;
 		kfree(wr->send_wr);
 		wr->send_wr = NULL;
 	}
@@ -1967,7 +1975,6 @@ isert_completion_rdma_read(struct iser_tx_desc *tx_desc,
 	iscsit_stop_dataout_timer(cmd);
 	device->unreg_rdma_mem(isert_cmd, isert_conn);
 	cmd->write_data_done = wr->data.len;
-	wr->send_wr_num = 0;
 
 	isert_dbg("Cmd: %p RDMA_READ comp calling execute_cmd\n", isert_cmd);
 	spin_lock_bh(&cmd->istate_lock);
@@ -2232,7 +2239,7 @@ isert_put_response(struct iscsi_conn *conn, struct iscsi_cmd *cmd)
 		isert_cmd->pdu_buf_len = pdu_len;
 		tx_dsg->addr	= isert_cmd->pdu_buf_dma;
 		tx_dsg->length	= pdu_len;
-		tx_dsg->lkey	= device->mr->lkey;
+		tx_dsg->lkey	= device->local_dma_lkey;
 		isert_cmd->tx_desc.num_sge = 2;
 	}
 
@@ -2360,7 +2367,7 @@ isert_put_reject(struct iscsi_cmd *cmd, struct iscsi_conn *conn)
 	isert_cmd->pdu_buf_len = ISCSI_HDR_LEN;
 	tx_dsg->addr	= isert_cmd->pdu_buf_dma;
 	tx_dsg->length	= ISCSI_HDR_LEN;
-	tx_dsg->lkey	= device->mr->lkey;
+	tx_dsg->lkey	= device->local_dma_lkey;
 	isert_cmd->tx_desc.num_sge = 2;
 
 	isert_init_send_wr(isert_conn, isert_cmd, send_wr);
@@ -2401,7 +2408,7 @@ isert_put_text_rsp(struct iscsi_cmd *cmd, struct iscsi_conn *conn)
 		isert_cmd->pdu_buf_len = txt_rsp_len;
 		tx_dsg->addr	= isert_cmd->pdu_buf_dma;
 		tx_dsg->length	= txt_rsp_len;
-		tx_dsg->lkey	= device->mr->lkey;
+		tx_dsg->lkey	= device->local_dma_lkey;
 		isert_cmd->tx_desc.num_sge = 2;
 	}
 	isert_init_send_wr(isert_conn, isert_cmd, send_wr);
@@ -2442,7 +2449,7 @@ isert_build_rdma_wr(struct isert_conn *isert_conn, struct isert_cmd *isert_cmd,
 		ib_sge->addr = ib_sg_dma_address(ib_dev, tmp_sg) + page_off;
 		ib_sge->length = min_t(u32, data_left,
 				ib_sg_dma_len(ib_dev, tmp_sg) - page_off);
-		ib_sge->lkey = device->mr->lkey;
+		ib_sge->lkey = device->local_dma_lkey;
 
 		isert_dbg("RDMA ib_sge: addr: 0x%llx  length: %u lkey: %x\n",
 			  ib_sge->addr, ib_sge->length, ib_sge->lkey);
@@ -2622,7 +2629,7 @@ isert_fast_reg_mr(struct isert_conn *isert_conn,
 	u32 page_off;
 
 	if (mem->dma_nents == 1) {
-		sge->lkey = device->mr->lkey;
+		sge->lkey = device->local_dma_lkey;
 		sge->addr = ib_sg_dma_address(ib_dev, &mem->sg[0]);
 		sge->length = ib_sg_dma_len(ib_dev, &mem->sg[0]);
 		isert_dbg("sge: addr: 0x%llx  length: %u lkey: %x\n",
diff --git a/drivers/infiniband/ulp/isert/ib_isert.h b/drivers/infiniband/ulp/isert/ib_isert.h
index 11cd662..25a0946 100644
--- a/drivers/infiniband/ulp/isert/ib_isert.h
+++ b/drivers/infiniband/ulp/isert/ib_isert.h
@@ -212,6 +212,7 @@ struct isert_device {
 	struct ib_device	*ib_device;
 	struct ib_pd		*pd;
 	struct ib_mr		*mr;
+	u32			local_dma_lkey;
 	struct isert_comp	*comps;
 	int                     comps_used;
 	struct list_head	dev_node;

