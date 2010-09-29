Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:31495 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752536Ab0I2LK3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 07:10:29 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/9] pnfs: alloc and free layout_hdr layoutdriver methods
Date: Wed, 29 Sep 2010 13:10:26 +0200
Message-Id: <1285758626-26934-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4CA31DC3.8070300@panasas.com>
References: <4CA31DC3.8070300@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   21 ++++++++++++++++++---
 fs/nfs/pnfs.h |    4 ++++
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index b3e1e8a..8339444 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -233,6 +233,21 @@ EXPORT_SYMBOL_GPL(pnfs_unregister_layoutdriver);
  * pNFS client layout cache
  */
 
+static struct pnfs_layout_hdr *
+pnfs_alloc_layout_hdr(struct inode *ino)
+{
+	struct pnfs_layoutdriver_type *ld = NFS_SERVER(ino)->pnfs_curr_ld;
+	return ld->alloc_layout_hdr ? ld->alloc_layout_hdr(ino) :
+		kzalloc(sizeof(struct pnfs_layout_hdr), GFP_KERNEL);
+}
+
+static void
+pnfs_free_layout_hdr(struct pnfs_layout_hdr *lo)
+{
+	struct pnfs_layoutdriver_type *ld = NFS_SERVER(lo->inode)->pnfs_curr_ld;
+	return ld->alloc_layout_hdr ? ld->free_layout_hdr(lo) : kfree(lo);
+}
+
 static void
 get_layout_hdr_locked(struct pnfs_layout_hdr *lo)
 {
@@ -251,7 +266,7 @@ put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
 		dprintk("%s: freeing layout cache %p\n", __func__, lo);
 		BUG_ON(!list_empty(&lo->layouts));
 		NFS_I(lo->inode)->layout = NULL;
-		kfree(lo);
+		pnfs_free_layout_hdr(lo);
 	}
 }
 
@@ -839,7 +854,7 @@ alloc_init_layout_hdr(struct inode *ino)
 {
 	struct pnfs_layout_hdr *lo;
 
-	lo = kzalloc(sizeof(struct pnfs_layout_hdr), GFP_KERNEL);
+	lo = pnfs_alloc_layout_hdr(ino);
 	if (!lo)
 		return NULL;
 	lo->refcount = 1;
@@ -869,7 +884,7 @@ pnfs_find_alloc_layout(struct inode *ino)
 	if (likely(nfsi->layout == NULL))	/* Won the race? */
 		nfsi->layout = new;
 	else
-		kfree(new);
+		pnfs_free_layout_hdr(new);
 	return nfsi->layout;
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index af29b02..36ce9fa 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -76,6 +76,10 @@ struct pnfs_layoutdriver_type {
 	unsigned flags;
 	int (*initialize_mountpoint) (struct nfs_server *, const struct nfs_fh *);
 	int (*uninitialize_mountpoint) (struct nfs_server *);
+
+	struct pnfs_layout_hdr * (*alloc_layout_hdr) (struct inode *inode);
+	void (*free_layout_hdr) (struct pnfs_layout_hdr *);
+
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
-- 
1.7.2.3

