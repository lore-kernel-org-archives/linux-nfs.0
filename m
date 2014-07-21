Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:52434 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932332AbaGUPDd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:33 -0400
Received: by mail-qc0-f170.google.com with SMTP id c9so5811526qcz.29
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:32 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 23/40] nfsd: Add reference counting to state owners
Date: Mon, 21 Jul 2014 11:02:35 -0400
Message-Id: <1405954972-28904-24-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

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
 fs/nfsd/nfs4state.c | 43 +++++++++++++++++++++++++++++--------------
 fs/nfsd/state.h     |  3 +++
 2 files changed, 32 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8f724aa429ed..d96737f72c46 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -72,6 +72,7 @@ static u64 current_sessionid = 1;
 /* forward declarations */
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
 static void nfs4_free_generic_stateid(struct nfs4_stid *stid);
+static void nfs4_put_stateowner(struct nfs4_stateowner *sop);
 
 /* Locking: */
 
@@ -955,16 +956,10 @@ static void unhash_lockowner(struct nfs4_lockowner *lo)
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
@@ -1034,18 +1029,12 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
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
@@ -2979,9 +2968,17 @@ static inline void *alloc_stateowner(struct kmem_cache *slab, struct xdr_netobj
 	INIT_LIST_HEAD(&sop->so_stateids);
 	sop->so_client = clp;
 	init_nfs4_replay(&sop->so_replay);
+	atomic_set(&sop->so_count, 1);
 	return sop;
 }
 
+static void nfs4_put_stateowner(struct nfs4_stateowner *sop)
+{
+	if (!atomic_dec_and_test(&sop->so_count))
+		return;
+	sop->so_free(sop);
+}
+
 static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, unsigned int strhashval)
 {
 	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
@@ -2990,6 +2987,14 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
 	list_add(&oo->oo_perclient, &clp->cl_openowners);
 }
 
+static void nfs4_free_openowner(struct nfs4_stateowner *so)
+{
+	struct nfs4_openowner *oo = openowner(so);
+
+	kfree(oo->oo_owner.so_owner.data);
+	kmem_cache_free(openowner_slab, oo);
+}
+
 static struct nfs4_openowner *
 alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 			   struct nfsd4_compound_state *cstate)
@@ -3000,6 +3005,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 	oo = alloc_stateowner(openowner_slab, &open->op_owner, clp);
 	if (!oo)
 		return NULL;
+	oo->oo_owner.so_free = nfs4_free_openowner;
 	oo->oo_owner.so_is_open_owner = 1;
 	oo->oo_owner.so_seqid = open->op_seqid;
 	oo->oo_flags = NFS4_OO_NEW;
@@ -4746,6 +4752,14 @@ find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
 	return NULL;
 }
 
+static void nfs4_free_lockowner(struct nfs4_stateowner *sop)
+{
+	struct nfs4_lockowner *lo = lockowner(sop);
+
+	kfree(lo->lo_owner.so_owner.data);
+	kmem_cache_free(lockowner_slab, lo);
+}
+
 /*
  * Alloc a lock owner structure.
  * Called in nfsd4_lock - therefore, OPEN and OPEN_CONFIRM (if needed) has 
@@ -4766,6 +4780,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	/* It is the openowner seqid that will be incremented in encode in the
 	 * case of new lockowners; so increment the lock seqid manually: */
 	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid + 1;
+	lo->lo_owner.so_free = nfs4_free_lockowner;
 	list_add(&lo->lo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
 	return lo;
 }
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 5c30e6064749..3cb7283bc42a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -339,10 +339,13 @@ struct nfs4_stateowner {
 	struct nfs4_client *    so_client;
 	/* after increment in ENCODE_SEQID_OP_TAIL, represents the next
 	 * sequence id expected from the client: */
+	atomic_t		so_count;
 	u32                     so_seqid;
 	struct xdr_netobj       so_owner;     /* open owner name */
 	struct nfs4_replay	so_replay;
 	bool			so_is_open_owner;
+
+	void (*so_free)(struct nfs4_stateowner *);
 };
 
 struct nfs4_openowner {
-- 
1.9.3

