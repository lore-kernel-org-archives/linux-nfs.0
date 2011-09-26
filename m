Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48602 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752494Ab1IZWjp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 18:39:45 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/4] nfsd4: look up stateid's per clientid
Date: Mon, 26 Sep 2011 18:39:40 -0400
Message-Id: <1317076780-22309-4-git-send-email-bfields@redhat.com>
In-Reply-To: <20110926223722.GB22140@fieldses.org>
References: <20110926223722.GB22140@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Use a separate stateid idr per client, and lookup a stateid by first
finding the client, then looking up the stateid relative to that client.

Also some minor refactoring.

This allows us to improve error returns: we can return expired when the
clientid is not found and bad_stateid when the clientid is found but not
the stateid, as opposed to returning expired for both cases.

I hope this will also help to replace the state lock mostly by a
per-client lock, but that hasn't been done yet.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |  112 ++++++++++++++++++++++----------------------------
 fs/nfsd/nfs4xdr.c   |    3 +-
 fs/nfsd/state.h     |    4 +-
 3 files changed, 54 insertions(+), 65 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index daf75fa..931155f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -32,7 +32,6 @@
 *
 */
 
-#include <linux/idr.h>
 #include <linux/file.h>
 #include <linux/fs.h>
 #include <linux/slab.h>
@@ -149,8 +148,6 @@ static struct list_head	open_ownerstr_hashtbl[OPEN_OWNER_HASH_SIZE];
 #define FILE_HASH_BITS                   8
 #define FILE_HASH_SIZE                  (1 << FILE_HASH_BITS)
 
-struct idr stateids;
-
 static unsigned int file_hashval(struct inode *ino)
 {
 	/* XXX: why are we hashing on inode pointer, anyway? */
@@ -209,13 +206,14 @@ static void nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 static inline int get_new_stid(struct nfs4_stid *stid)
 {
 	static int min_stateid = 0;
+	struct idr *stateids = &stid->sc_client->cl_stateids;
 	int new_stid;
 	int error;
 
-	if (!idr_pre_get(&stateids, GFP_KERNEL))
+	if (!idr_pre_get(stateids, GFP_KERNEL))
 		return -ENOMEM;
 
-	error = idr_get_new_above(&stateids, stid, min_stateid, &new_stid);
+	error = idr_get_new_above(stateids, stid, min_stateid, &new_stid);
 	/*
 	 * All this code is currently serialized; the preallocation
 	 * above should still be ours:
@@ -324,7 +322,9 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 
 static void unhash_stid(struct nfs4_stid *s)
 {
-	idr_remove(&stateids, s->sc_stateid.si_opaque.so_id);
+	struct idr *stateids = &s->sc_client->cl_stateids;
+
+	idr_remove(stateids, s->sc_stateid.si_opaque.so_id);
 }
 
 /* Called under the state lock. */
@@ -1126,16 +1126,16 @@ static void gen_confirm(struct nfs4_client *clp)
 	*p++ = i++;
 }
 
-static struct nfs4_stid *find_stateid(stateid_t *t)
+static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
 {
-	return idr_find(&stateids, t->si_opaque.so_id);
+	return idr_find(&cl->cl_stateids, t->si_opaque.so_id);
 }
 
-static struct nfs4_stid *find_stateid_by_type(stateid_t *t, char typemask)
+static struct nfs4_stid *find_stateid_by_type(struct nfs4_client *cl, stateid_t *t, char typemask)
 {
 	struct nfs4_stid *s;
 
-	s = find_stateid(t);
+	s = find_stateid(cl, t);
 	if (!s)
 		return NULL;
 	if (typemask & s->sc_type)
@@ -1143,16 +1143,6 @@ static struct nfs4_stid *find_stateid_by_type(stateid_t *t, char typemask)
 	return NULL;
 }
 
-static struct nfs4_ol_stateid *find_ol_stateid_by_type(stateid_t *t, char typemask)
-{
-	struct nfs4_stid *s;
-
-	s = find_stateid_by_type(t, typemask);
-	if (!s)
-		return NULL;
-	return openlockstateid(s);
-}
-
 static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 		struct svc_rqst *rqstp, nfs4_verifier *verf)
 {
@@ -1175,6 +1165,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 		}
 	}
 
+	idr_init(&clp->cl_stateids);
 	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
 	atomic_set(&clp->cl_refcount, 0);
 	clp->cl_cb_state = NFSD4_CB_UNKNOWN;
@@ -2611,24 +2602,24 @@ static int share_access_to_flags(u32 share_access)
 	return share_access == NFS4_SHARE_ACCESS_READ ? RD_STATE : WR_STATE;
 }
 
-static struct nfs4_delegation *find_deleg_stateid(stateid_t *s)
+static struct nfs4_delegation *find_deleg_stateid(struct nfs4_client *cl, stateid_t *s)
 {
 	struct nfs4_stid *ret;
 
-	ret = find_stateid_by_type(s, NFS4_DELEG_STID);
+	ret = find_stateid_by_type(cl, s, NFS4_DELEG_STID);
 	if (!ret)
 		return NULL;
 	return delegstateid(ret);
 }
 
 static __be32
-nfs4_check_deleg(struct nfs4_file *fp, struct nfsd4_open *open,
+nfs4_check_deleg(struct nfs4_client *cl, struct nfs4_file *fp, struct nfsd4_open *open,
 		struct nfs4_delegation **dp)
 {
 	int flags;
 	__be32 status = nfserr_bad_stateid;
 
-	*dp = find_deleg_stateid(&open->op_delegate_stateid);
+	*dp = find_deleg_stateid(cl, &open->op_delegate_stateid);
 	if (*dp == NULL)
 		goto out;
 	flags = share_access_to_flags(open->op_share_access);
@@ -2920,6 +2911,7 @@ __be32
 nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_open *open)
 {
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
+	struct nfs4_client *cl = open->op_openowner->oo_owner.so_client;
 	struct nfs4_file *fp = NULL;
 	struct inode *ino = current_fh->fh_dentry->d_inode;
 	struct nfs4_ol_stateid *stp = NULL;
@@ -2939,7 +2931,7 @@ nfsd4_process_open2(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nf
 	if (fp) {
 		if ((status = nfs4_check_open(fp, open, &stp)))
 			goto out;
-		status = nfs4_check_deleg(fp, open, &dp);
+		status = nfs4_check_deleg(cl, fp, open, &dp);
 		if (status)
 			goto out;
 	} else {
@@ -3256,7 +3248,7 @@ static int check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_sess
 	return nfserr_old_stateid;
 }
 
-__be32 nfs4_validate_stateid(stateid_t *stateid)
+__be32 nfs4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 {
 	struct nfs4_stid *s;
 	struct nfs4_ol_stateid *ols;
@@ -3265,7 +3257,7 @@ __be32 nfs4_validate_stateid(stateid_t *stateid)
 	if (STALE_STATEID(stateid))
 		return nfserr_stale_stateid;
 
-	s = find_stateid(stateid);
+	s = find_stateid(cl, stateid);
 	if (!s)
 		 return nfserr_stale_stateid;
 	status = check_stateid_generation(stateid, &s->sc_stateid, 1);
@@ -3280,6 +3272,24 @@ __be32 nfs4_validate_stateid(stateid_t *stateid)
 	return nfs_ok;
 }
 
+static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask, struct nfs4_stid **s)
+{
+	struct nfs4_client *cl;
+
+	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
+		return nfserr_bad_stateid;
+	if (STALE_STATEID(stateid))
+		return nfserr_stale_stateid;
+	cl = find_confirmed_client(&stateid->si_opaque.so_clid);
+	if (!cl)
+		return nfserr_expired;
+	*s = find_stateid_by_type(cl, stateid, typemask);
+	if (!*s)
+		return nfserr_bad_stateid;
+	return nfs_ok;
+
+}
+
 /*
 * Checks for stateid operations
 */
@@ -3303,18 +3313,9 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return check_special_stateids(current_fh, stateid, flags);
 
-	status = nfserr_stale_stateid;
-	if (STALE_STATEID(stateid)) 
-		goto out;
-
-	/*
-	 * We assume that any stateid that has the current boot time,
-	 * but that we can't find, is expired:
-	 */
-	status = nfserr_expired;
-	s = find_stateid(stateid);
-	if (!s)
-		goto out;
+	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID, &s);
+	if (status)
+		return status;
 	status = check_stateid_generation(stateid, &s->sc_stateid, nfsd4_has_session(cstate));
 	if (status)
 		goto out;
@@ -3384,10 +3385,11 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	stateid_t *stateid = &free_stateid->fr_stateid;
 	struct nfs4_stid *s;
+	struct nfs4_client *cl = cstate->session->se_client;
 	__be32 ret = nfserr_bad_stateid;
 
 	nfs4_lock_state();
-	s = find_stateid(stateid);
+	s = find_stateid(cl, stateid);
 	if (!s)
 		goto out;
 	switch (s->sc_type) {
@@ -3419,15 +3421,6 @@ setlkflg (int type)
 		RD_STATE : WR_STATE;
 }
 
-static __be32 nfs4_nospecial_stateid_checks(stateid_t *stateid)
-{
-	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
-		return nfserr_bad_stateid;
-	if (STALE_STATEID(stateid))
-		return nfserr_stale_stateid;
-	return nfs_ok;
-}
-
 static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_t *stateid, u32 seqid, struct nfs4_ol_stateid *stp)
 {
 	struct svc_fh *current_fh = &cstate->current_fh;
@@ -3458,17 +3451,16 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 			 struct nfs4_ol_stateid **stpp)
 {
 	__be32 status;
+	struct nfs4_stid *s;
 
 	dprintk("NFSD: %s: seqid=%d stateid = " STATEID_FMT "\n", __func__,
 		seqid, STATEID_VAL(stateid));
 
 	*stpp = NULL;
-	status = nfs4_nospecial_stateid_checks(stateid);
+	status = nfsd4_lookup_stateid(stateid, typemask, &s);
 	if (status)
 		return status;
-	*stpp = find_ol_stateid_by_type(stateid, typemask);
-	if (*stpp == NULL)
-		return nfserr_expired;
+	*stpp = openlockstateid(s);
 	cstate->replay_owner = (*stpp)->st_stateowner;
 	renew_client((*stpp)->st_stateowner->so_client);
 
@@ -3673,6 +3665,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	struct nfs4_delegation *dp;
 	stateid_t *stateid = &dr->dr_stateid;
+	struct nfs4_stid *s;
 	struct inode *inode;
 	__be32 status;
 
@@ -3681,16 +3674,10 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	inode = cstate->current_fh.fh_dentry->d_inode;
 
 	nfs4_lock_state();
-	status = nfserr_bad_stateid;
-	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
-		goto out;
-	status = nfserr_stale_stateid;
-	if (STALE_STATEID(stateid))
-		goto out;
-	status = nfserr_expired;
-	dp = find_deleg_stateid(stateid);
-	if (!dp)
+	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID, &s);
+	if (status)
 		goto out;
+	dp = delegstateid(s);
 	status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
 	if (status)
 		goto out;
@@ -4409,7 +4396,6 @@ nfs4_state_init(void)
 	for (i = 0; i < OPEN_OWNER_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&open_ownerstr_hashtbl[i]);
 	}
-	idr_init(&stateids);
 	for (i = 0; i < LOCK_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&lock_ownerstr_hashtbl[i]);
 	}
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2429fff..5779acd 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3287,6 +3287,7 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, int nfserr,
 			  struct nfsd4_test_stateid *test_stateid)
 {
 	struct nfsd4_compoundargs *argp;
+	struct nfs4_client *cl = resp->cstate.session->se_client;
 	stateid_t si;
 	__be32 *p;
 	int i;
@@ -3302,7 +3303,7 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, int nfserr,
 	nfs4_lock_state();
 	for (i = 0; i < test_stateid->ts_num_ids; i++) {
 		nfsd4_decode_stateid(argp, &si);
-		valid = nfs4_validate_stateid(&si);
+		valid = nfs4_validate_stateid(cl, &si);
 		RESERVE_SPACE(4);
 		*p++ = htonl(valid);
 		resp->p = p;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 55a4d6a..13f6f9f 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -35,6 +35,7 @@
 #ifndef _NFSD4_STATE_H
 #define _NFSD4_STATE_H
 
+#include <linux/idr.h>
 #include <linux/sunrpc/svc_xprt.h>
 #include <linux/nfsd/nfsfh.h>
 #include "nfsfh.h"
@@ -231,6 +232,7 @@ struct nfs4_client {
 	struct list_head	cl_idhash; 	/* hash by cl_clientid.id */
 	struct list_head	cl_strhash; 	/* hash by cl_name */
 	struct list_head	cl_openowners;
+	struct idr		cl_stateids;	/* stateid lookup */
 	struct list_head	cl_delegations;
 	struct list_head        cl_lru;         /* tail queue */
 	struct xdr_netobj	cl_name; 	/* id generated by client */
@@ -508,7 +510,7 @@ extern void nfsd4_recdir_purge_old(void);
 extern int nfsd4_create_clid_dir(struct nfs4_client *clp);
 extern void nfsd4_remove_clid_dir(struct nfs4_client *clp);
 extern void release_session_client(struct nfsd4_session *);
-extern __be32 nfs4_validate_stateid(stateid_t *);
+extern __be32 nfs4_validate_stateid(struct nfs4_client *, stateid_t *);
 extern void nfsd4_purge_closed_stateid(struct nfs4_stateowner *);
 
 #endif   /* NFSD4_STATE_H */
-- 
1.7.4.1

