Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:51009 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752391AbbGXQTG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jul 2015 12:19:06 -0400
From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH V6 9/9] isert: Support iWARP transports using FRMRs
To: dledford@redhat.com
Cc: infinipath@intel.com, sagig@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Date: Fri, 24 Jul 2015 11:19:05 -0500
Message-ID: <20150724161904.25617.85015.stgit@build2.ogc.int>
In-Reply-To: <20150724161331.25617.8475.stgit@build2.ogc.int>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add new register and unregister functions to be used with devices that
support FRMRs, provide a local dma lkey, yet do not support DIF/PI.

isert_reg_frmr() only needs to use FRMRs for RDMA READ since RDMA WRITE
can be handled entirely with the local dma lkey.  So for RDMA READ,
it calls isert_reg_read_frmr().  Otherwise is uses the lkey map service
isert_map_lkey() for RDMA WRITEs.

isert_reg_read_frmr() will create a linked list of WR triplets of the
form: INV->FRWR->READ.  The number of these triplets is dependent on
the devices fast reg page list length limit.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/ulp/isert/ib_isert.c |  224 ++++++++++++++++++++++++++++++-
 1 files changed, 218 insertions(+), 6 deletions(-)

diff --git a/drivers/infiniband/ulp/isert/ib_isert.c b/drivers/infiniband/ulp/isert/ib_isert.c
index 47bb790..34b3151 100644
--- a/drivers/infiniband/ulp/isert/ib_isert.c
+++ b/drivers/infiniband/ulp/isert/ib_isert.c
@@ -57,6 +57,11 @@ isert_unreg_frmr_pi(struct isert_cmd *isert_cmd, struct isert_conn *isert_conn);
 static int
 isert_reg_frmr_pi(struct iscsi_conn *conn, struct iscsi_cmd *cmd,
 		  struct isert_rdma_wr *wr);
+static void
+isert_unreg_frmr(struct isert_cmd *isert_cmd, struct isert_conn *isert_conn);
+static int
+isert_reg_frmr(struct iscsi_conn *conn, struct iscsi_cmd *cmd,
+	       struct isert_rdma_wr *wr);
 static int
 isert_put_response(struct iscsi_conn *conn, struct iscsi_cmd *cmd);
 static int
@@ -368,6 +373,7 @@ static int
 isert_create_device_ib_res(struct isert_device *device)
 {
 	struct ib_device_attr *dev_attr;
+	int cap_flags;
 	int ret;
 
 	dev_attr = &device->dev_attr;
@@ -376,12 +382,18 @@ isert_create_device_ib_res(struct isert_device *device)
 		return ret;
 
 	/* assign function handlers */
-	if (dev_attr->device_cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS &&
-	    dev_attr->device_cap_flags & IB_DEVICE_LOCAL_DMA_LKEY &&
-	    dev_attr->device_cap_flags & IB_DEVICE_SIGNATURE_HANDOVER) {
-		device->use_fastreg = 1;
-		device->reg_rdma_mem = isert_reg_frmr_pi;
-		device->unreg_rdma_mem = isert_unreg_frmr_pi;
+	cap_flags = dev_attr->device_cap_flags;
+	if (cap_flags & IB_DEVICE_MEM_MGT_EXTENSIONS &&
+	    cap_flags & IB_DEVICE_LOCAL_DMA_LKEY) {
+		if (cap_flags & IB_DEVICE_SIGNATURE_HANDOVER) {
+			device->use_fastreg = 1;
+			device->reg_rdma_mem = isert_reg_frmr_pi;
+			device->unreg_rdma_mem = isert_unreg_frmr_pi;
+		} else {
+			device->use_fastreg = 1;
+			device->reg_rdma_mem = isert_reg_frmr;
+			device->unreg_rdma_mem = isert_unreg_frmr;
+		}
 	} else {
 		device->use_fastreg = 0;
 		device->reg_rdma_mem = isert_map_lkey;
@@ -1782,6 +1794,50 @@ isert_unreg_frmr_pi(struct isert_cmd *isert_cmd, struct isert_conn *isert_conn)
 }
 
 static void
+isert_unreg_frmr(struct isert_cmd *isert_cmd, struct isert_conn *isert_conn)
+{
+	struct isert_rdma_wr *wr = &isert_cmd->rdma_wr;
+
+	if (wr->data.sg) {
+		isert_dbg("Cmd %p unmap_sg op\n", isert_cmd);
+		isert_unmap_data_buf(isert_conn, &wr->data);
+	}
+
+	if (wr->send_wr) {
+		int i;
+
+		isert_dbg("Cmd %p free send_wr wr_num %d\n", isert_cmd,
+			  wr->send_wr_num);
+		if (wr->iser_ib_op == ISER_IB_RDMA_READ) {
+			spin_lock_bh(&isert_conn->pool_lock);
+			for (i = 0; i < wr->send_wr_num; i += 3) {
+				struct ib_send_wr *fr_wr;
+				struct fast_reg_descriptor *fr_desc;
+
+				fr_wr = &wr->send_wr[i + 1];
+				fr_desc = (struct fast_reg_descriptor *)
+					  (uintptr_t) fr_wr->wr_id;
+				isert_dbg("Cmd %p free fr_desc %p\n", isert_cmd,
+					  fr_desc);
+				list_add_tail(&fr_desc->list,
+					      &isert_conn->fr_pool);
+			}
+			spin_unlock_bh(&isert_conn->pool_lock);
+		}
+		isert_dbg("Cmd %p free wr->send_wr\n", isert_cmd);
+		kfree(wr->send_wr);
+		wr->send_wr = NULL;
+		wr->send_wr_num = 0;
+	}
+
+	if (wr->ib_sge) {
+		isert_dbg("Cmd %p free ib_sge\n", isert_cmd);
+		kfree(wr->ib_sge);
+		wr->ib_sge = NULL;
+	}
+}
+
+static void
 isert_put_cmd(struct isert_cmd *isert_cmd, bool comp_err)
 {
 	struct iscsi_cmd *cmd = isert_cmd->iscsi_cmd;
@@ -2958,6 +3014,162 @@ unmap_cmd:
 	return ret;
 }
 
+static void
+isert_build_inv_fr_wrs(struct isert_conn *isert_conn,
+		       struct isert_cmd *isert_cmd, struct ib_sge *ib_sge,
+		       struct ib_send_wr *inv_wr, u32 data_len, u32 offset)
+{
+	struct iscsi_cmd *cmd = isert_cmd->iscsi_cmd;
+	struct scatterlist *sg_start;
+	struct isert_device *device = isert_conn->device;
+	struct ib_device *ib_dev = device->ib_device;
+	struct ib_fast_reg_page_list *frpl;
+	struct fast_reg_descriptor *fr_desc;
+	struct ib_send_wr *fr_wr;
+	u32 sg_off, page_off;
+	int sg_nents;
+	int frpl_len;
+	unsigned long flags;
+
+	sg_off = offset / PAGE_SIZE;
+	sg_start = &cmd->se_cmd.t_data_sg[sg_off];
+	sg_nents = min(cmd->se_cmd.t_data_nents - sg_off,
+		   isert_conn->max_frpl_len);
+	page_off = offset % PAGE_SIZE;
+
+	spin_lock_irqsave(&isert_conn->pool_lock, flags);
+	fr_desc = list_first_entry(&isert_conn->fr_pool,
+				   struct fast_reg_descriptor, list);
+	list_del(&fr_desc->list);
+	spin_unlock_irqrestore(&isert_conn->pool_lock, flags);
+	fr_desc->ind &= ~ISERT_DATA_KEY_VALID;
+
+	/* Build the INV WR */
+	isert_inv_rkey(inv_wr, fr_desc->data_mr);
+
+	/* Build the FR WR */
+	frpl = fr_desc->data_frpl;
+	frpl_len = isert_map_fr_pagelist(ib_dev, sg_start, sg_nents,
+					     &frpl->page_list[0]);
+	fr_wr = inv_wr + 1;
+	memset(fr_wr, 0, sizeof(fr_wr));
+	fr_wr->wr_id = (uintptr_t)fr_desc;
+	fr_wr->opcode = IB_WR_FAST_REG_MR;
+	fr_wr->wr.fast_reg.iova_start = frpl->page_list[0] + page_off;
+	fr_wr->wr.fast_reg.page_list = frpl;
+	fr_wr->wr.fast_reg.page_list_len = frpl_len;
+	fr_wr->wr.fast_reg.page_shift = PAGE_SHIFT;
+	fr_wr->wr.fast_reg.length = data_len;
+	fr_wr->wr.fast_reg.rkey = fr_desc->data_mr->rkey;
+	fr_wr->wr.fast_reg.access_flags = IB_ACCESS_REMOTE_WRITE |
+					  IB_ACCESS_LOCAL_WRITE;
+
+	ib_sge->addr = frpl->page_list[0] + page_off;
+	ib_sge->length = data_len;
+	ib_sge->lkey = fr_desc->data_mr->rkey;
+
+	/* Link up the wrs: inv->fr->read */
+	inv_wr->next = fr_wr;
+	fr_wr->next = fr_wr + 1;
+}
+
+static int
+isert_reg_read_frmr(struct iscsi_conn *conn, struct iscsi_cmd *cmd,
+		    struct isert_rdma_wr *wr)
+{
+	struct se_cmd *se_cmd = &cmd->se_cmd;
+	struct isert_cmd *isert_cmd = iscsit_priv_cmd(cmd);
+	struct isert_conn *isert_conn = conn->context;
+	struct isert_data_buf *data = &wr->data;
+	struct ib_send_wr *send_wr = NULL;
+	struct ib_sge *ib_sge;
+	u32 offset, data_len, data_left, rdma_max_len, va_offset = 0;
+	int ret = 0, i;
+	u32 num_frwrs;
+
+	isert_cmd->tx_desc.isert_cmd = isert_cmd;
+
+	offset = cmd->write_data_done;
+	ret = isert_map_data_buf(isert_conn, isert_cmd, se_cmd->t_data_sg,
+				 se_cmd->t_data_nents, se_cmd->data_length,
+				 offset, wr->iser_ib_op, &wr->data);
+	if (ret)
+		return ret;
+
+	data_left = data->len;
+	offset = data->offset;
+	num_frwrs = DIV_ROUND_UP(data->nents, isert_conn->max_frpl_len);
+
+	ib_sge = kcalloc(num_frwrs, sizeof(struct ib_sge), GFP_KERNEL);
+	if (!ib_sge) {
+		ret = -ENOMEM;
+		goto unmap_cmd;
+	}
+	wr->ib_sge = ib_sge;
+
+	/* always do INV + FR + READ for now */
+	wr->send_wr_num = 3 * num_frwrs;
+	wr->send_wr = kcalloc(wr->send_wr_num, sizeof(struct ib_send_wr),
+			      GFP_KERNEL);
+	if (!wr->send_wr) {
+		ret = -ENOMEM;
+		goto unmap_cmd;
+	}
+	isert_info("num_frwrs %d send_wr_num %d\n", num_frwrs, wr->send_wr_num);
+
+	wr->isert_cmd = isert_cmd;
+	rdma_max_len = isert_conn->max_frpl_len * PAGE_SIZE;
+
+	for (i = 0; i < wr->send_wr_num; i += 3) {
+
+		/*
+		 * i = INV, i+1 = FR, i+2 = READ
+		 */
+		send_wr = &isert_cmd->rdma_wr.send_wr[i+2];
+		data_len = min(data_left, rdma_max_len);
+		isert_build_inv_fr_wrs(isert_conn, isert_cmd, ib_sge,
+				       send_wr - 2, data_len, offset);
+		send_wr->opcode = IB_WR_RDMA_READ;
+		send_wr->wr.rdma.remote_addr = isert_cmd->write_va + va_offset;
+		send_wr->wr.rdma.rkey = isert_cmd->write_stag;
+		send_wr->sg_list = ib_sge;
+		send_wr->num_sge = 1;
+		if (i + 3 == wr->send_wr_num) {
+			send_wr->wr_id = (uintptr_t)&isert_cmd->tx_desc;
+			send_wr->send_flags = IB_SEND_SIGNALED;
+		} else {
+			send_wr->next = send_wr + 1;
+		}
+
+		ib_sge++;
+		offset += data_len;
+		va_offset += data_len;
+		data_left -= data_len;
+	}
+	isert_info("send_wr->send_flags 0x%x\n", send_wr->send_flags);
+
+	return 0;
+unmap_cmd:
+	isert_unmap_data_buf(isert_conn, data);
+
+	return ret;
+}
+
+static int
+isert_reg_frmr(struct iscsi_conn *conn, struct iscsi_cmd *cmd,
+	       struct isert_rdma_wr *wr)
+{
+
+	/*
+	 * Use the local dma lkey for Writes since it only requires local
+	 * access flags.  For reads, build up inv+fr+read
+	 * wr chains as needed.
+	 */
+	if (wr->iser_ib_op == ISER_IB_RDMA_WRITE)
+		return isert_map_lkey(conn, cmd, wr);
+	return isert_reg_read_frmr(conn, cmd, wr);
+}
+
 static int
 isert_put_datain(struct iscsi_conn *conn, struct iscsi_cmd *cmd)
 {

