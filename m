Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1032153Ab2COSlE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Mar 2012 14:41:04 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 1 09/11] NFSv4.1 wake up all tasks on un-connected DS slot table waitq
Date: Thu, 15 Mar 2012 14:40:48 -0400
Message-Id: <1331836850-5195-10-git-send-email-andros@netapp.com>
In-Reply-To: <1331836850-5195-1-git-send-email-andros@netapp.com>
References: <1331836850-5195-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The DS has a connection error (invalid deviceid). Drain the fore channel
slot table waitq.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 8531161..a67a137 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -193,6 +193,7 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 				struct nfs_read_data *data)
 {
 	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(data->lseg);
+	struct nfs4_slot_table *tbl = &data->ds_clp->cl_session->fc_slot_table;
 	unsigned long reset = 0;
 
 	dprintk("%s DS read\n", __func__);
@@ -205,8 +206,10 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 
 		if (test_bit(NFS4_RESET_TO_MDS, &reset)) {
 			filelayout_reset_read(task, data);
-			if (test_bit(NFS4_RESET_DEVICEID, &reset))
+			if (test_bit(NFS4_RESET_DEVICEID, &reset)) {
 				filelayout_mark_devid_invalid(devid);
+				rpc_drain_queue(&tbl->slot_tbl_waitq);
+			}
 		}
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
@@ -292,6 +295,7 @@ static int filelayout_write_done_cb(struct rpc_task *task,
 				struct nfs_write_data *data)
 {
 	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(data->lseg);
+	struct nfs4_slot_table *tbl = &data->ds_clp->cl_session->fc_slot_table;
 	unsigned long reset = 0;
 
 	if (filelayout_async_handle_error(task, data->args.context->state,
@@ -302,8 +306,10 @@ static int filelayout_write_done_cb(struct rpc_task *task,
 
 		if (test_bit(NFS4_RESET_TO_MDS, &reset)) {
 			filelayout_reset_write(task, data);
-			if (test_bit(NFS4_RESET_DEVICEID, &reset))
+			if (test_bit(NFS4_RESET_DEVICEID, &reset)) {
 				filelayout_mark_devid_invalid(devid);
+				rpc_drain_queue(&tbl->slot_tbl_waitq);
+			}
 		}
 		rpc_restart_call_prepare(task);
 		return -EAGAIN;
@@ -328,6 +334,7 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 				     struct nfs_write_data *data)
 {
 	struct nfs4_deviceid_node *devid = FILELAYOUT_DEVID_NODE(data->lseg);
+	struct nfs4_slot_table *tbl = &data->ds_clp->cl_session->fc_slot_table;
 	unsigned long reset = 0;
 
 	if (filelayout_async_handle_error(task, data->args.context->state,
@@ -338,8 +345,10 @@ static int filelayout_commit_done_cb(struct rpc_task *task,
 
 		if (test_bit(NFS4_RESET_TO_MDS, &reset)) {
 			prepare_to_resend_writes(data);
-			if (test_bit(NFS4_RESET_DEVICEID, &reset))
+			if (test_bit(NFS4_RESET_DEVICEID, &reset)) {
 				filelayout_mark_devid_invalid(devid);
+				rpc_drain_queue(&tbl->slot_tbl_waitq);
+			}
 		} else {
 			rpc_restart_call_prepare(task);
 		}
-- 
1.7.6.4

