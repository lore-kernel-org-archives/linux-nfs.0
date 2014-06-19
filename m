Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:59960 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758052AbaFSOwE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:04 -0400
Received: by mail-qc0-f173.google.com with SMTP id l6so2220029qcy.4
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:03 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 045/104] NFSd: Add reference counting to state owners
Date: Thu, 19 Jun 2014 10:49:51 -0400
Message-Id: <1403189450-18729-46-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 42 ++++++++++++++++++++++++++++--------------
 fs/nfsd/state.h     |  3 +++
 2 files changed, 31 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4ddd7ec31d6c..c96a9b7071e1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -71,6 +71,7 @@ static u64 current_sessionid = 1;
 /* forward declarations */
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
 static void nfs4_free_generic_stateid(struct nfs4_stid *stid);
+static void nfs4_put_stateowner(struct nfs4_stateowner *sop);
 
 /* Locking: */
 
@@ -826,16 +827,10 @@ static void unhash_lockowner(struct nfs4_lockowner *lo)
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
@@ -905,18 +900,12 @@ static void release_last_closed_stateid(struct nfs4_openowner *oo)
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
@@ -2860,9 +2849,17 @@ static inline void *alloc_stateowner(struct kmem_cache *slab, struct xdr_netobj
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
@@ -2871,6 +2868,14 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
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
 alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, struct nfsd4_open *open) {
 	struct nfs4_openowner *oo;
@@ -2878,6 +2883,7 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	oo = alloc_stateowner(openowner_slab, &open->op_owner, clp);
 	if (!oo)
 		return NULL;
+	oo->oo_owner.so_free = nfs4_free_openowner;
 	oo->oo_owner.so_is_open_owner = 1;
 	oo->oo_owner.so_seqid = open->op_seqid;
 	oo->oo_flags = NFS4_OO_NEW;
@@ -4590,6 +4596,13 @@ static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, s
 	list_add(&lo->lo_owner.so_strhash, &nn->ownerstr_hashtbl[strhashval]);
 }
 
+static void nfs4_free_lockowner(struct nfs4_stateowner *sop)
+{
+	struct nfs4_lockowner *lo = lockowner(sop);
+	kfree(lo->lo_owner.so_owner.data);
+	kmem_cache_free(lockowner_slab, lo);
+}
+
 /*
  * Alloc a lock owner structure.
  * Called in nfsd4_lock - therefore, OPEN and OPEN_CONFIRM (if needed) has 
@@ -4611,6 +4624,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	 * case of new lockowners; so increment the lock seqid manually: */
 	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid + 1;
 	hash_lockowner(lo, strhashval, clp);
+	lo->lo_owner.so_free = nfs4_free_lockowner;
 	return lo;
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f5dee9e8550a..ebd3d302a572 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -340,10 +340,13 @@ struct nfs4_stateowner {
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

