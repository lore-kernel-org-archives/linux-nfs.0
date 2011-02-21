Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47186 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883Ab1BUWal (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 17:30:41 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 6/9] pnfs: return NFS4ERR_DELAY from layoutrecall while waiting on lsegs
Date: Mon, 21 Feb 2011 14:30:37 -0800
Message-Id: <1298327437-8675-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D62E6F3.8000304@panasas.com>
References: <4D62E6F3.8000304@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c |   23 +++++++++++++++--------
 1 files changed, 15 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 9547c34..5e4b5d1 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -186,6 +186,7 @@ void nfs_client_return_layouts(struct nfs_client *clp)
 {
 	struct pnfs_cb_lrecall_info *cb_info;
 
+	dprintk("%s\n", __func__);
 	spin_lock(&clp->cl_lock);
 	while (true) {
 		if (list_empty(&clp->cl_layoutrecalls)) {
@@ -270,10 +271,13 @@ static int initiate_layout_draining(struct pnfs_cb_lrecall_info *cb_info)
 		spin_lock(&lo->inode->i_lock);
 		if (rv == NFS4_OK) {
 			lo->plh_block_lgets++;
-			nfs4_asynch_forget_layouts(lo, &args->cbl_range,
-						   cb_info->pcl_notify_bit,
-						   &cb_info->pcl_count,
-						   &free_me_list);
+			if (nfs4_asynch_forget_layouts(lo, &args->cbl_range,
+						       cb_info->pcl_notify_bit,
+						       &cb_info->pcl_count,
+						       &free_me_list))
+				rv = NFS4ERR_DELAY;
+			else
+				rv = NFS4ERR_NOMATCHING_LAYOUT;
 		}
 		pnfs_set_layout_stateid(lo, &args->cbl_stateid, true);
 		spin_unlock(&lo->inode->i_lock);
@@ -309,10 +313,13 @@ static int initiate_layout_draining(struct pnfs_cb_lrecall_info *cb_info)
 					 &recall_list, plh_bulk_recall) {
 			spin_lock(&lo->inode->i_lock);
 			set_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
-			nfs4_asynch_forget_layouts(lo, &range,
-						   cb_info->pcl_notify_bit,
-						   &cb_info->pcl_count,
-						   &free_me_list);
+			if (nfs4_asynch_forget_layouts(lo, &range,
+						       cb_info->pcl_notify_bit,
+						       &cb_info->pcl_count,
+						       &free_me_list))
+				rv = NFS4ERR_DELAY;
+			else
+				rv = NFS4ERR_NOMATCHING_LAYOUT;
 			list_del_init(&lo->plh_bulk_recall);
 			spin_unlock(&lo->inode->i_lock);
 			put_layout_hdr(lo);
-- 
1.7.3.4

