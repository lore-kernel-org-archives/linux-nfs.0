Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:37464 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbaF3PvU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:20 -0400
Received: by mail-qg0-f50.google.com with SMTP id j5so2125587qga.37
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:20 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 034/114] nfsd: Simplify stateid management
Date: Mon, 30 Jun 2014 11:49:03 -0400
Message-Id: <1404143423-24381-35-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Don't allow stateids to clear the open file pointer until they are
being destroyed. Also, move to kzalloc and get rid of explicit
zeroing of fields.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f14b925f9de0..fdbd209b02a6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -447,7 +447,7 @@ kmem_cache *slab)
 	struct nfs4_stid *stid;
 	int new_id;
 
-	stid = kmem_cache_alloc(slab, GFP_KERNEL);
+	stid = kmem_cache_zalloc(slab, GFP_KERNEL);
 	if (!stid)
 		return NULL;
 
@@ -459,11 +459,9 @@ kmem_cache *slab)
 	if (new_id < 0)
 		goto out_free;
 	stid->sc_client = cl;
-	stid->sc_type = 0;
 	stid->sc_stateid.si_opaque.so_id = new_id;
 	stid->sc_stateid.si_opaque.so_clid = cl->cl_clientid;
 	/* Will be incremented before return to client: */
-	stid->sc_stateid.si_generation = 0;
 	atomic_set(&stid->sc_count, 1);
 
 	/*
@@ -582,10 +580,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	INIT_LIST_HEAD(&dp->dl_perfile);
 	INIT_LIST_HEAD(&dp->dl_perclnt);
 	INIT_LIST_HEAD(&dp->dl_recall_lru);
-	dp->dl_file = NULL;
 	dp->dl_type = NFS4_OPEN_DELEGATE_READ;
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
-	dp->dl_time = 0;
 	return dp;
 }
 
@@ -607,6 +603,8 @@ void
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
 	if (atomic_dec_and_test(&dp->dl_stid.sc_count)) {
+		if (dp->dl_file)
+			put_nfs4_file(dp->dl_file);
 		nfs4_free_stid(deleg_slab, &dp->dl_stid);
 		num_delegations--;
 	}
@@ -654,12 +652,9 @@ unhash_delegation(struct nfs4_delegation *dp)
 	list_del_init(&dp->dl_recall_lru);
 	list_del_init(&dp->dl_perfile);
 	spin_unlock(&fp->fi_lock);
-	if (fp) {
+	if (fp)
 		nfs4_put_deleg_lease(fp);
-		dp->dl_file = NULL;
-	}
 	spin_unlock(&state_lock);
-	put_nfs4_file(fp);
 }
 
 
@@ -845,13 +840,13 @@ static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	release_all_access(stp);
-	put_nfs4_file(stp->st_file);
-	stp->st_file = NULL;
 }
 
 static void free_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	remove_stid(&stp->st_stid);
+	if (stp->st_file)
+		put_nfs4_file(stp->st_file);
 	nfs4_free_stid(stateid_slab, &stp->st_stid);
 }
 
@@ -4406,6 +4401,10 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 		if (list_empty(&oo->oo_owner.so_stateids))
 			release_openowner(oo);
 	} else {
+		if (s->st_file) {
+			put_nfs4_file(s->st_file);
+			s->st_file = NULL;
+		}
 		oo->oo_last_closed_stid = s;
 		/*
 		 * In the 4.0 case we need to keep the owners around a
-- 
1.9.3

