Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753310Ab0JUVOs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Oct 2010 17:14:48 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Use more sensible names for 'initialize_mountpoint'
Date: Thu, 21 Oct 2010 17:14:43 -0400
Message-Id: <1287695683-17431-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The initialize_mountpoint/uninitialise_mountpoint functions are really about
setting or clearing the layout driver to be used on this filesystem. Change
the names to the more descriptive 'set_layoutdriver/clear_layoutdriver'.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4filelayout.c |   14 +++++++-------
 fs/nfs/pnfs.c           |    4 ++--
 fs/nfs/pnfs.h           |    4 ++--
 3 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 9e82b51..2e92f0d 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -40,8 +40,8 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Dean Hildebrand <dhildebz@umich.edu>");
 MODULE_DESCRIPTION("The NFSv4 file layout driver");
 
-int
-filelayout_initialize_mountpoint(struct nfs_server *nfss)
+static int
+filelayout_set_layoutdriver(struct nfs_server *nfss)
 {
 	int status = pnfs_alloc_init_deviceid_cache(nfss->nfs_client,
 						nfs4_fl_free_deviceid_callback);
@@ -55,9 +55,9 @@ filelayout_initialize_mountpoint(struct nfs_server *nfss)
 	return 0;
 }
 
-/* Uninitialize a mountpoint by destroying its device list */
-int
-filelayout_uninitialize_mountpoint(struct nfs_server *nfss)
+/* Clear out the layout by destroying its device list */
+static int
+filelayout_clear_layoutdriver(struct nfs_server *nfss)
 {
 	dprintk("--> %s\n", __func__);
 
@@ -256,8 +256,8 @@ static struct pnfs_layoutdriver_type filelayout_type = {
 	.id = LAYOUT_NFSV4_1_FILES,
 	.name = "LAYOUT_NFSV4_1_FILES",
 	.owner = THIS_MODULE,
-	.initialize_mountpoint   = filelayout_initialize_mountpoint,
-	.uninitialize_mountpoint = filelayout_uninitialize_mountpoint,
+	.set_layoutdriver = filelayout_set_layoutdriver,
+	.clear_layoutdriver = filelayout_clear_layoutdriver,
 	.alloc_lseg              = filelayout_alloc_lseg,
 	.free_lseg               = filelayout_free_lseg,
 };
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d1ad7df..db77342 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -75,7 +75,7 @@ void
 unset_pnfs_layoutdriver(struct nfs_server *nfss)
 {
 	if (nfss->pnfs_curr_ld) {
-		nfss->pnfs_curr_ld->uninitialize_mountpoint(nfss);
+		nfss->pnfs_curr_ld->clear_layoutdriver(nfss);
 		module_put(nfss->pnfs_curr_ld->owner);
 	}
 	nfss->pnfs_curr_ld = NULL;
@@ -115,7 +115,7 @@ set_pnfs_layoutdriver(struct nfs_server *server, u32 id)
 		goto out_no_driver;
 	}
 	server->pnfs_curr_ld = ld_type;
-	if (ld_type->initialize_mountpoint(server)) {
+	if (ld_type->set_layoutdriver(server)) {
 		printk(KERN_ERR
 		       "%s: Error initializing mount point for layout driver %u.\n",
 		       __func__, id);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index cbba28c..e12367d 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -53,8 +53,8 @@ struct pnfs_layoutdriver_type {
 	const u32 id;
 	const char *name;
 	struct module *owner;
-	int (*initialize_mountpoint) (struct nfs_server *);
-	int (*uninitialize_mountpoint) (struct nfs_server *);
+	int (*set_layoutdriver) (struct nfs_server *);
+	int (*clear_layoutdriver) (struct nfs_server *);
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 };
-- 
1.7.2.3

