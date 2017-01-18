Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33072 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753847AbdARLE6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jan 2017 06:04:58 -0500
Received: by mail-pg0-f66.google.com with SMTP id 194so1160631pgd.0
        for <linux-nfs@vger.kernel.org>; Wed, 18 Jan 2017 03:04:53 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] NFSD: Fix a null reference case in
 find_or_create_lock_stateid()
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <7b2e18b5-8ffe-d1c7-6aa4-9c8ff41d630f@gmail.com>
Date: Wed, 18 Jan 2017 19:04:42 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd assigns the nfs4_free_lock_stateid to .sc_free in init_lock_stateid().

If nfsd doesn't go through init_lock_stateid() and put stateid at end,
there is a NULL reference to .sc_free when calling nfs4_put_stid(ns).

This patch let the nfs4_stid.sc_free assignment to nfs4_alloc_stid().

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4layouts.c |  5 +++--
 fs/nfsd/nfs4state.c   | 19 ++++++++-----------
 fs/nfsd/state.h       |  4 ++--
 3 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 596205d..1fc07a9 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -223,10 +223,11 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
 	struct nfs4_layout_stateid *ls;
 	struct nfs4_stid *stp;
 
-	stp = nfs4_alloc_stid(cstate->clp, nfs4_layout_stateid_cache);
+	stp = nfs4_alloc_stid(cstate->clp, nfs4_layout_stateid_cache,
+					nfsd4_free_layout_stateid);
 	if (!stp)
 		return NULL;
-	stp->sc_free = nfsd4_free_layout_stateid;
+
 	get_nfs4_file(fp);
 	stp->sc_file = fp;
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4b4beaa..a0dee8a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -633,8 +633,8 @@ find_or_hash_clnt_odstate(struct nfs4_file *fp, struct nfs4_clnt_odstate *new)
 	return co;
 }
 
-struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
-					 struct kmem_cache *slab)
+struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab,
+				  void (*sc_free)(struct nfs4_stid *))
 {
 	struct nfs4_stid *stid;
 	int new_id;
@@ -650,6 +650,8 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
 	idr_preload_end();
 	if (new_id < 0)
 		goto out_free;
+
+	stid->sc_free = sc_free;
 	stid->sc_client = cl;
 	stid->sc_stateid.si_opaque.so_id = new_id;
 	stid->sc_stateid.si_opaque.so_clid = cl->cl_clientid;
@@ -675,15 +677,12 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
 static struct nfs4_ol_stateid * nfs4_alloc_open_stateid(struct nfs4_client *clp)
 {
 	struct nfs4_stid *stid;
-	struct nfs4_ol_stateid *stp;
 
-	stid = nfs4_alloc_stid(clp, stateid_slab);
+	stid = nfs4_alloc_stid(clp, stateid_slab, nfs4_free_ol_stateid);
 	if (!stid)
 		return NULL;
 
-	stp = openlockstateid(stid);
-	stp->st_stid.sc_free = nfs4_free_ol_stateid;
-	return stp;
+	return openlockstateid(stid);
 }
 
 static void nfs4_free_deleg(struct nfs4_stid *stid)
@@ -781,11 +780,10 @@ alloc_init_deleg(struct nfs4_client *clp, struct svc_fh *current_fh,
 		goto out_dec;
 	if (delegation_blocked(&current_fh->fh_handle))
 		goto out_dec;
-	dp = delegstateid(nfs4_alloc_stid(clp, deleg_slab));
+	dp = delegstateid(nfs4_alloc_stid(clp, deleg_slab, nfs4_free_deleg));
 	if (dp == NULL)
 		goto out_dec;
 
-	dp->dl_stid.sc_free = nfs4_free_deleg;
 	/*
 	 * delegation seqid's are never incremented.  The 4.1 special
 	 * meaning of seqid 0 isn't meaningful, really, but let's avoid
@@ -5580,7 +5578,6 @@ init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
 	stp->st_stateowner = nfs4_get_stateowner(&lo->lo_owner);
 	get_nfs4_file(fp);
 	stp->st_stid.sc_file = fp;
-	stp->st_stid.sc_free = nfs4_free_lock_stateid;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = open_stp->st_deny_bmap;
 	stp->st_openstp = open_stp;
@@ -5623,7 +5620,7 @@ find_or_create_lock_stateid(struct nfs4_lockowner *lo, struct nfs4_file *fi,
 	lst = find_lock_stateid(lo, fi);
 	if (lst == NULL) {
 		spin_unlock(&clp->cl_lock);
-		ns = nfs4_alloc_stid(clp, stateid_slab);
+		ns = nfs4_alloc_stid(clp, stateid_slab, nfs4_free_lock_stateid);
 		if (ns == NULL)
 			return NULL;
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index c939936..4516e8b 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -603,8 +603,8 @@ extern __be32 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     stateid_t *stateid, unsigned char typemask,
 		     struct nfs4_stid **s, struct nfsd_net *nn);
-struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl,
-		struct kmem_cache *slab);
+struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab,
+				  void (*sc_free)(struct nfs4_stid *));
 void nfs4_unhash_stid(struct nfs4_stid *s);
 void nfs4_put_stid(struct nfs4_stid *s);
 void nfs4_inc_and_copy_stateid(stateid_t *dst, struct nfs4_stid *stid);
-- 
2.9.3

