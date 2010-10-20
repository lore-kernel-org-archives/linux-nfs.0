Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19372 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751169Ab0JTESQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Oct 2010 00:18:16 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 09/12] NFS: create and destroy inode's layout cache
Date: Wed, 20 Oct 2010 00:18:01 -0400
Message-Id: <1287548284-28374-10-git-send-email-iisaman@netapp.com>
In-Reply-To: <1287548284-28374-1-git-send-email-iisaman@netapp.com>
References: <1287548284-28374-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Benny Halevy <bhalevy@panasas.com>

At the start of the io paths, try to grab the relevant layout
information.  This will initiate the inode's layout cache, but
stubs ensure the cache stays empty.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
Signed-off-by: Dean Hildebrand <dhildebz@umich.edu>
Signed-off-by: Marc Eshel <eshel@almaden.ibm.com>
Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/file.c          |    5 ++
 fs/nfs/inode.c         |    3 +
 fs/nfs/pnfs.c          |  140 ++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/pnfs.h          |   39 +++++++++++++
 fs/nfs/read.c          |    3 +
 include/linux/nfs_fs.h |    3 +
 6 files changed, 193 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 39672b7..6347777 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -36,6 +36,7 @@
 #include "internal.h"
 #include "iostat.h"
 #include "fscache.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_FILE
 
@@ -386,6 +387,10 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 		file->f_path.dentry->d_name.name,
 		mapping->host->i_ino, len, (long long) pos);
 
+	pnfs_update_layout(mapping->host,
+			   nfs_file_open_context(file),
+			   IOMODE_RW);
+
 start:
 	/*
 	 * Prevent starvation issues if someone is doing a consistency
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index f2d2c80..07919ea 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -48,6 +48,7 @@
 #include "internal.h"
 #include "fscache.h"
 #include "dns_resolve.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
@@ -1414,6 +1415,7 @@ void nfs4_evict_inode(struct inode *inode)
 {
 	truncate_inode_pages(&inode->i_data, 0);
 	end_writeback(inode);
+	pnfs_destroy_layout(NFS_I(inode));
 	/* If we are holding a delegation, return it! */
 	nfs_inode_return_delegation_noreclaim(inode);
 	/* First call standard NFS clear_inode() code */
@@ -1451,6 +1453,7 @@ static inline void nfs4_init_once(struct nfs_inode *nfsi)
 	nfsi->delegation = NULL;
 	nfsi->delegation_state = 0;
 	init_rwsem(&nfsi->rwsem);
+	nfsi->layout = NULL;
 #endif
 }
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index cf79562..c0cd954 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -166,3 +166,143 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
 	spin_unlock(&pnfs_spinlock);
 }
 EXPORT_SYMBOL_GPL(pnfs_unregister_layoutdriver);
+
+static void
+get_layout_hdr_locked(struct pnfs_layout_hdr *lo)
+{
+	assert_spin_locked(&lo->inode->i_lock);
+	lo->refcount++;
+}
+
+static void
+put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
+{
+	assert_spin_locked(&lo->inode->i_lock);
+	BUG_ON(lo->refcount == 0);
+
+	lo->refcount--;
+	if (!lo->refcount) {
+		dprintk("%s: freeing layout cache %p\n", __func__, lo);
+		NFS_I(lo->inode)->layout = NULL;
+		kfree(lo);
+	}
+}
+
+void
+pnfs_destroy_layout(struct nfs_inode *nfsi)
+{
+	struct pnfs_layout_hdr *lo;
+
+	spin_lock(&nfsi->vfs_inode.i_lock);
+	lo = nfsi->layout;
+	if (lo) {
+		/* Matched by refcount set to 1 in alloc_init_layout_hdr */
+		put_layout_hdr_locked(lo);
+	}
+	spin_unlock(&nfsi->vfs_inode.i_lock);
+}
+
+/* STUB - pretend LAYOUTGET to server failed */
+static struct pnfs_layout_segment *
+send_layoutget(struct pnfs_layout_hdr *lo,
+	   struct nfs_open_context *ctx,
+	   u32 iomode)
+{
+	struct inode *ino = lo->inode;
+
+	set_bit(lo_fail_bit(iomode), &lo->state);
+	spin_lock(&ino->i_lock);
+	put_layout_hdr_locked(lo);
+	spin_unlock(&ino->i_lock);
+	return NULL;
+}
+
+static struct pnfs_layout_hdr *
+alloc_init_layout_hdr(struct inode *ino)
+{
+	struct pnfs_layout_hdr *lo;
+
+	lo = kzalloc(sizeof(struct pnfs_layout_hdr), GFP_KERNEL);
+	if (!lo)
+		return NULL;
+	lo->refcount = 1;
+	lo->inode = ino;
+	return lo;
+}
+
+static struct pnfs_layout_hdr *
+pnfs_find_alloc_layout(struct inode *ino)
+{
+	struct nfs_inode *nfsi = NFS_I(ino);
+	struct pnfs_layout_hdr *new = NULL;
+
+	dprintk("%s Begin ino=%p layout=%p\n", __func__, ino, nfsi->layout);
+
+	assert_spin_locked(&ino->i_lock);
+	if (nfsi->layout)
+		return nfsi->layout;
+
+	spin_unlock(&ino->i_lock);
+	new = alloc_init_layout_hdr(ino);
+	spin_lock(&ino->i_lock);
+
+	if (likely(nfsi->layout == NULL))	/* Won the race? */
+		nfsi->layout = new;
+	else
+		kfree(new);
+	return nfsi->layout;
+}
+
+/* STUB - LAYOUTGET never succeeds, so cache is empty */
+static struct pnfs_layout_segment *
+pnfs_has_layout(struct pnfs_layout_hdr *lo, u32 iomode)
+{
+	return NULL;
+}
+
+/*
+ * Layout segment is retreived from the server if not cached.
+ * The appropriate layout segment is referenced and returned to the caller.
+ */
+struct pnfs_layout_segment *
+pnfs_update_layout(struct inode *ino,
+		   struct nfs_open_context *ctx,
+		   enum pnfs_iomode iomode)
+{
+	struct nfs_inode *nfsi = NFS_I(ino);
+	struct pnfs_layout_hdr *lo;
+	struct pnfs_layout_segment *lseg = NULL;
+
+	if (!pnfs_enabled_sb(NFS_SERVER(ino)))
+		return NULL;
+	spin_lock(&ino->i_lock);
+	lo = pnfs_find_alloc_layout(ino);
+	if (lo == NULL) {
+		dprintk("%s ERROR: can't get pnfs_layout_hdr\n", __func__);
+		goto out_unlock;
+	}
+
+	/* Check to see if the layout for the given range already exists */
+	lseg = pnfs_has_layout(lo, iomode);
+	if (lseg) {
+		dprintk("%s: Using cached lseg %p for iomode %d)\n",
+			__func__, lseg, iomode);
+		goto out_unlock;
+	}
+
+	/* if LAYOUTGET already failed once we don't try again */
+	if (test_bit(lo_fail_bit(iomode), &nfsi->layout->state))
+		goto out_unlock;
+
+	get_layout_hdr_locked(lo);
+	spin_unlock(&ino->i_lock);
+
+	lseg = send_layoutget(lo, ctx, iomode);
+out:
+	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
+		nfsi->layout->state, lseg);
+	return lseg;
+out_unlock:
+	spin_unlock(&ino->i_lock);
+	goto out;
+}
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 61531f3..4ed1b48 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -34,6 +34,11 @@
 
 #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
 
+enum {
+	NFS_LAYOUT_RO_FAILED = 0,	/* get ro layout failed stop trying */
+	NFS_LAYOUT_RW_FAILED,		/* get rw layout failed stop trying */
+};
+
 /* Per-layout driver specific registration structure */
 struct pnfs_layoutdriver_type {
 	struct list_head pnfs_tblid;
@@ -44,14 +49,48 @@ struct pnfs_layoutdriver_type {
 	int (*uninitialize_mountpoint) (struct nfs_server *);
 };
 
+struct pnfs_layout_hdr {
+	unsigned long		refcount;
+	unsigned long		state;
+	struct inode		*inode;
+};
+
 extern int pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *);
 extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
 
+struct pnfs_layout_segment *
+pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
+		   enum pnfs_iomode access_type);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
+void pnfs_destroy_layout(struct nfs_inode *);
+
+
+static inline int lo_fail_bit(u32 iomode)
+{
+	return iomode == IOMODE_RW ?
+			 NFS_LAYOUT_RW_FAILED : NFS_LAYOUT_RO_FAILED;
+}
+
+/* Return true if a layout driver is being used for this mountpoint */
+static inline int pnfs_enabled_sb(struct nfs_server *nfss)
+{
+	return nfss->pnfs_curr_ld != NULL;
+}
 
 #else  /* CONFIG_NFS_V4_1 */
 
+static inline void pnfs_destroy_layout(struct nfs_inode *nfsi)
+{
+}
+
+static inline struct pnfs_layout_segment *
+pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
+		   enum pnfs_iomode access_type)
+{
+	return NULL;
+}
+
 static inline void set_pnfs_layoutdriver(struct nfs_server *s, u32 id)
 {
 }
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 79859c8..e4b62c6 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -25,6 +25,7 @@
 #include "internal.h"
 #include "iostat.h"
 #include "fscache.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
@@ -120,6 +121,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
+	pnfs_update_layout(inode, ctx, IOMODE_READ);
 	new = nfs_create_request(ctx, inode, page, 0, len);
 	if (IS_ERR(new)) {
 		unlock_page(page);
@@ -624,6 +626,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		goto read_complete; /* all pages were read */
 
+	pnfs_update_layout(inode, desc.ctx, IOMODE_READ);
 	if (rsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(&pgio, inode, nfs_pagein_multi, rsize, 0);
 	else
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 499872f..0833bb6 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -188,6 +188,9 @@ struct nfs_inode {
 	struct nfs_delegation	*delegation;
 	fmode_t			 delegation_state;
 	struct rw_semaphore	rwsem;
+
+	/* pNFS layout information */
+	struct pnfs_layout_hdr *layout;
 #endif /* CONFIG_NFS_V4*/
 #ifdef CONFIG_NFS_FSCACHE
 	struct fscache_cookie	*fscache;
-- 
1.7.2.1

