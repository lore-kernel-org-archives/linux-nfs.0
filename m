Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:59969 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSl2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:41:28 -0400
Received: by mail-qc0-f178.google.com with SMTP id r5so1043528qcx.9
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:41:27 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 23/49] pnfsd: layout state allocation
Date: Thu, 26 Sep 2013 14:41:25 -0400
Message-Id: <1380220885-13733-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4pnfsd.c | 55 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4state.c | 20 +++++++++----------
 fs/nfsd/pnfsd.h     | 11 +++++++++++
 fs/nfsd/state.h     |  4 ++++
 4 files changed, 80 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index b8ddd82..82b6a7d 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -39,6 +39,7 @@
  * Layout state - NFSv4.1 pNFS
  */
 static struct kmem_cache *pnfs_layout_slab;
+static struct kmem_cache *layout_state_slab;
 
 /* hash table for nfsd4_pnfs_deviceid.sbid */
 #define SBID_HASH_BITS	8
@@ -82,6 +83,7 @@ struct sbid_tracker {
 	struct sbid_tracker *sbid;
 
 	nfsd4_free_slab(&pnfs_layout_slab);
+	nfsd4_free_slab(&layout_state_slab);
 
 	for (i = 0; i < SBID_HASH_SIZE; i++) {
 		while (!list_empty(&sbid_hashtbl[i])) {
@@ -103,12 +105,65 @@ struct sbid_tracker {
 	if (pnfs_layout_slab == NULL)
 		return -ENOMEM;
 
+	layout_state_slab = kmem_cache_create("pnfs_layout_states",
+			sizeof(struct nfs4_layout_state), 0, 0, NULL);
+	if (layout_state_slab == NULL)
+		return -ENOMEM;
+
 	for (i = 0; i < SBID_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&sbid_hashtbl[i]);
 
 	return 0;
 }
 
+/*
+ * Note: must be called under the state lock
+ */
+static struct nfs4_layout_state *
+alloc_init_layout_state(struct nfs4_client *clp, stateid_t *stateid)
+{
+	struct nfs4_layout_state *new;
+
+	nfs4_assert_state_locked();
+	new = layoutstateid(nfsd4_alloc_stid(clp, layout_state_slab));
+	if (!new)
+		return new;
+	kref_init(&new->ls_ref);
+	new->ls_stid.sc_type = NFS4_LAYOUT_STID;
+	return new;
+}
+
+static void
+get_layout_state(struct nfs4_layout_state *ls)
+{
+	kref_get(&ls->ls_ref);
+}
+
+/*
+ * Note: must be called under the state lock
+ */
+static void
+destroy_layout_state(struct kref *kref)
+{
+	struct nfs4_layout_state *ls =
+			container_of(kref, struct nfs4_layout_state, ls_ref);
+
+	nfsd4_remove_stid(&ls->ls_stid);
+	nfsd4_free_stid(layout_state_slab, &ls->ls_stid);
+}
+
+/*
+ * Note: must be called under the state lock
+ */
+static void
+put_layout_state(struct nfs4_layout_state *ls)
+{
+	dprintk("pNFS %s: ls %p ls_ref %d\n", __func__, ls,
+		atomic_read(&ls->ls_ref.refcount));
+	nfs4_assert_state_locked();
+	kref_put(&ls->ls_ref, destroy_layout_state);
+}
+
 static struct nfs4_layout *
 alloc_layout(void)
 {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 099976e..6e251fb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -330,7 +330,7 @@ static void nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 		__nfs4_file_put_access(fp, oflag);
 }
 
-static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct
+struct nfs4_stid *nfsd4_alloc_stid(struct nfs4_client *cl, struct
 kmem_cache *slab)
 {
 	struct idr *stateids = &cl->cl_stateids;
@@ -369,7 +369,7 @@ static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct
 
 static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
 {
-	return openlockstateid(nfs4_alloc_stid(clp, stateid_slab));
+	return openlockstateid(nfsd4_alloc_stid(clp, stateid_slab));
 }
 
 static struct nfs4_delegation *
@@ -380,7 +380,7 @@ static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
 	dprintk("NFSD alloc_init_deleg\n");
 	if (num_delegations > max_delegations)
 		return NULL;
-	dp = delegstateid(nfs4_alloc_stid(clp, deleg_slab));
+	dp = delegstateid(nfsd4_alloc_stid(clp, deleg_slab));
 	if (dp == NULL)
 		return dp;
 	dp->dl_stid.sc_type = NFS4_DELEG_STID;
@@ -403,7 +403,7 @@ static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
 	return dp;
 }
 
-static void remove_stid(struct nfs4_stid *s)
+void nfsd4_remove_stid(struct nfs4_stid *s)
 {
 	struct idr *stateids = &s->sc_client->cl_stateids;
 
@@ -411,7 +411,7 @@ static void remove_stid(struct nfs4_stid *s)
 	idr_remove(stateids, s->sc_stateid.si_opaque.so_id);
 }
 
-static void free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
+void nfsd4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
 {
 	kmem_cache_free(slab, s);
 }
@@ -420,7 +420,7 @@ static void free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
 	if (atomic_dec_and_test(&dp->dl_count)) {
-		free_stid(deleg_slab, &dp->dl_stid);
+		nfsd4_free_stid(deleg_slab, &dp->dl_stid);
 		num_delegations--;
 	}
 }
@@ -459,14 +459,14 @@ static void unhash_stid(struct nfs4_stid *s)
 static void destroy_revoked_delegation(struct nfs4_delegation *dp)
 {
 	list_del_init(&dp->dl_recall_lru);
-	remove_stid(&dp->dl_stid);
+	nfsd4_remove_stid(&dp->dl_stid);
 	nfs4_put_delegation(dp);
 }
 
 static void destroy_delegation(struct nfs4_delegation *dp)
 {
 	unhash_delegation(dp);
-	remove_stid(&dp->dl_stid);
+	nfsd4_remove_stid(&dp->dl_stid);
 	nfs4_put_delegation(dp);
 }
 
@@ -623,8 +623,8 @@ static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 
 static void free_generic_stateid(struct nfs4_ol_stateid *stp)
 {
-	remove_stid(&stp->st_stid);
-	free_stid(stateid_slab, &stp->st_stid);
+	nfsd4_remove_stid(&stp->st_stid);
+	nfsd4_free_stid(stateid_slab, &stp->st_stid);
 }
 
 static void release_lock_stateid(struct nfs4_ol_stateid *stp)
diff --git a/fs/nfsd/pnfsd.h b/fs/nfsd/pnfsd.h
index 6920e43..c2360e4 100644
--- a/fs/nfsd/pnfsd.h
+++ b/fs/nfsd/pnfsd.h
@@ -40,6 +40,12 @@
 #include "state.h"
 #include "xdr4.h"
 
+/* outstanding layout stateid */
+struct nfs4_layout_state {
+	struct nfs4_stid	ls_stid; /* must be first field */
+	struct kref		ls_ref;
+};
+
 /* outstanding layout */
 struct nfs4_layout {
 	struct nfsd4_layout_seg		lo_seg;
@@ -49,4 +55,9 @@ struct nfs4_layout {
 struct super_block *find_sbid_id(u64);
 __be32 nfs4_pnfs_get_layout(struct svc_rqst *, struct nfsd4_pnfs_layoutget *, struct exp_xdr_stream *);
 
+static inline struct nfs4_layout_state *layoutstateid(struct nfs4_stid *s)
+{
+	return container_of(s, struct nfs4_layout_state, ls_stid);
+}
+
 #endif /* LINUX_NFSD_PNFSD_H */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index b85ad60..18a64c4 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -81,6 +81,7 @@ struct nfs4_stid {
 #define NFS4_CLOSED_STID 8
 /* For a deleg stateid kept around only to process free_stateid's: */
 #define NFS4_REVOKED_DELEG_STID 16
+#define NFS4_LAYOUT_STID 32
 	unsigned char sc_type;
 	stateid_t sc_stateid;
 	struct nfs4_client *sc_client;
@@ -486,6 +487,9 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 extern void put_nfs4_file(struct nfs4_file *);
 extern void get_nfs4_file(struct nfs4_file *);
 extern struct nfs4_client *find_confirmed_client(clientid_t *, bool sessions, struct nfsd_net *);
+extern struct nfs4_stid *nfsd4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab);
+extern void nfsd4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s);
+extern void nfsd4_remove_stid(struct nfs4_stid *s);
 
 #if defined(CONFIG_PNFSD)
 extern int nfsd4_init_pnfs_slabs(void);
-- 
1.8.3.1

