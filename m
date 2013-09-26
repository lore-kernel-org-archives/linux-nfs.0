Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f52.google.com ([209.85.128.52]:60356 "EHLO
	mail-qe0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753553Ab3IZSlI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:41:08 -0400
Received: by mail-qe0-f52.google.com with SMTP id i11so1094294qej.39
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:41:07 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 18/49] pnfsd: nfs4_assert_state_locked
Date: Thu, 26 Sep 2013 14:41:05 -0400
Message-Id: <1380220865-13506-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make sure the state lock state is taken.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 15 +++++++++++++++
 fs/nfsd/state.h     |  1 +
 2 files changed, 16 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 68b6f7a..f6022a6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -135,6 +135,12 @@ static bool is_client_expired(struct nfs4_client *clp)
 	return clp->cl_time == 0;
 }
 
+void
+nfs4_assert_state_locked(void)
+{
+	BUG_ON(!mutex_is_locked(&client_mutex));
+}
+
 static __be32 mark_client_expired_locked(struct nfs4_client *clp)
 {
 	if (atomic_read(&clp->cl_refcount))
@@ -331,6 +337,7 @@ static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct
 	struct nfs4_stid *stid;
 	int new_id;
 
+	nfs4_assert_state_locked();
 	stid = kmem_cache_alloc(slab, GFP_KERNEL);
 	if (!stid)
 		return NULL;
@@ -400,6 +407,7 @@ static void remove_stid(struct nfs4_stid *s)
 {
 	struct idr *stateids = &s->sc_client->cl_stateids;
 
+	nfs4_assert_state_locked();
 	idr_remove(stateids, s->sc_stateid.si_opaque.so_id);
 }
 
@@ -1306,6 +1314,7 @@ static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
 {
 	struct nfs4_stid *ret;
 
+	nfs4_assert_state_locked();
 	ret = idr_find(&cl->cl_stateids, t->si_opaque.so_id);
 	if (!ret || !ret->sc_type)
 		return NULL;
@@ -1394,6 +1403,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	struct rb_node *node = root->rb_node;
 	struct nfs4_client *clp;
 
+	nfs4_assert_state_locked();
 	while (node) {
 		clp = rb_entry(node, struct nfs4_client, cl_namenode);
 		cmp = compare_blob(&clp->cl_name, name);
@@ -1440,6 +1450,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	struct nfs4_client *clp;
 	unsigned int idhashval = clientid_hashval(clid->cl_id);
 
+	nfs4_assert_state_locked();
 	list_for_each_entry(clp, &tbl[idhashval], cl_idhash) {
 		if (same_clid(&clp->cl_clientid, clid)) {
 			if ((bool)clp->cl_minorversion != sessions)
@@ -2589,6 +2600,7 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
 {
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
+	nfs4_assert_state_locked();
 	list_add(&oo->oo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
 	list_add(&oo->oo_perclient, &clp->cl_openowners);
 }
@@ -2655,6 +2667,7 @@ static void init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
 	struct nfs4_openowner *oo;
 	struct nfs4_client *clp;
 
+	nfs4_assert_state_locked();
 	list_for_each_entry(so, &nn->ownerstr_hashtbl[hashval], so_strhash) {
 		if (!so->so_is_open_owner)
 			continue;
@@ -4166,6 +4179,7 @@ static bool same_lockowner_ino(struct nfs4_lockowner *lo, struct inode *inode, c
 	unsigned int hashval = lockowner_ino_hashval(inode, clid->cl_id, owner);
 	struct nfs4_lockowner *lo;
 
+	nfs4_assert_state_locked();
 	list_for_each_entry(lo, &nn->lockowner_ino_hashtbl[hashval], lo_owner_ino_hash) {
 		if (same_lockowner_ino(lo, inode, clid, owner))
 			return lo;
@@ -4180,6 +4194,7 @@ static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, s
 			clp->cl_clientid.cl_id, &lo->lo_owner.so_owner);
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 
+	nfs4_assert_state_locked();
 	list_add(&lo->lo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
 	list_add(&lo->lo_owner_ino_hash, &nn->lockowner_ino_hashtbl[inohash]);
 	list_add(&lo->lo_perstateid, &open_stp->st_lockowners);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 424d8f5..2e601a2 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -459,6 +459,7 @@ extern __be32 nfs4_preprocess_stateid_op(struct net *net,
 		stateid_t *stateid, int flags, struct file **filp);
 extern void nfs4_lock_state(void);
 extern void nfs4_unlock_state(void);
+extern void nfs4_assert_state_locked(void);
 void nfs4_remove_reclaim_record(struct nfs4_client_reclaim *, struct nfsd_net *);
 extern void nfs4_release_reclaim(struct nfsd_net *);
 extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(const char *recdir,
-- 
1.8.3.1

