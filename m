Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50879 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755368Ab1E2SXN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 14:23:13 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Cc: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 18/32] pnfs: alloc and free layout_hdr layoutdriver methods
Date: Sun, 29 May 2011 21:23:01 +0300
Message-Id: <1306693381-8210-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE28CFB.4060608@panasas.com>
References: <4DE28CFB.4060608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

[gfp_flags]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/pnfs.c |   21 ++++++++++++++++++---
 fs/nfs/pnfs.h |    4 ++++
 2 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 20436a5..ef535f2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -177,13 +177,28 @@ get_layout_hdr(struct pnfs_layout_hdr *lo)
 	atomic_inc(&lo->plh_refcount);
 }
 
+static struct pnfs_layout_hdr *
+pnfs_alloc_layout_hdr(struct inode *ino, gfp_t gfp_flags)
+{
+	struct pnfs_layoutdriver_type *ld = NFS_SERVER(ino)->pnfs_curr_ld;
+	return ld->alloc_layout_hdr ? ld->alloc_layout_hdr(ino, gfp_flags) :
+		kzalloc(sizeof(struct pnfs_layout_hdr), gfp_flags);
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
@@ -744,7 +759,7 @@ alloc_init_layout_hdr(struct inode *ino, gfp_t gfp_flags)
 {
 	struct pnfs_layout_hdr *lo;
 
-	lo = kzalloc(sizeof(struct pnfs_layout_hdr), gfp_flags);
+	lo = pnfs_alloc_layout_hdr(ino, gfp_flags);
 	if (!lo)
 		return NULL;
 	atomic_set(&lo->plh_refcount, 1);
@@ -777,7 +792,7 @@ pnfs_find_alloc_layout(struct inode *ino, gfp_t gfp_flags)
 	if (likely(nfsi->layout == NULL))	/* Won the race? */
 		nfsi->layout = new;
 	else
-		kfree(new);
+		pnfs_free_layout_hdr(new);
 	return nfsi->layout;
 }
 
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index f37ab35..925d6ef 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -73,6 +73,10 @@ struct pnfs_layoutdriver_type {
 	const u32 id;
 	const char *name;
 	struct module *owner;
+
+	struct pnfs_layout_hdr * (*alloc_layout_hdr) (struct inode *inode, gfp_t gfp_flags);
+	void (*free_layout_hdr) (struct pnfs_layout_hdr *);
+
 	struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr, gfp_t gfp_flags);
 	void (*free_lseg) (struct pnfs_layout_segment *lseg);
 
-- 
1.7.2.3

