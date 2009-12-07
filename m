From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 15/35] pnfsd: Helper functions for layout stateid processing.
Date: Mon,  7 Dec 2009 11:33:06 +0200
Message-ID: <1260178386-15188-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>,
	Boaz Harrosh <bharrosh@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:53043 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934852AbZLGJcK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2009 04:32:10 -0500
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Add a list of per clientid reference counted layout state structures (struct
nfs4_layout_state) to struct nfs4_file to track the layout stateid usage.

A struct nfs4_layout_state is created upon first LAYOUTGET operation from a
clientid on the file. Each successful LAYOUTGET from a clientid on the file
that adds a nfsd4_layout_seg bumps the struct nfs4_layout_state reference
count, and the nfsd4_layout_seg is added to the nfs4_layout_state
ls_state list.

LAYOUTRETURNS that remove nfsd4_layout_segs decrement the nfs4_layout_state
reference count.  A struct nfs4_layout_state is reaped when its reference
count goes to zero and the ls_state list is empty.

A delegation stateid is identified by a zero si_fileid field, an open/lock
stateid has non-zero si_stateownerid and si_fileid field, a layout stateid
is identified by a zero si_stateownerid field. The layout stateid
si_fileid field is used (reset) as a uniqifier.

NOTE: A design point of this architecture was to leave the nfs4_file fi_layouts
list alone so as not to disturb server implementations just prior to
Connectathon. We might want to get rid of the fi_layouts list and just
use the fi_layout_state list.

Use a spin_lock rather than the state_lock mutex for protecting
the layout and layoutrecall state.

[Moved pnfsd code from nfs4state.c to nfs4pnfsd.c]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: use a spinlock for layout state]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[removed nfs4_layout_lock and nfs4_layout_unlock]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: Move pnfsd code out of nfs4state.c/h]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[pnfsd: clean up layoutget export API]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4pnfsd.c |   99 ++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/nfs4state.c |    1 +
 fs/nfsd/pnfsd.h     |   12 ++++++
 fs/nfsd/state.h     |    1 +
 4 files changed, 109 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index b0794e3..b02daad 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -25,11 +25,19 @@
 
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
+/* Globals */
+static u32 current_layoutid = 1;
+
 /*
  * Layout state - NFSv4.1 pNFS
  */
 static struct kmem_cache *pnfs_layout_slab;
 
+/*
+ * Currently used for manipulating the layout state.
+ */
+static DEFINE_SPINLOCK(layout_lock);
+
 void
 nfsd4_free_pnfs_slabs(void)
 {
@@ -46,6 +54,80 @@ nfsd4_init_pnfs_slabs(void)
 	return 0;
 }
 
+static struct nfs4_layout_state *
+alloc_init_layout_state(struct nfs4_client *clp, struct nfs4_file *fp,
+			stateid_t *stateid)
+{
+	struct nfs4_layout_state *new;
+
+	/* FIXME: use a kmem_cache */
+	new = kzalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		return new;
+	get_nfs4_file(fp);
+	INIT_LIST_HEAD(&new->ls_perfile);
+	INIT_LIST_HEAD(&new->ls_layouts);
+	kref_init(&new->ls_ref);
+	new->ls_client = clp;
+	new->ls_file = fp;
+	new->ls_stateid.si_boot = stateid->si_boot;
+	new->ls_stateid.si_stateownerid = 0; /* identifies layout stateid */
+	new->ls_stateid.si_generation = 1;
+	spin_lock(&layout_lock);
+	new->ls_stateid.si_fileid = current_layoutid++;
+	list_add(&new->ls_perfile, &fp->fi_layout_states);
+	spin_unlock(&layout_lock);
+	return new;
+}
+
+static inline void
+get_layout_state(struct nfs4_layout_state *ls)
+{
+	kref_get(&ls->ls_ref);
+}
+
+static void
+destroy_layout_state_common(struct nfs4_layout_state *ls)
+{
+	struct nfs4_file *fp = ls->ls_file;
+
+	dprintk("pNFS %s: ls %p fp %p clp %p\n", __func__, ls, fp,
+		ls->ls_client);
+	BUG_ON(!list_empty(&ls->ls_layouts));
+	kfree(ls);
+	put_nfs4_file(fp);
+}
+
+static void
+destroy_layout_state(struct kref *kref)
+{
+	struct nfs4_layout_state *ls =
+			container_of(kref, struct nfs4_layout_state, ls_ref);
+
+	spin_lock(&layout_lock);
+	list_del(&ls->ls_perfile);
+	spin_unlock(&layout_lock);
+	destroy_layout_state_common(ls);
+}
+
+static void
+destroy_layout_state_locked(struct kref *kref)
+{
+	struct nfs4_layout_state *ls =
+			container_of(kref, struct nfs4_layout_state, ls_ref);
+
+	list_del(&ls->ls_perfile);
+	destroy_layout_state_common(ls);
+}
+
+static inline void
+put_layout_state(struct nfs4_layout_state *ls)
+{
+	dprintk("pNFS %s: ls %p ls_ref %d\n", __func__, ls,
+		atomic_read(&ls->ls_ref.refcount));
+	kref_put(&ls->ls_ref, destroy_layout_state);
+}
+
 static inline struct nfs4_layout *
 alloc_layout(void)
 {
@@ -59,21 +141,27 @@ free_layout(struct nfs4_layout *lp)
 }
 
 static void
-init_layout(struct nfs4_layout *lp,
+init_layout(struct nfs4_layout_state *ls,
+	    struct nfs4_layout *lp,
 	    struct nfs4_file *fp,
 	    struct nfs4_client *clp,
 	    struct svc_fh *current_fh,
 	    struct nfsd4_layout_seg *seg)
 {
-	dprintk("pNFS %s: lp %p clp %p fp %p ino %p\n", __func__,
-		lp, clp, fp, fp->fi_inode);
+	dprintk("pNFS %s: ls %p lp %p clp %p fp %p ino %p\n", __func__,
+		ls, lp, clp, fp, fp->fi_inode);
 
 	get_nfs4_file(fp);
 	lp->lo_client = clp;
 	lp->lo_file = fp;
+	get_layout_state(ls);
+	lp->lo_state = ls;
 	memcpy(&lp->lo_seg, seg, sizeof(lp->lo_seg));
+	spin_lock(&layout_lock);
+	list_add_tail(&lp->lo_perstate, &ls->ls_layouts);
 	list_add_tail(&lp->lo_perclnt, &clp->cl_layouts);
 	list_add_tail(&lp->lo_perfile, &fp->fi_layouts);
+	spin_unlock(&layout_lock);
 	dprintk("pNFS %s end\n", __func__);
 }
 
@@ -159,6 +247,7 @@ merge_layout(struct nfs4_file *fp,
 {
 	struct nfs4_layout *lp = NULL;
 
+	spin_lock(&layout_lock);
 	list_for_each_entry (lp, &fp->fi_layouts, lo_perfile)
 		if (lp->lo_seg.layout_type == seg->layout_type &&
 		    lp->lo_seg.clientid == seg->clientid &&
@@ -167,6 +256,7 @@ merge_layout(struct nfs4_file *fp,
 			extend_layout(&lp->lo_seg, seg);
 			break;
 		}
+	spin_unlock(&layout_lock);
 
 	return lp;
 }
@@ -182,6 +272,7 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
 	struct nfs4_file *fp;
 	struct nfs4_client *clp;
 	struct nfs4_layout *lp = NULL;
+	struct nfs4_layout_state *ls = NULL;
 	struct nfsd4_pnfs_layoutget_arg args = {
 		.lg_minlength = lgp->lg_minlength,
 		.lg_fsid = lgp->lg_fhp->fh_export->ex_fsid,
@@ -259,7 +350,7 @@ nfs4_pnfs_get_layout(struct nfsd4_pnfs_layoutget *lgp,
 		goto out_freelayout;
 
 	/* Can't merge, so let's initialize this new layout */
-	init_layout(lp, fp, clp, lgp->lg_fhp, &res.lg_seg);
+	init_layout(ls, lp, fp, clp, lgp->lg_fhp, &res.lg_seg);
 out:
 	if (fp)
 		put_nfs4_file(fp);
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cea0edc..9646240 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1725,6 +1725,7 @@ alloc_init_file(struct inode *ino, struct svc_fh *current_fh)
 		INIT_LIST_HEAD(&fp->fi_delegations);
 #if defined(CONFIG_PNFSD)
 		INIT_LIST_HEAD(&fp->fi_layouts);
+		INIT_LIST_HEAD(&fp->fi_layout_states);
 #endif /* CONFIG_PNFSD */
 		spin_lock(&recall_lock);
 		list_add(&fp->fi_hash, &file_hashtbl[hashval]);
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 04d713f..523b149 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -40,12 +40,24 @@
 #include <state.h>
 #include <xdr4.h>
 
+/* outstanding layout stateid */
+struct nfs4_layout_state {
+	struct list_head	ls_perfile;
+	struct list_head	ls_layouts; /* list of nfs4_layouts */
+	struct kref		ls_ref;
+	struct nfs4_client	*ls_client;
+	struct nfs4_file	*ls_file;
+	stateid_t		ls_stateid;
+};
+
 /* outstanding layout */
 struct nfs4_layout {
 	struct list_head		lo_perfile;	/* hash by f_id */
 	struct list_head		lo_perclnt;	/* hash by clientid */
+	struct list_head		lo_perstate;
 	struct nfs4_file		*lo_file;	/* backpointer */
 	struct nfs4_client		*lo_client;
+	struct nfs4_layout_state	*lo_state;
 	struct nfsd4_layout_seg 	lo_seg;
 };
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 44b25d2..23d62f4 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -328,6 +328,7 @@ struct nfs4_file {
 	struct list_head	fi_delegations;
 #if defined(CONFIG_PNFSD)
 	struct list_head	fi_layouts;
+	struct list_head	fi_layout_states;
 #endif /* CONFIG_PNFSD */
 	struct inode		*fi_inode;
 	u32                     fi_id;      /* used with stateowner->so_id 
-- 
1.6.5.1

