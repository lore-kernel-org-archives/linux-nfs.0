Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f50.google.com ([209.85.216.50]:48707 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754734AbaG3BfW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:35:22 -0400
Received: by mail-qa0-f50.google.com with SMTP id s7so583862qap.23
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:35:21 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v3 21/38] nfsd: Add reference counting to state owners
Date: Tue, 29 Jul 2014 21:34:26 -0400
Message-Id: <1406684083-19736-22-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The way stateowners are managed today is somewhat awkward. They need to
be explicitly destroyed, even though the stateids reference them. This
will be particularly problematic when we remove the client_mutex.

We may create a new stateowner and attempt to open a file or set a lock,
and have that fail. In the meantime, another RPC may come in that uses
that same stateowner and succeed. We can't have the first task tearing
down the stateowner in that situation.

To fix this, we need to change how stateowners are tracked altogether.
Refcount them and only destroy them once all stateids that reference
them have been destroyed. This patch starts by adding the refcounting
necessary to do that.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 49 +++++++++++++++++++++++++++++++++++--------------
 fs/nfsd/state.h     | 22 +++++++++++++++-------
 2 files changed, 50 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 653de6b14665..5a93e5fafd4a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -890,6 +890,14 @@ release_all_access(struct nfs4_ol_stateid *stp)
 	}
 }
 
+static void nfs4_put_stateowner(struct nfs4_stateowner *sop)
+{
+	if (!atomic_dec_and_test(&sop->so_count))
+		return;
+	kfree(sop->so_owner.data);
+	sop->so_ops->so_free(sop);
+}
+
 static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_file *fp = stp->st_stid.sc_file;
@@ -946,16 +954,10 @@ static void unhash_lockowner(struct nfs4_lockowner *lo)
 	}
 }
 
-static void nfs4_free_lockowner(struct nfs4_lockowner *lo)
-{
-	kfree(lo->lo_owner.so_owner.data);
-	kmem_cache_free(lockowner_slab, lo);
-}
-
 static void release_lockowner(struct nfs4_lockowner *lo)
 {
 	unhash_lockowner(lo);
-	nfs4_free_lockowner(lo);
+	nfs4_put_stateowner(&lo->lo_owner);
 }
 
 static void release_lockowner_if_empty(struct nfs4_lockowner *lo)
@@ -1025,18 +1027,12 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
 	}
 }
 
-static void nfs4_free_openowner(struct nfs4_openowner *oo)
-{
-	kfree(oo->oo_owner.so_owner.data);
-	kmem_cache_free(openowner_slab, oo);
-}
-
 static void release_openowner(struct nfs4_openowner *oo)
 {
 	unhash_openowner(oo);
 	list_del(&oo->oo_close_lru);
 	release_last_closed_stateid(oo);
-	nfs4_free_openowner(oo);
+	nfs4_put_stateowner(&oo->oo_owner);
 }
 
 static inline int
@@ -2964,6 +2960,7 @@ static inline void *alloc_stateowner(struct kmem_cache *slab, struct xdr_netobj
 	INIT_LIST_HEAD(&sop->so_stateids);
 	sop->so_client = clp;
 	init_nfs4_replay(&sop->so_replay);
+	atomic_set(&sop->so_count, 1);
 	return sop;
 }
 
@@ -2975,6 +2972,17 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
 	list_add(&oo->oo_perclient, &clp->cl_openowners);
 }
 
+static void nfs4_free_openowner(struct nfs4_stateowner *so)
+{
+	struct nfs4_openowner *oo = openowner(so);
+
+	kmem_cache_free(openowner_slab, oo);
+}
+
+static const struct nfs4_stateowner_operations openowner_ops = {
+	.so_free = nfs4_free_openowner,
+};
+
 static struct nfs4_openowner *
 alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 			   struct nfsd4_compound_state *cstate)
@@ -2985,6 +2993,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 	oo = alloc_stateowner(openowner_slab, &open->op_owner, clp);
 	if (!oo)
 		return NULL;
+	oo->oo_owner.so_ops = &openowner_ops;
 	oo->oo_owner.so_is_open_owner = 1;
 	oo->oo_owner.so_seqid = open->op_seqid;
 	oo->oo_flags = NFS4_OO_NEW;
@@ -4729,6 +4738,17 @@ find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
 	return NULL;
 }
 
+static void nfs4_free_lockowner(struct nfs4_stateowner *sop)
+{
+	struct nfs4_lockowner *lo = lockowner(sop);
+
+	kmem_cache_free(lockowner_slab, lo);
+}
+
+static const struct nfs4_stateowner_operations lockowner_ops = {
+	.so_free = nfs4_free_lockowner,
+};
+
 /*
  * Alloc a lock owner structure.
  * Called in nfsd4_lock - therefore, OPEN and OPEN_CONFIRM (if needed) has 
@@ -4749,6 +4769,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	/* It is the openowner seqid that will be incremented in encode in the
 	 * case of new lockowners; so increment the lock seqid manually: */
 	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid + 1;
+	lo->lo_owner.so_ops = &lockowner_ops;
 	list_add(&lo->lo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
 	return lo;
 }
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index af1d9c42e939..dc725deb4aa8 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -331,16 +331,24 @@ struct nfs4_replay {
 	char			rp_ibuf[NFSD4_REPLAY_ISIZE];
 };
 
+struct nfs4_stateowner;
+
+struct nfs4_stateowner_operations {
+	void (*so_free)(struct nfs4_stateowner *);
+};
+
 struct nfs4_stateowner {
-	struct list_head        so_strhash;   /* hash by op_name */
-	struct list_head        so_stateids;
-	struct nfs4_client *    so_client;
+	struct list_head			so_strhash;
+	struct list_head			so_stateids;
+	struct nfs4_client			*so_client;
+	const struct nfs4_stateowner_operations	*so_ops;
 	/* after increment in ENCODE_SEQID_OP_TAIL, represents the next
 	 * sequence id expected from the client: */
-	u32                     so_seqid;
-	struct xdr_netobj       so_owner;     /* open owner name */
-	struct nfs4_replay	so_replay;
-	bool			so_is_open_owner;
+	atomic_t				so_count;
+	u32					so_seqid;
+	struct xdr_netobj			so_owner; /* open owner name */
+	struct nfs4_replay			so_replay;
+	bool					so_is_open_owner;
 };
 
 struct nfs4_openowner {
-- 
1.9.3

