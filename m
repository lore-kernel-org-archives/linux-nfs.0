Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:57572 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757959AbaFSOv0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:26 -0400
Received: by mail-qa0-f43.google.com with SMTP id k15so2032605qaq.2
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:25 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 019/104] NFSd: Simplify stateid management
Date: Thu, 19 Jun 2014 10:49:25 -0400
Message-Id: <1403189450-18729-20-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Don't allow stateids to clear the open file pointer until they are
being destroyed.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 427efcdb81e6..6f9a0d2d0223 100644
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
@@ -507,10 +505,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	INIT_LIST_HEAD(&dp->dl_perfile);
 	INIT_LIST_HEAD(&dp->dl_perclnt);
 	INIT_LIST_HEAD(&dp->dl_recall_lru);
-	dp->dl_file = NULL;
 	dp->dl_type = NFS4_OPEN_DELEGATE_READ;
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
-	dp->dl_time = 0;
 	nfsd4_init_callback(&dp->dl_recall);
 	return dp;
 }
@@ -533,6 +529,8 @@ void
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
 	if (atomic_dec_and_test(&dp->dl_stid.sc_count)) {
+		if (dp->dl_file)
+			put_nfs4_file(dp->dl_file);
 		nfs4_free_stid(deleg_slab, &dp->dl_stid);
 		num_delegations--;
 	}
@@ -580,12 +578,9 @@ unhash_delegation(struct nfs4_delegation *dp)
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
 
 
@@ -745,13 +740,13 @@ static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
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
 
@@ -4329,8 +4324,13 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	if (cstate->minorversion)
 		free_generic_stateid(stp);
-	else
+	else {
+		if (stp->st_file) {
+			put_nfs4_file(stp->st_file);
+			stp->st_file = NULL;
+		}
 		oo->oo_last_closed_stid = stp;
+	}
 
 	if (list_empty(&oo->oo_owner.so_stateids)) {
 		if (cstate->minorversion)
-- 
1.9.3

