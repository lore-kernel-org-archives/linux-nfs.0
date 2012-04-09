Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57514 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757902Ab2DIUwt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 16:52:49 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 02/26] NFS4.1: make pnfs_ld_[read|write]_done consistent
Date: Mon,  9 Apr 2012 16:52:00 -0400
Message-Id: <1334004744-31842-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
References: <1334004744-31842-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The two functions had diverged quite a bit, with the write function
being a bit more robust than the read.

However, these still break badly in the desc->pg_bsize < PAGE_CACHE_SIZE case,
as then there is nothing hanging on the data->pages list, and the resend
ends up doing nothing.  This will be fixed in a patch later in the series.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |   64 +++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 38 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b5d4515..e4aee9d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1189,6 +1189,17 @@ static int pnfs_write_done_resend_to_mds(struct inode *inode, struct list_head *
 	return 0;
 }
 
+static void pnfs_ld_handle_write_error(struct nfs_write_data *data)
+{
+	dprintk("pnfs write error = %d\n", data->pnfs_error);
+	if (NFS_SERVER(data->inode)->pnfs_curr_ld->flags &
+	    PNFS_LAYOUTRET_ON_ERROR) {
+		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(data->inode)->flags);
+		pnfs_return_layout(data->inode);
+	}
+	data->task.tk_status = pnfs_write_done_resend_to_mds(data->inode, &data->pages);
+}
+
 /*
  * Called by non rpc-based layout drivers
  */
@@ -1197,19 +1208,8 @@ void pnfs_ld_write_done(struct nfs_write_data *data)
 	if (likely(!data->pnfs_error)) {
 		pnfs_set_layoutcommit(data);
 		data->mds_ops->rpc_call_done(&data->task, data);
-	} else {
-		dprintk("pnfs write error = %d\n", data->pnfs_error);
-		if (NFS_SERVER(data->inode)->pnfs_curr_ld->flags &
-						PNFS_LAYOUTRET_ON_ERROR) {
-			/* Don't lo_commit on error, Server will needs to
-			 * preform a file recovery.
-			 */
-			clear_bit(NFS_INO_LAYOUTCOMMIT,
-				  &NFS_I(data->inode)->flags);
-			pnfs_return_layout(data->inode);
-		}
-		data->task.tk_status = pnfs_write_done_resend_to_mds(data->inode, &data->pages);
-	}
+	} else
+		pnfs_ld_handle_write_error(data);
 	put_lseg(data->lseg);
 	data->mds_ops->rpc_release(data);
 }
@@ -1293,26 +1293,38 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_writepages);
 
-static void pnfs_ld_handle_read_error(struct nfs_read_data *data)
+static int pnfs_read_done_resend_to_mds(struct inode *inode, struct list_head *head)
 {
 	struct nfs_pageio_descriptor pgio;
+	LIST_HEAD(failed);
 
-	put_lseg(data->lseg);
-	data->lseg = NULL;
-	dprintk("pnfs write error = %d\n", data->pnfs_error);
-	if (NFS_SERVER(data->inode)->pnfs_curr_ld->flags &
-						PNFS_LAYOUTRET_ON_ERROR)
-		pnfs_return_layout(data->inode);
-
-	nfs_pageio_init_read_mds(&pgio, data->inode);
-
-	while (!list_empty(&data->pages)) {
-		struct nfs_page *req = nfs_list_entry(data->pages.next);
+	/* Resend all requests through the MDS */
+	nfs_pageio_init_read_mds(&pgio, inode);
+	while (!list_empty(head)) {
+		struct nfs_page *req = nfs_list_entry(head->next);
 
 		nfs_list_remove_request(req);
-		nfs_pageio_add_request(&pgio, req);
+		if (!nfs_pageio_add_request(&pgio, req))
+			nfs_list_add_request(req, &failed);
 	}
 	nfs_pageio_complete(&pgio);
+
+	if (!list_empty(&failed)) {
+		list_move(&failed, head);
+		return -EIO;
+	}
+	return 0;
+}
+
+static void pnfs_ld_handle_read_error(struct nfs_read_data *data)
+{
+	dprintk("pnfs read error = %d\n", data->pnfs_error);
+	if (NFS_SERVER(data->inode)->pnfs_curr_ld->flags &
+	    PNFS_LAYOUTRET_ON_ERROR) {
+		clear_bit(NFS_INO_LAYOUTCOMMIT, &NFS_I(data->inode)->flags);
+		pnfs_return_layout(data->inode);
+	}
+	data->task.tk_status = pnfs_read_done_resend_to_mds(data->inode, &data->pages);
 }
 
 /*
-- 
1.7.2.1

