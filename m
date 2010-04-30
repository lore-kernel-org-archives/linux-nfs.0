From: andros@netapp.com
Subject: [PATCH 5/5] pnfs_post_submit: restore get_blocksize policy operation
Date: Fri, 30 Apr 2010 14:27:12 -0400
Message-ID: <1272652032-2496-6-git-send-email-andros@netapp.com>
References: <1272652032-2496-1-git-send-email-andros@netapp.com>
 <1272652032-2496-2-git-send-email-andros@netapp.com>
 <1272652032-2496-3-git-send-email-andros@netapp.com>
 <1272652032-2496-4-git-send-email-andros@netapp.com>
 <1272652032-2496-5-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31670 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933895Ab0D3S1u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 14:27:50 -0400
In-Reply-To: <1272652032-2496-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The object layout driver is the only consumer of the get_blocksize policy
operation.
Note: struct pnfs_mount_type has been removed.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |   25 +++++++++++++++++++++++--
 include/linux/nfs4_pnfs.h |    8 ++++++++
 2 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index fadfd7c..c7918e1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1598,11 +1598,32 @@ pnfs_use_write(struct inode *inode, ssize_t count)
 	return 1; /* use pNFS I/O */
 }
 
+/* Return I/O buffer size for a layout driver
+ * This value will determine what size reads and writes
+ * will be gathered into and sent to the data servers.
+ * blocksize must be a multiple of the page cache size.
+ */
+unsigned int
+pnfs_getiosize(struct nfs_server *server)
+{
+	if (!PNFS_EXISTS_LDPOLICY_OP(server, get_blocksize))
+		return 0;
+	return server->pnfs_curr_ld->ld_policy_ops->get_blocksize();
+}
+
 void
 pnfs_set_ds_iosize(struct nfs_server *server)
 {
-	server->ds_wsize = server->wsize;
-	server->ds_rsize = server->rsize;
+	unsigned dssize = pnfs_getiosize(server);
+
+	/* Set buffer size for data servers */
+	if (dssize > 0) {
+		server->ds_rsize = server->ds_wsize =
+			nfs_block_size(dssize, NULL);
+	} else {
+		server->ds_wsize = server->wsize;
+		server->ds_rsize = server->rsize;
+	}
 }
 
 static int
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index b99843b..e3d5568 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -202,6 +202,14 @@ struct layoutdriver_policy_operations {
 	int (*do_flush)(struct pnfs_layout_segment *lseg, struct nfs_page *req,
 			struct pnfs_fsdata *fsdata);
 
+	/* Retreive the block size of the file system.
+	 * If gather_across_stripes == 1, then the file system will gather
+	 * requests into the block size.
+	 * TODO: Where will the layout driver get this info?  It is hard
+	 * coded in PVFS2.
+	 */
+	ssize_t (*get_blocksize) (void);
+
 	/* Read requests under this value are sent to the NFSv4 server */
 	ssize_t (*get_read_threshold) (struct pnfs_layout_type *, struct inode *);
 
-- 
1.6.6

