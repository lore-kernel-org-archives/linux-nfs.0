Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60191 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932251Ab1INLp3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Sep 2011 07:45:29 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 22/25] nfsd4: hash deleg stateid's like any other
Date: Wed, 14 Sep 2011 07:45:18 -0400
Message-Id: <1316000721-3289-23-git-send-email-bfields@redhat.com>
In-Reply-To: <1316000721-3289-1-git-send-email-bfields@redhat.com>
References: <1316000721-3289-1-git-send-email-bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

It's simpler to look up delegation stateid's in the same hash table as
any other stateid.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |  112 +++++++++++++++++++++------------------------------
 fs/nfsd/state.h     |    5 ++
 2 files changed, 51 insertions(+), 66 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 581a5d0..24685a0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -60,8 +60,6 @@ static u64 current_sessionid = 1;
 #define ONE_STATEID(stateid)  (!memcmp((stateid), &onestateid, sizeof(stateid_t)))
 
 /* forward declarations */
-static struct nfs4_delegation * search_for_delegation(stateid_t *stid);
-static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, stateid_t *stid);
 static int check_for_locks(struct nfs4_file *filp, struct nfs4_lockowner *lowner);
 
 /* Locking: */
@@ -256,10 +254,12 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	get_nfs4_file(fp);
 	dp->dl_file = fp;
 	dp->dl_type = type;
+	dp->dl_stid.sc_type = NFS4_DELEG_STID;
 	dp->dl_stid.sc_stateid.si_boot = boot_time;
 	dp->dl_stid.sc_stateid.si_stateownerid = current_delegid++;
 	dp->dl_stid.sc_stateid.si_fileid = 0;
 	dp->dl_stid.sc_stateid.si_generation = 1;
+	hash_stid(&dp->dl_stid);
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	dp->dl_time = 0;
 	atomic_set(&dp->dl_count, 1);
@@ -292,6 +292,7 @@ static void nfs4_put_deleg_lease(struct nfs4_file *fp)
 static void
 unhash_delegation(struct nfs4_delegation *dp)
 {
+	list_del_init(&dp->dl_stid.sc_hash);
 	list_del_init(&dp->dl_perclnt);
 	spin_lock(&recall_lock);
 	list_del_init(&dp->dl_perfile);
@@ -1077,7 +1078,7 @@ same_stateid(stateid_t *id_one, stateid_t *id_two)
 	return id_one->si_fileid == id_two->si_fileid;
 }
 
-static struct nfs4_ol_stateid *find_stateid(stateid_t *t)
+static struct nfs4_stid *find_stateid(stateid_t *t)
 {
 	struct nfs4_stid *s;
 	unsigned int hashval;
@@ -1085,22 +1086,42 @@ static struct nfs4_ol_stateid *find_stateid(stateid_t *t)
 	hashval = stateid_hashval(t->si_stateownerid, t->si_fileid);
 	list_for_each_entry(s, &stateid_hashtbl[hashval], sc_hash)
 		if (same_stateid(&s->sc_stateid, t))
-			return openlockstateid(s);
+			return s;
 	return NULL;
 }
 
-static struct nfs4_ol_stateid *find_stateid_by_type(stateid_t *t, char typemask)
+static struct nfs4_ol_stateid *find_ol_stateid(stateid_t *t)
 {
-	struct nfs4_ol_stateid *s;
+	struct nfs4_stid *s;
+
+	s = find_stateid(t);
+	if (!s)
+		return NULL;
+	return openlockstateid(s);
+}
+
+static struct nfs4_stid *find_stateid_by_type(stateid_t *t, char typemask)
+{
+	struct nfs4_stid *s;
 
 	s = find_stateid(t);
 	if (!s)
 		return NULL;
-	if (typemask & s->st_stid.sc_type)
+	if (typemask & s->sc_type)
 		return s;
 	return NULL;
 }
 
+static struct nfs4_ol_stateid *find_ol_stateid_by_type(stateid_t *t, char typemask)
+{
+	struct nfs4_stid *s;
+
+	s = find_stateid_by_type(t, typemask);
+	if (!s)
+		return NULL;
+	return openlockstateid(s);
+}
+
 static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 		struct svc_rqst *rqstp, nfs4_verifier *verf)
 {
@@ -2573,26 +2594,21 @@ nfs4_check_delegmode(struct nfs4_delegation *dp, int flags)
 		return nfs_ok;
 }
 
-static struct nfs4_delegation *
-find_delegation_file(struct nfs4_file *fp, stateid_t *stid)
+static int share_access_to_flags(u32 share_access)
 {
-	struct nfs4_delegation *dp;
+	share_access &= ~NFS4_SHARE_WANT_MASK;
 
-	spin_lock(&recall_lock);
-	list_for_each_entry(dp, &fp->fi_delegations, dl_perfile)
-		if (dp->dl_stid.sc_stateid.si_stateownerid == stid->si_stateownerid) {
-			spin_unlock(&recall_lock);
-			return dp;
-		}
-	spin_unlock(&recall_lock);
-	return NULL;
+	return share_access == NFS4_SHARE_ACCESS_READ ? RD_STATE : WR_STATE;
 }
 
-static int share_access_to_flags(u32 share_access)
+static struct nfs4_delegation *find_deleg_stateid(stateid_t *s)
 {
-	share_access &= ~NFS4_SHARE_WANT_MASK;
+	struct nfs4_stid *ret;
 
-	return share_access == NFS4_SHARE_ACCESS_READ ? RD_STATE : WR_STATE;
+	ret = find_stateid_by_type(s, NFS4_DELEG_STID);
+	if (!ret)
+		return NULL;
+	return delegstateid(ret);
 }
 
 static __be32
@@ -2602,7 +2618,7 @@ nfs4_check_deleg(struct nfs4_file *fp, struct nfsd4_open *open,
 	int flags;
 	__be32 status = nfserr_bad_stateid;
 
-	*dp = find_delegation_file(fp, &open->op_delegate_stateid);
+	*dp = find_deleg_stateid(&open->op_delegate_stateid);
 	if (*dp == NULL)
 		goto out;
 	flags = share_access_to_flags(open->op_share_access);
@@ -3252,7 +3268,7 @@ __be32 nfs4_validate_stateid(stateid_t *stateid, bool has_session)
 		goto out;
 
 	status = nfserr_expired;
-	stp = find_stateid(stateid);
+	stp = find_ol_stateid(stateid);
 	if (!stp)
 		goto out;
 	status = nfserr_bad_stateid;
@@ -3301,7 +3317,7 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 	 */
 	status = nfserr_expired;
 	if (is_delegation_stateid(stateid)) {
-		dp = find_delegation_stateid(ino, stateid);
+		dp = find_deleg_stateid(stateid);
 		if (!dp)
 			goto out;
 		status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
@@ -3316,7 +3332,7 @@ nfs4_preprocess_stateid_op(struct nfsd4_compound_state *cstate,
 			BUG_ON(!*filpp);
 		}
 	} else { /* open or lock stateid */
-		stp = find_stateid(stateid);
+		stp = find_ol_stateid(stateid);
 		if (!stp)
 			goto out;
 		status = nfserr_bad_stateid;
@@ -3348,9 +3364,10 @@ out:
 static __be32
 nfsd4_free_delegation_stateid(stateid_t *stateid)
 {
-	struct nfs4_delegation *dp = search_for_delegation(stateid);
+	struct nfs4_delegation *dp = find_deleg_stateid(stateid);
 	if (dp)
 		return nfserr_locks_held;
+
 	return nfserr_bad_stateid;
 }
 
@@ -3391,7 +3408,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	}
 
-	stp = find_stateid(stateid);
+	stp = find_ol_stateid(stateid);
 	if (!stp) {
 		ret = nfserr_bad_stateid;
 		goto out;
@@ -3460,7 +3477,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	status = nfs4_nospecial_stateid_checks(stateid);
 	if (status)
 		return status;
-	*stpp = find_stateid_by_type(stateid, typemask);
+	*stpp = find_ol_stateid_by_type(stateid, typemask);
 	if (*stpp == NULL)
 		return nfserr_expired;
 	cstate->replay_owner = (*stpp)->st_stateowner;
@@ -3672,7 +3689,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (!is_delegation_stateid(stateid))
 		goto out;
 	status = nfserr_expired;
-	dp = find_delegation_stateid(inode, stateid);
+	dp = find_deleg_stateid(stateid);
 	if (!dp)
 		goto out;
 	status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
@@ -3733,43 +3750,6 @@ lock_ownerstr_hashval(struct inode *inode, u32 cl_id,
 static struct list_head lock_ownerid_hashtbl[LOCK_HASH_SIZE];
 static struct list_head	lock_ownerstr_hashtbl[LOCK_HASH_SIZE];
 
-static struct nfs4_delegation *
-search_for_delegation(stateid_t *stid)
-{
-	struct nfs4_file *fp;
-	struct nfs4_delegation *dp;
-	struct list_head *pos;
-	int i;
-
-	for (i = 0; i < FILE_HASH_SIZE; i++) {
-		list_for_each_entry(fp, &file_hashtbl[i], fi_hash) {
-			list_for_each(pos, &fp->fi_delegations) {
-				dp = list_entry(pos, struct nfs4_delegation, dl_perfile);
-				if (same_stateid(&dp->dl_stid.sc_stateid, stid))
-					return dp;
-			}
-		}
-	}
-	return NULL;
-}
-
-static struct nfs4_delegation *
-find_delegation_stateid(struct inode *ino, stateid_t *stid)
-{
-	struct nfs4_file *fp;
-	struct nfs4_delegation *dl;
-
-	dprintk("NFSD: %s: stateid=" STATEID_FMT "\n", __func__,
-		STATEID_VAL(stid));
-
-	fp = find_file(ino);
-	if (!fp)
-		return NULL;
-	dl = find_delegation_file(fp, stid);
-	put_nfs4_file(fp);
-	return dl;
-}
-
 /*
  * TODO: Linux file offsets are _signed_ 64-bit quantities, which means that
  * we can't properly handle lock requests that go beyond the (2^63 - 1)-th
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index e3ff7c9..12c1424 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -113,6 +113,11 @@ struct nfs4_cb_conn {
 	struct svc_xprt		*cb_xprt;	/* minorversion 1 only */
 };
 
+static inline struct nfs4_delegation *delegstateid(struct nfs4_stid *s)
+{
+	return container_of(s, struct nfs4_delegation, dl_stid);
+}
+
 /* Maximum number of slots per session. 160 is useful for long haul TCP */
 #define NFSD_MAX_SLOTS_PER_SESSION     160
 /* Maximum number of operations per session compound */
-- 
1.7.4.1

