Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:34306 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754247Ab1G0Skr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jul 2011 14:40:47 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: [PATCH v3 02/25] pnfs: add set-clear layoutdriver interface
Date: Wed, 27 Jul 2011 14:40:25 -0400
Message-Id: <1311792048-12551-3-git-send-email-rees@umich.edu>
In-Reply-To: <1311792048-12551-1-git-send-email-rees@umich.edu>
References: <1311792048-12551-1-git-send-email-rees@umich.edu>
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
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/client.c |    8 +++++---
 fs/nfs/pnfs.c   |   16 ++++++++++++++--
 fs/nfs/pnfs.h   |    8 ++++++--
 3 files changed, 25 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 19ea7d9..a9b1848 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -904,7 +904,9 @@ error:
 /*
  * Load up the server record from information gained in an fsinfo record
  */
-static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *fsinfo)
+static void nfs_server_set_fsinfo(struct nfs_server *server,
+				  struct nfs_fh *mntfh,
+				  struct nfs_fsinfo *fsinfo)
 {
 	unsigned long max_rpc_payload;
 
@@ -934,7 +936,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *
 	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
 		server->wsize = NFS_MAX_FILE_IO_SIZE;
 	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
-	set_pnfs_layoutdriver(server, fsinfo->layouttype);
+	set_pnfs_layoutdriver(server, mntfh, fsinfo->layouttype);
 
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
@@ -980,7 +982,7 @@ static int nfs_probe_fsinfo(struct nfs_server *server, struct nfs_fh *mntfh, str
 	if (error < 0)
 		goto out_error;
 
-	nfs_server_set_fsinfo(server, &fsinfo);
+	nfs_server_set_fsinfo(server, mntfh, &fsinfo);
 
 	/* Get some general file system info */
 	if (server->namelen == 0) {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 38e5508..8e72724 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -76,8 +76,11 @@ find_pnfs_driver(u32 id)
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
 
@@ -88,7 +91,8 @@ unset_pnfs_layoutdriver(struct nfs_server *nfss)
  * @id layout type. Zero (illegal layout type) indicates pNFS not in use.
  */
 void
-set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
+set_pnfs_layoutdriver(struct nfs_server *server, const struct nfs_fh *mntfh,
+		      u32 id)
 {
 	struct pnfs_layoutdriver_type *ld_type = NULL;
 
@@ -115,6 +119,14 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 		goto out_no_driver;
 	}
 	server->pnfs_curr_ld = ld_type;
+	if (ld_type->set_layoutdriver
+	    && ld_type->set_layoutdriver(server, mntfh)) {
+		printk(KERN_ERR
+		       "%s: Error initializing mount point for layout driver %u.\n",
+		       __func__, id);
+		module_put(ld_type->owner);
+		goto out_no_driver;
+	}
 
 	dprintk("%s: pNFS module for %u set\n", __func__, id);
 	return;
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index ffea314..23d8267 100644
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
 
@@ -165,7 +168,7 @@ void put_lseg(struct pnfs_layout_segment *lseg);
 bool pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *);
 bool pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *, int);
 
-void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
+void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 void pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *, struct nfs_page *);
 int pnfs_generic_pg_readpages(struct nfs_pageio_descriptor *desc);
@@ -372,7 +375,8 @@ pnfs_roc_drain(struct inode *ino, u32 *barrier)
 	return false;
 }
 
-static inline void set_pnfs_layoutdriver(struct nfs_server *s, u32 id)
+static inline void set_pnfs_layoutdriver(struct nfs_server *s,
+					 const struct nfs_fh *mntfh, u32 id);
 {
 }
 
-- 
1.7.4.1

