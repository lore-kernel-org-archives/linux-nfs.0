Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38880 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752279Ab1EVQvx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 12:51:53 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 14/23] pnfs: alloc and free layout_hdr layoutdriver methods
Date: Sun, 22 May 2011 19:51:33 +0300
Message-Id: <1306083093-11007-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD93D3E.9010909@panasas.com>
References: <4DD93D3E.9010909@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   21 ++++++++++++++++++---
 fs/nfs/pnfs.h |    3 +++
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 3ac7b82..7f283b2 100644
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
@@ -752,7 +767,7 @@ alloc_init_layout_hdr(struct inode *ino)
 {
 	struct pnfs_layout_hdr *lo;
 
-	lo = kzalloc(sizeof(struct pnfs_layout_hdr), GFP_KERNEL);
+	lo = pnfs_alloc_layout_hdr(ino);
 	if (!lo)
 		return NULL;
 	atomic_set(&lo->plh_refcount, 1);
@@ -785,7 +800,7 @@ pnfs_find_alloc_layout(struct inode *ino)
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
1.7.2.3

