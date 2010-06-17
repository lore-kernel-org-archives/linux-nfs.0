From: andros@netapp.com
Subject: [PATCH 1/7] SQUASHME pnfs-submit: remove setup_layoutcommit
Date: Thu, 17 Jun 2010 15:34:50 -0400
Message-ID: <1276803296-9438-2-git-send-email-andros@netapp.com>
References: <1276803296-9438-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.212.112.111]:56786 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759984Ab0FQTfc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jun 2010 15:35:32 -0400
In-Reply-To: <1276803296-9438-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Not used by the file layout driver

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |    7 -------
 include/linux/nfs4_pnfs.h |    2 --
 2 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 750ef22..96e8b5b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1586,7 +1586,6 @@ pnfs_layoutcommit_setup(struct inode *inode,
 			struct pnfs_layoutcommit_data *data,
 			loff_t write_begin_pos, loff_t write_end_pos, int sync)
 {
-	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_server *nfss = NFS_SERVER(inode);
 	int result = 0;
 
@@ -1612,12 +1611,6 @@ pnfs_layoutcommit_setup(struct inode *inode,
 	data->args.bitmask = nfss->attr_bitmask;
 	data->res.server = nfss;
 
-	/* Call layout driver to set the arguments.
-	 */
-	if (nfss->pnfs_curr_ld->ld_io_ops->setup_layoutcommit)
-		result = nfss->pnfs_curr_ld->ld_io_ops->setup_layoutcommit(
-				&nfsi->layout, &data->args);
-
 	dprintk("%s End Status %d\n", __func__, result);
 	return result;
 }
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index a88cd69..b635573 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -154,8 +154,6 @@ struct layoutdriver_io_operations {
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_type *layoutid, struct nfs4_pnfs_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
-	int (*setup_layoutcommit) (struct pnfs_layout_type *layoutid,
-				    struct pnfs_layoutcommit_arg *args);
 	void (*encode_layoutcommit) (struct pnfs_layout_type *layoutid,
 				     struct xdr_stream *xdr,
 				     const struct pnfs_layoutcommit_arg *args);
-- 
1.6.6

