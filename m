Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38009 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602Ab1EIRJn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 13:09:43 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 17/29] pnfs: alloc and free layout_hdr layoutdriver methods
Date: Mon,  9 May 2011 20:09:34 +0300
Message-Id: <1304960974-4420-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DC81E8C.6040901@panasas.com>
References: <4DC81E8C.6040901@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   21 ++++++++++++++++++---
 fs/nfs/pnfs.h |    3 +++
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index d5efe2e..880a84d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -188,13 +188,28 @@ get_layout_hdr(struct pnfs_layout_hdr *lo)
 	atomic_inc(&lo->plh_refcount);
 }
 
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
+	struct pnfs_layoutdriver_type *ld = NFS_SERVER(lo->plh_inode)->pnfs_curr_ld;
+	return ld->alloc_layout_hdr ? ld->free_layout_hdr(lo) : kfree(lo);
+}
+
 static void
 destroy_layout_hdr(struct pnfs_layout_hdr *lo)
 {
 	dprintk("%s: freeing layout cache %p\n", __func__, lo);
 	BUG_ON(!list_empty(&lo->plh_layouts));
 	NFS_I(lo->plh_inode)->layout = NULL;
-	kfree(lo);
+	pnfs_free_layout_hdr(lo);
 }
 
 static void
@@ -756,7 +771,7 @@ alloc_init_layout_hdr(struct inode *ino)
 {
 	struct pnfs_layout_hdr *lo;
 
-	lo = kzalloc(sizeof(struct pnfs_layout_hdr), GFP_KERNEL);
+	lo = pnfs_alloc_layout_hdr(ino);
 	if (!lo)
 		return NULL;
 	atomic_set(&lo->plh_refcount, 1);
@@ -789,7 +804,7 @@ pnfs_find_alloc_layout(struct inode *ino)
 	if (likely(nfsi->layout == NULL))	/* Won the race? */
 		nfsi->layout = new;
 	else
-		kfree(new);
+		pnfs_free_layout_hdr(new);
 	return nfsi->layout;
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9d620de..e24c7fb 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -75,6 +75,9 @@ struct pnfs_layoutdriver_type {
 	int (*set_layoutdriver) (struct nfs_server *);
 	int (*unset_layoutdriver) (struct nfs_server *);
 
+	struct pnfs_layout_hdr * (*alloc_layout_hdr) (struct inode *inode);
+	void (*free_layout_hdr) (struct pnfs_layout_hdr *);
+
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
-- 
1.7.3.4

