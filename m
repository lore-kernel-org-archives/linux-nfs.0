Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:64110 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754957AbaGQTMq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2014 15:12:46 -0400
Received: by mail-qc0-f173.google.com with SMTP id c9so2481513qcz.18
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jul 2014 12:12:45 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] nfsd: simplify stateid allocation and file handling
Date: Thu, 17 Jul 2014 15:12:31 -0400
Message-Id: <1405624354-22388-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405624354-22388-1-git-send-email-jlayton@primarydata.com>
References: <1405624354-22388-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Don't allow stateids to clear the open file pointer until they are
being destroyed. In a later patch we'll want to move the putting of
the nfs4_file into generic stateid handling code.

Also, move to kzalloc and get rid of explicit zeroing of fields.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d88a33fa8e8f..c06a08711e7f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -459,7 +459,7 @@ kmem_cache *slab)
 	struct nfs4_stid *stid;
 	int new_id;
 
-	stid = kmem_cache_alloc(slab, GFP_KERNEL);
+	stid = kmem_cache_zalloc(slab, GFP_KERNEL);
 	if (!stid)
 		return NULL;
 
@@ -467,11 +467,9 @@ kmem_cache *slab)
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
@@ -592,10 +590,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	INIT_LIST_HEAD(&dp->dl_perfile);
 	INIT_LIST_HEAD(&dp->dl_perclnt);
 	INIT_LIST_HEAD(&dp->dl_recall_lru);
-	dp->dl_file = NULL;
 	dp->dl_type = NFS4_OPEN_DELEGATE_READ;
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
-	dp->dl_time = 0;
 	INIT_WORK(&dp->dl_recall.cb_work, nfsd4_run_cb_recall);
 	return dp;
 }
@@ -616,6 +612,8 @@ void
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
 	if (atomic_dec_and_test(&dp->dl_stid.sc_count)) {
+		if (dp->dl_file)
+			put_nfs4_file(dp->dl_file);
 		remove_stid(&dp->dl_stid);
 		nfs4_free_stid(deleg_slab, &dp->dl_stid);
 		num_delegations--;
@@ -665,13 +663,9 @@ unhash_delegation(struct nfs4_delegation *dp)
 	list_del_init(&dp->dl_recall_lru);
 	list_del_init(&dp->dl_perfile);
 	spin_unlock(&fp->fi_lock);
-	if (fp) {
+	if (fp)
 		nfs4_put_deleg_lease(fp);
-		dp->dl_file = NULL;
-	}
 	spin_unlock(&state_lock);
-	if (fp)
-		put_nfs4_file(fp);
 }
 
 static void destroy_revoked_delegation(struct nfs4_delegation *dp)
@@ -879,12 +873,12 @@ static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
 static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	release_all_access(stp);
-	put_nfs4_file(stp->st_file);
-	stp->st_file = NULL;
 }
 
 static void free_generic_stateid(struct nfs4_ol_stateid *stp)
 {
+	if (stp->st_file)
+		put_nfs4_file(stp->st_file);
 	remove_stid(&stp->st_stid);
 	nfs4_free_stid(stateid_slab, &stp->st_stid);
 }
@@ -4447,6 +4441,10 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
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

