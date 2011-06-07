Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:52411 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755521Ab1FGR0C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 13:26:02 -0400
Date: Tue, 7 Jun 2011 13:26:00 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH 01/88] pnfs: add set-clear layoutdriver interface
Message-ID: <c7f000a5e65e900c73d26ef3de26ae67879c511c.1307464381.git.rees@umich.edu>
References: <cover.1307464381.git.rees@umich.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1307464381.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
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
index 963be42..3b182cc 100644
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
index ba01e59..b8548d8 100644
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
 
@@ -169,7 +172,7 @@ struct pnfs_layout_segment *
 pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   loff_t pos, u64 count, enum pnfs_iomode access_type,
 		   gfp_t gfp_flags);
-void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
+void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 enum pnfs_try_status pnfs_try_to_write_data(struct nfs_write_data *,
 					     const struct rpc_call_ops *, int);
@@ -396,7 +399,8 @@ pnfs_roc_drain(struct inode *ino, u32 *barrier)
 	return false;
 }
 
-static inline void set_pnfs_layoutdriver(struct nfs_server *s, u32 id)
+static inline void set_pnfs_layoutdriver(struct nfs_server *s,
+					 const struct nfs_fh *mntfh, u32 id);
 {
 }
 
-- 
1.7.4.1

