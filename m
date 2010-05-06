From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 4/5] pnfs-post-submit: pass mntfh down the init_pnfs path
Date: Thu,  6 May 2010 22:23:37 +0300
Message-ID: <1273173817-27750-1-git-send-email-bhalevy@panasas.com>
References: <4BE3166F.7060800@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:5233 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754813Ab0EFTXl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 May 2010 15:23:41 -0400
In-Reply-To: <4BE3166F.7060800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To allow layout driver to issue getdevicelist at mount time.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/client.c           |   10 +++++-----
 fs/nfs/nfs4filelayout.c   |    5 +++--
 fs/nfs/pnfs.c             |    5 +++--
 fs/nfs/pnfs.h             |    2 +-
 include/linux/nfs4_pnfs.h |    3 ++-
 5 files changed, 14 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index b8c459d..7e1833d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -873,14 +873,14 @@ error:
 /*
  * Initialize the pNFS layout driver and setup pNFS related parameters
  */
-static void nfs4_init_pnfs(struct nfs_server *server, struct nfs_fsinfo *fsinfo)
+static void nfs4_init_pnfs(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs_fsinfo *fsinfo)
 {
 #if defined(CONFIG_NFS_V4_1)
 	struct nfs_client *clp = server->nfs_client;
 
 	if (nfs4_has_session(clp) &&
 	    (clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS)) {
-		set_pnfs_layoutdriver(server, fsinfo->layouttype);
+		set_pnfs_layoutdriver(server, mntfh, fsinfo->layouttype);
 		pnfs_set_ds_iosize(server);
 	}
 #endif /* CONFIG_NFS_V4_1 */
@@ -889,7 +889,7 @@ static void nfs4_init_pnfs(struct nfs_server *server, struct nfs_fsinfo *fsinfo)
 /*
  * Load up the server record from information gained in an fsinfo record
  */
-static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *fsinfo)
+static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, struct nfs_fsinfo *fsinfo)
 {
 	unsigned long max_rpc_payload;
 
@@ -919,7 +919,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *
 	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
 		server->wsize = NFS_MAX_FILE_IO_SIZE;
 	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	nfs4_init_pnfs(server, fsinfo);
+	nfs4_init_pnfs(server, mntfh, fsinfo);
 
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
@@ -963,7 +963,7 @@ static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, str
 	if (error < 0)
 		goto out_error;
 
-	nfs_server_set_fsinfo(server, &fsinfo);
+	nfs_server_set_fsinfo(server, mntfh, &fsinfo);
 
 	/* Get some general file system info */
 	if (server->namelen == 0) {
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 9d1274d..d649883 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -69,9 +69,10 @@ ssize_t filelayout_get_stripesize(struct pnfs_layout_type *);
 struct layoutdriver_io_operations filelayout_io_operations;
 
 int
-filelayout_initialize_mountpoint(struct nfs_client *clp)
+filelayout_initialize_mountpoint(struct nfs_server *nfss,
+				 const struct nfs_fh *mntfh)
 {
-	int status = nfs4_alloc_init_deviceid_cache(clp,
+	int status = nfs4_alloc_init_deviceid_cache(nfss->nfs_client,
 						nfs4_fl_free_deviceid_callback);
 	if (status) {
 		printk(KERN_WARNING "%s: deviceid cache could not be "
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6c0e8fa..059572f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -203,7 +203,8 @@ unmount_pnfs_layoutdriver(struct nfs_server *nfss)
  * Only one pNFS layout driver is supported.
  */
 void
-set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
+set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
+		      u32 id)
 {
 	struct pnfs_module *mod;
 
@@ -212,7 +213,7 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 
 	if (id > 0 && find_pnfs(id, &mod)) {
 		if (mod->pnfs_ld_type->ld_io_ops->initialize_mountpoint(
-			server->nfs_client)) {
+							server, mntfh)) {
 			printk(KERN_ERR "%s: Error initializing mount point "
 			       "for layout driver %u. ", __func__, id);
 			goto out_err;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 77623ea..8318112 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -41,7 +41,7 @@ int pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 int _pnfs_return_layout(struct inode *, struct nfs4_pnfs_layout_segment *,
 			const nfs4_stateid *stateid, /* optional */
 			enum pnfs_layoutreturn_type);
-void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
+void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *mntfh, u32 id);
 void unmount_pnfs_layoutdriver(struct nfs_server *);
 int pnfs_use_read(struct inode *inode, ssize_t count);
 int pnfs_use_ds_io(struct list_head *, struct inode *, int);
diff --git a/include/linux/nfs4_pnfs.h b/include/linux/nfs4_pnfs.h
index 87bb982..719302a 100644
--- a/include/linux/nfs4_pnfs.h
+++ b/include/linux/nfs4_pnfs.h
@@ -168,7 +168,8 @@ struct layoutdriver_io_operations {
 
 	/* Registration information for a new mounted file system
 	 */
-	int (*initialize_mountpoint) (struct nfs_client *);
+	int (*initialize_mountpoint) (struct nfs_server *,
+				      const struct nfs_fh * mntfh);
 	int (*uninitialize_mountpoint) (struct nfs_server *server);
 };
 
-- 
1.6.5.1

