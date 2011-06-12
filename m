Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:60560 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379Ab1FLXnw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 19:43:52 -0400
Message-Id: <82bae4d34ae6b51c5476108992482d7cdae974d8.1307921137.git.rees@umich.edu>
In-Reply-To: <cover.1307921137.git.rees@umich.edu>
References: <cover.1307921137.git.rees@umich.edu>
Date: Sun, 12 Jun 2011 19:43:50 -0400
Subject: [PATCH 02/34] pnfs: add set-clear layoutdriver interface
From: Jim Rees <rees@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: peter honeyman <honey@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

To allow layout driver to issue getdevicelist at mount time, and clean up
at umount time.

[fixup non NFS_V4_1 set_pnfs_layoutdriver definition]
[pnfs: pass mntfh down the init_pnfs path]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c |    7 ++++---
 fs/nfs/pnfs.c   |   15 +++++++++++++--
 fs/nfs/pnfs.h   |    8 ++++++--
 3 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index b3dc2b8..6bdb7da0 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -906,7 +906,8 @@ error:
 /*
  * Load up the server record from information gained in an fsinfo record
  */
-static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *fsinfo)
+static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh,
+				  struct nfs_fsinfo *fsinfo)
 {
 	unsigned long max_rpc_payload;
 
@@ -936,7 +937,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *
 	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
 		server->wsize = NFS_MAX_FILE_IO_SIZE;
 	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	set_pnfs_layoutdriver(server, fsinfo->layouttype);
+	set_pnfs_layoutdriver(server, mntfh, fsinfo->layouttype);
 
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
@@ -982,7 +983,7 @@ static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, str
 	if (error < 0)
 		goto out_error;
 
-	nfs_server_set_fsinfo(server, &fsinfo);
+	nfs_server_set_fsinfo(server, mntfh, &fsinfo);
 
 	/* Get some general file system info */
 	if (server->namelen == 0) {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 8c1309d..e3d618b 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -75,8 +75,11 @@ find_pnfs_driver(u32 id)
 void
 unset_pnfs_layoutdriver(struct nfs_server *nfss)
 {
-	if (nfss->pnfs_curr_ld)
+	if (nfss->pnfs_curr_ld) {
+		if (nfss->pnfs_curr_ld->clear_layoutdriver)
+			nfss->pnfs_curr_ld->clear_layoutdriver(nfss);
 		module_put(nfss->pnfs_curr_ld->owner);
+	}
 	nfss->pnfs_curr_ld = NULL;
 }
 
@@ -87,7 +90,8 @@ unset_pnfs_layoutdriver(struct nfs_server *nfss)
  * @id layout type. Zero (illegal layout type) indicates pNFS not in use.
  */
 void
-set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
+set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
+		      u32 id)
 {
 	struct pnfs_layoutdriver_type *ld_type = NULL;
 
@@ -114,6 +118,13 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 		goto out_no_driver;
 	}
 	server->pnfs_curr_ld = ld_type;
+        if (ld_type->set_layoutdriver && ld_type->set_layoutdriver(server, mntfh)) {
+                printk(KERN_ERR
+                       "%s: Error initializing mount point for layout driver %u.\n",
+                       __func__, id);
+                module_put(ld_type->owner);
+                goto out_no_driver;
+        }
 
 	dprintk("%s: pNFS module for %u set\n", __func__, id);
 	return;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 6113fc6..b071b56 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -80,6 +80,9 @@ struct pnfs_layoutdriver_type {
 	struct module *owner;
 	unsigned flags;
 
+	int (*set_layoutdriver) (struct nfs_server *, const struct nfs_fh *);
+	int (*clear_layoutdriver) (struct nfs_server *);
+
 	struct pnfs_layout_hdr * (*alloc_layout_hdr) (struct inode *inode, gfp_t gfp_flags);
 	void (*free_layout_hdr) (struct pnfs_layout_hdr *);
 
@@ -164,7 +167,7 @@ struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   loff_t pos, u64 count, enum pnfs_iomode access_type,
 		   gfp_t gfp_flags);
-void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
+void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
 					     const struct rpc_call_ops *, int);
@@ -388,7 +391,8 @@ pnfs_roc_drain(struct inode *ino, u32 *barrier)
 	return false;
 }
 
-static inline void set_pnfs_layoutdriver(struct nfs_server *s, u32 id)
+static inline void set_pnfs_layoutdriver(struct nfs_server *s,
+					 const struct nfs_fh *mntfh, u32 id);
 {
 }
 
-- 
1.7.4.1

