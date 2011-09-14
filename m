Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60153 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932144Ab1INLp1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:27 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 05/25] nfsd4: drop most stateowner refcounting
Date: Wed, 14 Sep 2011 07:45:01 -0400
Message-Id: <1316000721-3289-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Maybe we'll bring it back some day, but we don't have much real use for
it now.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4proc.c  |    6 ++----
 fs/nfsd/nfs4state.c |   23 ++++++++++++-----------
 fs/nfsd/nfs4xdr.c   |   11 ++++++-----
 fs/nfsd/state.h     |   15 +--------------
 fs/nfsd/xdr4.h      |    2 +-
 5 files changed, 22 insertions(+), 35 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 50063a8..ce151f0 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -405,10 +405,9 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	 */
 	status = nfsd4_process_open2(rqstp, &cstate->current_fh, open);
 out:
-	if (open->op_stateowner) {
-		nfs4_get_stateowner(open->op_stateowner);
+	if (open->op_stateowner)
 		cstate->replay_owner = open->op_stateowner;
-	} else
+	else
 		nfs4_unlock_state();
 	return status;
 }
@@ -1228,7 +1227,6 @@ encode_op:
 
 		if (cstate->replay_owner) {
 			nfs4_unlock_state();
-			nfs4_put_stateowner(cstate->replay_owner);
 			cstate->replay_owner = NULL;
 		}
 		/* XXX Ugh, we need to get rid of this kind of special case: */
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 26b0c75..834a5f8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -453,7 +453,7 @@ static void unhash_lockowner(struct nfs4_stateowner *sop)
 static void release_lockowner(struct nfs4_stateowner *sop)
 {
 	unhash_lockowner(sop);
-	nfs4_put_stateowner(sop);
+	nfs4_free_stateowner(sop);
 }
 
 static void
@@ -496,7 +496,7 @@ static void release_openowner(struct nfs4_stateowner *sop)
 {
 	unhash_openowner(sop);
 	list_del(&sop->so_close_lru);
-	nfs4_put_stateowner(sop);
+	nfs4_free_stateowner(sop);
 }
 
 #define SESSION_HASH_SIZE	512
@@ -2206,10 +2206,8 @@ out_nomem:
 }
 
 void
-nfs4_free_stateowner(struct kref *kref)
+nfs4_free_stateowner(struct nfs4_stateowner *sop)
 {
-	struct nfs4_stateowner *sop =
-		container_of(kref, struct nfs4_stateowner, so_ref);
 	kfree(sop->so_owner.data);
 	kmem_cache_free(stateowner_slab, sop);
 }
@@ -2236,7 +2234,6 @@ static inline struct nfs4_stateowner *alloc_stateowner(struct xdr_netobj *owner,
 	}
 	sop->so_owner.len = owner->len;
 
-	kref_init(&sop->so_ref);
 	INIT_LIST_HEAD(&sop->so_perclient);
 	INIT_LIST_HEAD(&sop->so_stateids);
 	INIT_LIST_HEAD(&sop->so_perstateid);
@@ -3413,14 +3410,12 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		/* It's not stale; let's assume it's expired: */
 		if (sop == NULL)
 			return nfserr_expired;
-		nfs4_get_stateowner(sop);
 		cstate->replay_owner = sop;
 		goto check_replay;
 	}
 
 	*stpp = stp;
 	sop = stp->st_stateowner;
-	nfs4_get_stateowner(sop);
 	cstate->replay_owner = sop;
 
 	if (nfs4_check_fh(current_fh, stp)) {
@@ -3783,11 +3778,17 @@ nfs4_set_lock_denied(struct file_lock *fl, struct nfsd4_lock_denied *deny)
 
 	if (fl->fl_lmops == &nfsd_posix_mng_ops) {
 		sop = (struct nfs4_stateowner *) fl->fl_owner;
-		kref_get(&sop->so_ref);
-		deny->ld_sop = sop;
+		deny->ld_owner.data = kmemdup(sop->so_owner.data,
+					sop->so_owner.len, GFP_KERNEL);
+		if (!deny->ld_owner.data)
+			/* We just don't care that much */
+			goto nevermind;
+		deny->ld_owner.len = sop->so_owner.len;
 		deny->ld_clientid = sop->so_client->cl_clientid;
 	} else {
-		deny->ld_sop = NULL;
+nevermind:
+		deny->ld_owner.len = 0;
+		deny->ld_owner.data = NULL;
 		deny->ld_clientid.cl_boot = 0;
 		deny->ld_clientid.cl_id = 0;
 	}
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 462c6ef..c4dcba3 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2570,17 +2570,18 @@ nfsd4_encode_getfh(struct nfsd4_compoundres *resp, __be32 nfserr, struct svc_fh
 static void
 nfsd4_encode_lock_denied(struct nfsd4_compoundres *resp, struct nfsd4_lock_denied *ld)
 {
+	struct xdr_netobj *conf = &ld->ld_owner;
 	__be32 *p;
 
-	RESERVE_SPACE(32 + XDR_LEN(ld->ld_sop ? ld->ld_sop->so_owner.len : 0));
+	RESERVE_SPACE(32 + XDR_LEN(conf->len));
 	WRITE64(ld->ld_start);
 	WRITE64(ld->ld_length);
 	WRITE32(ld->ld_type);
-	if (ld->ld_sop) {
+	if (conf->len) {
 		WRITEMEM(&ld->ld_clientid, 8);
-		WRITE32(ld->ld_sop->so_owner.len);
-		WRITEMEM(ld->ld_sop->so_owner.data, ld->ld_sop->so_owner.len);
-		kref_put(&ld->ld_sop->so_ref, nfs4_free_stateowner);
+		WRITE32(conf->len);
+		WRITEMEM(conf->data, conf->len);
+		kfree(conf->data);
 	}  else {  /* non - nfsv4 lock in conflict, no clientid nor owner */
 		WRITE64((u64)0); /* clientid */
 		WRITE32(0); /* length of owner name */
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index c425717..f7114fc2 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -338,7 +338,6 @@ struct nfs4_replay {
 *         reaped by laundramat thread after lease period.
 */
 struct nfs4_stateowner {
-	struct kref		so_ref;
 	struct list_head        so_idhash;   /* hash by so_id */
 	struct list_head        so_strhash;   /* hash by op_name */
 	struct list_head        so_perclient;
@@ -459,7 +458,7 @@ extern void nfs4_lock_state(void);
 extern void nfs4_unlock_state(void);
 extern int nfs4_in_grace(void);
 extern __be32 nfs4_check_open_reclaim(clientid_t *clid);
-extern void nfs4_free_stateowner(struct kref *kref);
+extern void nfs4_free_stateowner(struct nfs4_stateowner *sop);
 extern int set_callback_cred(void);
 extern void nfsd4_probe_callback(struct nfs4_client *clp);
 extern void nfsd4_probe_callback_sync(struct nfs4_client *clp);
@@ -482,16 +481,4 @@ extern void nfsd4_remove_clid_dir(struct nfs4_client *clp);
 extern void release_session_client(struct nfsd4_session *);
 extern __be32 nfs4_validate_stateid(stateid_t *, bool);
 
-static inline void
-nfs4_put_stateowner(struct nfs4_stateowner *so)
-{
-	kref_put(&so->so_ref, nfs4_free_stateowner);
-}
-
-static inline void
-nfs4_get_stateowner(struct nfs4_stateowner *so)
-{
-	kref_get(&so->so_ref);
-}
-
 #endif   /* NFSD4_STATE_H */
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 341f0a1..de236fb 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -130,7 +130,7 @@ struct nfsd4_link {
 
 struct nfsd4_lock_denied {
 	clientid_t	ld_clientid;
-	struct nfs4_stateowner   *ld_sop;
+	struct xdr_netobj	ld_owner;
 	u64             ld_start;
 	u64             ld_length;
 	u32             ld_type;
-- 
1.7.4.1

