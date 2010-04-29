From: andros@netapp.com
Subject: [PATCH 04/13] SQUASHME pnfs_submit: remove get_blocksize policy operation
Date: Thu, 29 Apr 2010 16:34:42 -0400
Message-ID: <1272573291-8986-5-git-send-email-andros@netapp.com>
References: <1272573291-8986-1-git-send-email-andros@netapp.com>
 <1272573291-8986-2-git-send-email-andros@netapp.com>
 <1272573291-8986-3-git-send-email-andros@netapp.com>
 <1272573291-8986-4-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52310 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757563Ab0D3Qst (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 12:48:49 -0400
In-Reply-To: <1272573291-8986-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Not used by the file layout driver

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c             |   41 ++++-------------------------------------
 include/linux/nfs4_pnfs.h |    6 ------
 2 files changed, 4 insertions(+), 43 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f6181bd..de3f15a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1609,46 +1609,13 @@ pnfs_use_write(struct inode *inode, ssize_t count)
 	return 1; /* use pNFS I/O */
 }
 
-/* Return I/O buffer size for a layout driver
- * This value will determine what size reads and writes
- * will be gathered into and sent to the data servers.
- * blocksize must be a multiple of the page cache size.
- */
-unsigned int
-pnfs_getiosize(struct nfs_server *server)
-{
-	struct pnfs_mount_type *mounttype;
-	struct pnfs_layoutdriver_type *ld;
-
-	mounttype = server->pnfs_mountid;
-	ld = server->pnfs_curr_ld;
-	if (!pnfs_enabled_sb(server) ||
-	    !mounttype ||
-	    !ld->ld_policy_ops ||
-	    !ld->ld_policy_ops->get_blocksize)
-		return 0;
-
-	return ld->ld_policy_ops->get_blocksize(mounttype);
-}
-
 void
 pnfs_set_ds_iosize(struct nfs_server *server)
 {
-	unsigned dssize = pnfs_getiosize(server);
-
-	/* Set buffer size for data servers */
-	if (dssize > 0) {
-		server->ds_rsize = server->ds_wsize =
-			nfs_block_size(dssize, NULL);
-		server->ds_rpages = server->ds_wpages =
-			(server->ds_rsize + PAGE_CACHE_SIZE - 1) >>
-			PAGE_CACHE_SHIFT;
-	} else {
-		server->ds_wsize = server->wsize;
-		server->ds_rsize = server->rsize;
-		server->ds_rpages = server->rpages;
-		server->ds_wpages = server->wpages;
-	}
+	server->ds_wsize = server->wsize;
+	server->ds_rsize = server->rsize;
+	server->ds_rpages = server->rpages;
+	server->ds_wpages = server->wpages;
 }
 
 static int
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index be42370..f0eddbd 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -214,12 +214,6 @@ struct layoutdriver_policy_operations {
 	int (*do_flush)(struct pnfs_layout_segment *lseg, struct nfs_page *req,
 			struct pnfs_fsdata *fsdata);
 
-	/* Retreive the block size of the file system.  If gather_across_stripes == 1,
-	 * then the file system will gather requests into the block size.
-	 * TODO: Where will the layout driver get this info?  It is hard coded in PVFS2.
-	 */
-	ssize_t (*get_blocksize) (struct pnfs_mount_type *);
-
 	/* Read requests under this value are sent to the NFSv4 server */
 	ssize_t (*get_read_threshold) (struct pnfs_layout_type *, struct inode *);
 
-- 
1.6.6

