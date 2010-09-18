Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:54044 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755185Ab0IRDSg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Sep 2010 23:18:36 -0400
Received: from localhost.localdomain (scher1-lxp.hq.netapp.com [10.58.61.44] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o8I3IEVC012071
	for <linux-nfs@vger.kernel.org>; Fri, 17 Sep 2010 20:18:23 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 10/12] RFC: nfs: client needs to maintain list of inodes with active layouts
Date: Fri, 17 Sep 2010 23:17:52 -0400
Message-Id: <1284779874-10499-11-git-send-email-iisaman@netapp.com>
In-Reply-To: <1284779874-10499-1-git-send-email-iisaman@netapp.com>
References: <1284779874-10499-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: The pNFS Team <linux-nfs@vger.kernel.org>

In particular, server reboot will invalidate all layouts.

Note that in order to have an active layout, we must get a successful response
from the server.  To avoid adding that machinery, this patch just includes a
stub that fakes up a successful return.  Since the layout is never referenced
for io, this is not a problem.

Signed-off-by: TBD - melding/reorganization of several patches
---
 fs/nfs/client.c           |    4 +-
 fs/nfs/nfs4state.c        |    2 +
 fs/nfs/pnfs.c             |  131 +++++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/pnfs.h             |   14 +++++
 include/linux/nfs_fs_sb.h |    1 +
 5 files changed, 148 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index eed1212..6fc5c84 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -156,7 +156,9 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	cred = rpc_lookup_machine_cred();
 	if (!IS_ERR(cred))
 		clp->cl_machine_cred = cred;
-
+#if defined(CONFIG_NFS_V4_1)
+	INIT_LIST_HEAD(&clp->cl_layouts);
+#endif
 	nfs_fscache_get_client_cookie(clp);
 
 	return clp;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 3e2f19b..b53a4ce 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -53,6 +53,7 @@
 #include "callback.h"
 #include "delegation.h"
 #include "internal.h"
+#include "pnfs.h"
 
 #define OPENOWNER_POOL_SIZE	8
 
@@ -1447,6 +1448,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			}
 			clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state);
 			set_bit(NFS4CLNT_RECLAIM_REBOOT, &clp->cl_state);
+			pnfs_destroy_all_layouts(clp);
 		}
 
 		if (test_and_clear_bit(NFS4CLNT_CHECK_LEASE, &clp->cl_state)) {
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5d55d0b..a9750f2 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -28,6 +28,7 @@
  */
 
 #include <linux/nfs_fs.h>
+#include "internal.h"
 #include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PNFS
@@ -171,11 +172,67 @@ put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
 	lo->refcount--;
 	if (!lo->refcount) {
 		dprintk("%s: freeing layout cache %p\n", __func__, lo);
+		BUG_ON(!list_empty(&lo->layouts));
 		NFS_I(lo->inode)->layout = NULL;
 		kfree(lo);
 	}
 }
 
+static void
+init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
+{
+	INIT_LIST_HEAD(&lseg->fi_list);
+	kref_init(&lseg->kref);
+	lseg->layout = lo;
+}
+
+static void
+destroy_lseg(struct kref *kref)
+{
+	struct pnfs_layout_segment *lseg =
+		container_of(kref, struct pnfs_layout_segment, kref);
+	struct pnfs_layout_hdr *local = lseg->layout;
+
+	dprintk("--> %s\n", __func__);
+	kfree(lseg);
+	/* Matched by get_layout_hdr_locked in pnfs_insert_layout */
+	put_layout_hdr_locked(local);
+}
+
+static void
+put_lseg_locked(struct pnfs_layout_segment *lseg)
+{
+	if (!lseg)
+		return;
+
+	dprintk("%s: lseg %p ref %d\n", __func__, lseg,
+		atomic_read(&lseg->kref.refcount));
+	kref_put(&lseg->kref, destroy_lseg);
+}
+
+static void
+pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo)
+{
+	struct pnfs_layout_segment *lseg, *next;
+	struct nfs_client *clp;
+
+	dprintk("%s:Begin lo %p\n", __func__, lo);
+
+	assert_spin_locked(&lo->inode->i_lock);
+	list_for_each_entry_safe(lseg, next, &lo->segs, fi_list) {
+		dprintk("%s: freeing lseg %p\n", __func__, lseg);
+		list_del(&lseg->fi_list);
+		put_lseg_locked(lseg);
+	}
+	clp = NFS_SERVER(lo->inode)->nfs_client;
+	spin_lock(&clp->cl_lock);
+	/* List does not take a reference, so no need for put here */
+	list_del_init(&lo->layouts);
+	spin_unlock(&clp->cl_lock);
+
+	dprintk("%s:Return\n", __func__);
+}
+
 void
 pnfs_destroy_layout(struct nfs_inode *nfsi)
 {
@@ -184,25 +241,91 @@ pnfs_destroy_layout(struct nfs_inode *nfsi)
 	spin_lock(&nfsi->vfs_inode.i_lock);
 	lo = nfsi->layout;
 	if (lo) {
+		pnfs_clear_lseg_list(lo);
 		/* Matched by refcount set to 1 in alloc_init_layout_hdr */
 		put_layout_hdr_locked(lo);
 	}
 	spin_unlock(&nfsi->vfs_inode.i_lock);
 }
 
-/* STUB - pretend LAYOUTGET to server failed */
+/*
+ * Called by the state manger to remove all layouts established under an
+ * expired lease.
+ */
+void
+pnfs_destroy_all_layouts(struct nfs_client *clp)
+{
+	struct pnfs_layout_hdr *lo;
+	LIST_HEAD(tmp_list);
+
+	spin_lock(&clp->cl_lock);
+	list_splice_init(&clp->cl_layouts, &tmp_list);
+	spin_unlock(&clp->cl_lock);
+
+	while (!list_empty(&tmp_list)) {
+		lo = list_entry(tmp_list.next, struct pnfs_layout_hdr,
+				layouts);
+		dprintk("%s freeing layout for inode %lu\n", __func__,
+			lo->inode->i_ino);
+		pnfs_destroy_layout(NFS_I(lo->inode));
+	}
+}
+
+static void pnfs_insert_layout(struct pnfs_layout_hdr *lo,
+			       struct pnfs_layout_segment *lseg);
+
+/* Get layout from server. */
 static struct pnfs_layout_segment *
 send_layoutget(struct pnfs_layout_hdr *lo,
 	   struct nfs_open_context *ctx,
 	   u32 iomode)
 {
 	struct inode *ino = lo->inode;
+	struct pnfs_layout_segment *lseg;
 
-	set_bit(lo_fail_bit(iomode), &lo->state);
+	/* Lets pretend we sent LAYOUTGET and got a response */
+	lseg = kzalloc(sizeof(*lseg), GFP_KERNEL);
+	if (!lseg) {
+		set_bit(lo_fail_bit(iomode), &lo->state);
+		spin_lock(&ino->i_lock);
+		put_layout_hdr_locked(lo);
+		spin_unlock(&ino->i_lock);
+		return NULL;
+	}
+	init_lseg(lo, lseg);
+	lseg->iomode = IOMODE_RW;
 	spin_lock(&ino->i_lock);
+	pnfs_insert_layout(lo, lseg);
 	put_layout_hdr_locked(lo);
 	spin_unlock(&ino->i_lock);
-	return NULL;
+	return lseg;
+}
+
+static void
+pnfs_insert_layout(struct pnfs_layout_hdr *lo,
+		   struct pnfs_layout_segment *lseg)
+{
+	dprintk("%s:Begin\n", __func__);
+
+	assert_spin_locked(&lo->inode->i_lock);
+	if (list_empty(&lo->segs)) {
+		struct nfs_client *clp = NFS_SERVER(lo->inode)->nfs_client;
+
+		spin_lock(&clp->cl_lock);
+		BUG_ON(!list_empty(&lo->layouts));
+		list_add_tail(&lo->layouts, &clp->cl_layouts);
+		spin_unlock(&clp->cl_lock);
+	}
+	get_layout_hdr_locked(lo);
+	/* STUB - add the constructed lseg if necessary */
+	if (list_empty(&lo->segs)) {
+		list_add_tail(&lseg->fi_list, &lo->segs);
+		dprintk("%s: inserted lseg %p iomode %d at tail\n",
+			__func__, lseg, lseg->iomode);
+	} else
+		put_lseg_locked(lo);
+
+	dprintk("%s:Return\n", __func__);
 }
 
 static struct pnfs_layout_hdr *
@@ -214,6 +337,8 @@ alloc_init_layout_hdr(struct inode *ino)
 	if (!lo)
 		return NULL;
 	lo->refcount = 1;
+	INIT_LIST_HEAD(&lo->layouts);
+	INIT_LIST_HEAD(&lo->segs);
 	lo->inode = ino;
 	return lo;
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 4ed1b48..1c3eb02 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -30,6 +30,13 @@
 #ifndef FS_NFS_PNFS_H
 #define FS_NFS_PNFS_H
 
+struct pnfs_layout_segment {
+	struct list_head fi_list;
+	u32 iomode;
+	struct kref kref;
+	struct pnfs_layout_hdr *layout;
+};
+
 #ifdef CONFIG_NFS_V4_1
 
 #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
@@ -51,6 +58,8 @@ struct pnfs_layoutdriver_type {
 
 struct pnfs_layout_hdr {
 	unsigned long		refcount;
+	struct list_head	layouts;   /* other client layouts */
+	struct list_head	segs;      /* layout segments list */
 	unsigned long		state;
 	struct inode		*inode;
 };
@@ -64,6 +73,7 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
 void pnfs_destroy_layout(struct nfs_inode *);
+void pnfs_destroy_all_layouts(struct nfs_client *);
 
 
 static inline int lo_fail_bit(u32 iomode)
@@ -80,6 +90,10 @@ static inline int pnfs_enabled_sb(struct nfs_server *nfss)
 
 #else  /* CONFIG_NFS_V4_1 */
 
+static inline void pnfs_destroy_all_layouts(struct nfs_client *clp)
+{
+}
+
 static inline void pnfs_destroy_layout(struct nfs_inode *nfsi)
 {
 }
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 29a821d..e670a9c 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -82,6 +82,7 @@ struct nfs_client {
 	/* The flags used for obtaining the clientid during EXCHANGE_ID */
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session; 	/* sharred session */
+	struct list_head	cl_layouts;
 #endif /* CONFIG_NFS_V4_1 */
 
 #ifdef CONFIG_NFS_FSCACHE
-- 
1.7.2.1

