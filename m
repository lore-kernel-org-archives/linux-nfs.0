From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 21/35] pnfsd: destroy layout on expire_client
Date: Mon,  7 Dec 2009 11:34:27 +0200
Message-ID: <1260178467-15545-1-git-send-email-bhalevy@panasas.com>
References: <4B1CCA52.8020900@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Andy Adamson <andros@netapp.com>,
	Boaz Harrosh <bharrosh@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4B1CCA52.8020900@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[extracted from pnfsd: Initial pNFS server implementation.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[Moved pnfsd code from nfs4state.c to nfs4pnfsd.c]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: use a spinlock for layout state]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfsd: expire_client code cleanup]
[pnfsd: expire_client code cleanup]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[Moved pnfsd code from nfs4state.c to nfs4pnfsd.c]
[removed nfs4_layout_lock and nfs4_layout_unlock]
Signed-off-by: Andy Adamson <andros@netapp.com>
[pnfsd: Move pnfsd code out of nfs4state.c/h]
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[moved defs back into state.h]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4pnfsd.c |   53 +++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4state.c |    3 ++
 fs/nfsd/state.h     |    2 +
 3 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index 9543e96..f475b3c 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -128,6 +128,14 @@ put_layout_state(struct nfs4_layout_state *ls)
 	kref_put(&ls->ls_ref, destroy_layout_state);
 }
 
+static inline void
+put_layout_state_locked(struct nfs4_layout_state *ls)
+{
+	dprintk("pNFS %s: ls %p ls_ref %d\n", __func__, ls,
+		atomic_read(&ls->ls_ref.refcount));
+	kref_put(&ls->ls_ref, destroy_layout_state_locked);
+}
+
 /*
  * Search the fp->fi_layout_state list for a layout state with the clientid.
  * If not found, then this is a 'first open/delegation/lock stateid' from
@@ -314,6 +322,35 @@ init_layout(struct nfs4_layout_state *ls,
 	dprintk("pNFS %s end\n", __func__);
 }
 
+static void
+dequeue_layout(struct nfs4_layout *lp)
+{
+	list_del(&lp->lo_perclnt);
+	list_del(&lp->lo_perfile);
+	list_del(&lp->lo_perstate);
+}
+
+static void
+destroy_layout(struct nfs4_layout *lp)
+{
+	struct nfs4_client *clp;
+	struct nfs4_file *fp;
+	struct nfs4_layout_state *ls;
+
+	dequeue_layout(lp);
+	clp = lp->lo_client;
+	fp = lp->lo_file;
+	ls = lp->lo_state;
+	dprintk("pNFS %s: lp %p clp %p fp %p ino %p ls_layouts empty %d\n",
+		__func__, lp, clp, fp, fp->fi_inode,
+		list_empty(&ls->ls_layouts));
+
+	kmem_cache_free(pnfs_layout_slab, lp);
+	/* release references taken by init_layout */
+	put_layout_state_locked(ls);
+	put_nfs4_file(fp);
+}
+
 /*
  * are two octet ranges overlapping?
  * start1            last1
@@ -517,3 +554,19 @@ out_freelayout:
 	free_layout(lp);
 	goto out;
 }
+
+void pnfs_expire_client(struct nfs4_client *clp)
+{
+	struct nfs4_layout *lp;
+
+	spin_lock(&layout_lock);
+	while (!list_empty(&clp->cl_layouts)) {
+		lp = list_entry(clp->cl_layouts.next, struct nfs4_layout,
+				lo_perclnt);
+		dprintk("NFSD: expire client. lp %p, fp %p\n", lp,
+			lp->lo_file);
+		BUG_ON(lp->lo_client != clp);
+		destroy_layout(lp);
+	}
+	spin_unlock(&layout_lock);
+}
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0cd563e..1833ddf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -742,6 +742,9 @@ expire_client(struct nfs4_client *clp)
 	list_del(&clp->cl_idhash);
 	list_del(&clp->cl_strhash);
 	list_del(&clp->cl_lru);
+
+	pnfs_expire_client(clp);
+
 	while (!list_empty(&clp->cl_openowners)) {
 		sop = list_entry(clp->cl_openowners.next, struct nfs4_stateowner, so_perclient);
 		release_openowner(sop);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index cde091a..9f68fd2 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -423,9 +423,11 @@ extern __be32 nfs4_check_stateid(stateid_t *);
 #if defined(CONFIG_PNFSD)
 extern int nfsd4_init_pnfs_slabs(void);
 extern void nfsd4_free_pnfs_slabs(void);
+extern void pnfs_expire_client(struct nfs4_client *);
 #else /* CONFIG_PNFSD */
 static inline void nfsd4_free_pnfs_slabs(void) {}
 static inline int nfsd4_init_pnfs_slabs(void) { return 0; }
+static inline void pnfs_expire_client(struct nfs4_client *clp) {}
 #endif /* CONFIG_PNFSD */
 
 static inline void
-- 
1.6.5.1

