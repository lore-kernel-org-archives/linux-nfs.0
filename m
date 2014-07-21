Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:36243 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932423AbaGUPDI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:08 -0400
Received: by mail-qa0-f43.google.com with SMTP id w8so5220733qac.16
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:08 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 06/40] nfsd: Cleanup the freeing of stateids
Date: Mon, 21 Jul 2014 11:02:18 -0400
Message-Id: <1405954972-28904-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
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
index 0243a19dbef4..7b329b28734c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -71,6 +71,7 @@ static u64 current_sessionid = 1;
 
 /* forward declarations */
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
+static void nfs4_free_generic_stateid(struct nfs4_stid *stid);
 
 /* Locking: */
 
@@ -452,8 +453,15 @@ static void nfs4_file_put_access(struct nfs4_file *fp, u32 access)
 		__nfs4_file_put_access(fp, O_RDONLY);
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
@@ -492,7 +500,22 @@ out_free:
 
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
+	atomic_long_dec(&num_delegations);
 }
 
 /*
@@ -586,6 +609,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh)
 	dp = delegstateid(nfs4_alloc_stid(clp, deleg_slab));
 	if (dp == NULL)
 		goto out_dec;
+
+	dp->dl_stid.sc_free = nfs4_free_deleg;
 	/*
 	 * delegation seqid's are never incremented.  The 4.1 special
 	 * meaning of seqid 0 isn't meaningful, really, but let's avoid
@@ -611,32 +636,23 @@ static void remove_stid_locked(struct nfs4_client *clp, struct nfs4_stid *s)
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
 
 	might_lock(&clp->cl_lock);
 
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
-		atomic_long_dec(&num_delegations);
+	nfs4_put_stid(&dp->dl_stid);
 }
 
 static void nfs4_put_deleg_lease(struct nfs4_file *fp)
@@ -887,14 +903,17 @@ static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
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
@@ -907,7 +926,6 @@ static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
 	file = find_any_file(stp->st_stid.sc_file);
 	if (file)
 		filp_close(file, (fl_owner_t)lockowner(stp->st_stateowner));
-	close_generic_stateid(stp);
 	put_generic_stateid(stp);
 }
 
@@ -965,7 +983,6 @@ static void unhash_open_stateid(struct nfs4_ol_stateid *stp)
 {
 	unhash_generic_stateid(stp);
 	release_open_stateid_locks(stp);
-	close_generic_stateid(stp);
 }
 
 static void release_open_stateid(struct nfs4_ol_stateid *stp)
@@ -4501,8 +4518,11 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
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
index 1be148ec9440..5c30e6064749 100644
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

