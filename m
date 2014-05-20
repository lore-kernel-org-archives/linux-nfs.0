Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:16546 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750868AbaETSI1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2014 14:08:27 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <dros@primarydata.com>, <hch@infradead.org>
Subject: [RFC 03/12] nfs: Create a common pnfs_ld_handle_rw_error() function
Date: Tue, 20 May 2014 14:08:10 -0400
Message-ID: <1400609299-32558-4-git-send-email-Anna.Schumaker@Netapp.com>
In-Reply-To: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1400609299-32558-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I use a simple function pointer to handle the difference between the
read and write paths.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/pnfs.c | 38 +++++++++++++-------------------------
 1 file changed, 13 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4d57003..4eaf74a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1446,6 +1446,17 @@ pnfs_generic_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_pg_test);
 
+static void pnfs_ld_handle_rw_error(struct nfs_pgio_header *hdr,
+			int (*resend_to_mds)(struct nfs_pgio_header *))
+{
+	if (NFS_SERVER(hdr->inode)->pnfs_curr_ld->flags &
+	    PNFS_LAYOUTRET_ON_ERROR) {
+		pnfs_return_layout(hdr->inode);
+	}
+	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags))
+		hdr->task.tk_status = resend_to_mds(hdr);
+}
+
 void
 pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			   struct nfs_page *req, u64 wb_size)
@@ -1465,18 +1476,6 @@ int pnfs_write_done_resend_to_mds(struct nfs_pgio_header *hdr)
 }
 EXPORT_SYMBOL_GPL(pnfs_write_done_resend_to_mds);
 
-static void pnfs_ld_handle_write_error(struct nfs_pgio_header *hdr)
-{
-
-	dprintk("pnfs write error = %d\n", hdr->pnfs_error);
-	if (NFS_SERVER(hdr->inode)->pnfs_curr_ld->flags &
-	    PNFS_LAYOUTRET_ON_ERROR) {
-		pnfs_return_layout(hdr->inode);
-	}
-	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags))
-		hdr->task.tk_status = pnfs_write_done_resend_to_mds(hdr);
-}
-
 /*
  * Called by non rpc-based layout drivers
  */
@@ -1487,7 +1486,7 @@ void pnfs_ld_write_done(struct nfs_pgio_header *hdr)
 		pnfs_set_layoutcommit(hdr);
 		hdr->mds_ops->rpc_call_done(&hdr->task, hdr);
 	} else
-		pnfs_ld_handle_write_error(hdr);
+		pnfs_ld_handle_rw_error(hdr, pnfs_write_done_resend_to_mds);
 	hdr->mds_ops->rpc_release(hdr);
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_write_done);
@@ -1596,17 +1595,6 @@ int pnfs_read_done_resend_to_mds(struct nfs_pgio_header *hdr)
 }
 EXPORT_SYMBOL_GPL(pnfs_read_done_resend_to_mds);
 
-static void pnfs_ld_handle_read_error(struct nfs_pgio_header *hdr)
-{
-	dprintk("pnfs read error = %d\n", hdr->pnfs_error);
-	if (NFS_SERVER(hdr->inode)->pnfs_curr_ld->flags &
-	    PNFS_LAYOUTRET_ON_ERROR) {
-		pnfs_return_layout(hdr->inode);
-	}
-	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags))
-		hdr->task.tk_status = pnfs_read_done_resend_to_mds(hdr);
-}
-
 /*
  * Called by non rpc-based layout drivers
  */
@@ -1617,7 +1605,7 @@ void pnfs_ld_read_done(struct nfs_pgio_header *hdr)
 		__nfs4_read_done_cb(hdr);
 		hdr->mds_ops->rpc_call_done(&hdr->task, hdr);
 	} else
-		pnfs_ld_handle_read_error(hdr);
+		pnfs_ld_handle_rw_error(hdr, pnfs_read_done_resend_to_mds);
 	hdr->mds_ops->rpc_release(hdr);
 }
 EXPORT_SYMBOL_GPL(pnfs_ld_read_done);
-- 
1.9.2

