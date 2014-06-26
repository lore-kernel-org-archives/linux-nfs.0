Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:49993 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbaFZTOs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:48 -0400
Received: by mail-qg0-f48.google.com with SMTP id q108so3414989qgd.21
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:47 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 045/117] nfsd: Cleanup the freeing of stateids
Date: Thu, 26 Jun 2014 15:12:25 -0400
Message-Id: <1403810017-16062-46-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Add a ->free() callback to the struct nfs4_stid, so that we can
release a reference to the stid without caring about the contents.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 62 +++++++++++++++++++++++++++++++++++------------------
 fs/nfsd/state.h     |  2 ++
 2 files changed, 43 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d3e845fa419a..b56ff136039d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -71,6 +71,7 @@ static u64 current_sessionid = 1;
 
 /* forward declarations */
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
+static void nfs4_free_generic_stateid(struct nfs4_stid *stid);
 static __be32 lookup_clientid(clientid_t *clid,
 		struct nfsd4_compound_state *cstate,
 		struct nfsd_net *nn);
@@ -485,8 +486,15 @@ static void nfs4_file_put_access(struct nfs4_file *fp, u32 access)
 		__nfs4_file_put_access(fp, oflag);
 }
 
-static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct
-kmem_cache *slab)
+static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
+{
+	if (s->sc_file)
+		put_nfs4_file(s->sc_file);
+	kmem_cache_free(slab, s);
+}
+
+static struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
+					 struct kmem_cache *slab)
 {
 	struct nfs4_stid *stid;
 	int new_id;
@@ -525,7 +533,22 @@ out_free:
 
 static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
 {
-	return openlockstateid(nfs4_alloc_stid(clp, stateid_slab));
+	struct nfs4_stid *stid;
+	struct nfs4_ol_stateid *stp;
+
+	stid = nfs4_alloc_stid(clp, stateid_slab);
+	if (!stid)
+		return NULL;
+
+	stp = openlockstateid(stid);
+	stp->st_stid.sc_free = nfs4_free_generic_stateid;
+	return stp;
+}
+
+static void nfs4_free_deleg(struct nfs4_stid *stid)
+{
+	nfs4_free_stid(deleg_slab, stid);
+	num_delegations--;
 }
 
 /*
@@ -614,6 +637,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	dp = delegstateid(nfs4_alloc_stid(clp, deleg_slab));
 	if (dp == NULL)
 		return dp;
+
+	dp->dl_stid.sc_free = nfs4_free_deleg;
 	/*
 	 * delegation seqid's are never incremented.  The 4.1 special
 	 * meaning of seqid 0 isn't meaningful, really, but let's avoid
@@ -636,30 +661,21 @@ static void remove_stid_locked(struct nfs4_client *clp, struct nfs4_stid *s)
 	idr_remove(&clp->cl_stateids, s->sc_stateid.si_opaque.so_id);
 }
 
-static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
-{
-	if (s->sc_file)
-		put_nfs4_file(s->sc_file);
-	kmem_cache_free(slab, s);
-}
-
-static bool nfs4_put_stid(struct kmem_cache *slab, struct nfs4_stid *s)
+static void nfs4_put_stid(struct nfs4_stid *s)
 {
 	struct nfs4_client *clp = s->sc_client;
 
 	if (!atomic_dec_and_lock(&s->sc_count, &clp->cl_lock))
-		return false;
+		return;
 	remove_stid_locked(clp, s);
 	spin_unlock(&clp->cl_lock);
-	nfs4_free_stid(slab, s);
-	return true;
+	s->sc_free(s);
 }
 
 void
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
-	if (nfs4_put_stid(deleg_slab, &dp->dl_stid))
-		num_delegations--;
+	nfs4_put_stid(&dp->dl_stid);
 }
 
 static void nfs4_put_deleg_lease(struct nfs4_file *fp)
@@ -875,14 +891,17 @@ static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 	list_del(&stp->st_perstateowner);
 }
 
-static void close_generic_stateid(struct nfs4_ol_stateid *stp)
+static void nfs4_free_generic_stateid(struct nfs4_stid *stid)
 {
+	struct nfs4_ol_stateid *stp = openlockstateid(stid);
+
 	release_all_access(stp);
+	nfs4_free_stid(stateid_slab, stid);
 }
 
 static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 {
-	nfs4_put_stid(stateid_slab, &stp->st_stid);
+	nfs4_put_stid(&stp->st_stid);
 }
 
 static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
@@ -895,7 +914,6 @@ static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 	file = find_any_file(stp->st_stid.sc_file);
 	if (file)
 		filp_close(file, (fl_owner_t)lockowner(stp->st_stateowner));
-	close_generic_stateid(stp);
 	put_generic_stateid(stp);
 }
 
@@ -953,7 +971,6 @@ static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 {
 	unhash_generic_stateid(stp);
 	release_open_stateid_locks(stp);
-	close_generic_stateid(stp);
 }
 
 static void release_open_stateid(struct nfs4_ol_stateid *stp)
@@ -4455,8 +4472,11 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 		oo->oo_last_closed_stid = s;
 		/*
 		 * In the 4.0 case we need to keep the owners around a
-		 * little while to handle CLOSE replay.
+		 * little while to handle CLOSE replay. We still do need
+		 * to release any file access that is held by them
+		 * before returning however.
 		 */
+		release_all_access(s);
 		if (list_empty(&oo->oo_owner.so_stateids))
 			move_to_close_lru(oo, clp->net);
 	}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 7aaf6e74504c..700ea964fe54 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -86,6 +86,8 @@ struct nfs4_stid {
 	stateid_t sc_stateid;
 	struct nfs4_client *sc_client;
 	struct nfs4_file *sc_file;
+
+	void (*sc_free)(struct nfs4_stid *);
 };
 
 struct nfs4_delegation {
-- 
1.9.3

