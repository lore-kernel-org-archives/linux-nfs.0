Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:58295 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbaGYLem (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jul 2014 07:34:42 -0400
Received: by mail-qa0-f46.google.com with SMTP id v10so4374494qac.5
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 04:34:42 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v6 1/9] nfsd: simplify stateid allocation and file handling
Date: Fri, 25 Jul 2014 07:34:19 -0400
Message-Id: <1406288067-20663-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
References: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Don't allow stateids to clear the open file pointer until they are
being destroyed. In a later patches we'll want to rely on the fact that
we have a valid file pointer when dealing with the stateid and this
will save us from having to do a lot of NULL pointer checks before
doing so.

Also, move to allocating stateids with kzalloc and get rid of the
explicit zeroing of fields.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1dfc8ee85c93..fdbfbcb70914 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -470,7 +470,7 @@ kmem_cache *slab)
 	struct nfs4_stid *stid;
 	int new_id;
 
-	stid = kmem_cache_alloc(slab, GFP_KERNEL);
+	stid = kmem_cache_zalloc(slab, GFP_KERNEL);
 	if (!stid)
 		return NULL;
 
@@ -478,11 +478,9 @@ kmem_cache *slab)
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
@@ -603,10 +601,8 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
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
@@ -627,6 +623,8 @@ void
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
 	if (atomic_dec_and_test(&dp->dl_stid.sc_count)) {
+		if (dp->dl_file)
+			put_nfs4_file(dp->dl_file);
 		remove_stid(&dp->dl_stid);
 		nfs4_free_stid(deleg_slab, &dp->dl_stid);
 		num_delegations--;
@@ -678,13 +676,9 @@ unhash_delegation(struct nfs4_delegation *dp)
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
@@ -892,12 +886,12 @@ static void unhash_generic_stateid(struct nfs4_ol_stateid *stp)
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
@@ -4469,6 +4463,10 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
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

