Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:14282 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755269Ab2KMPrL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Nov 2012 10:47:11 -0500
Subject: [PATCH 13/15] nfsd: use service net instead of hard-coded init_net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 13 Nov 2012 18:49:24 +0300
Message-ID: <20121113154924.12577.54489.stgit@localhost.localdomain>
In-Reply-To: <20121113154722.12577.57671.stgit@localhost.localdomain>
References: <20121113154722.12577.57671.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces init_net by SVC_NET(), where possible and also passes
proper context to nested functions where required.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfs4proc.c  |   13 +++++++----
 fs/nfsd/nfs4state.c |   63 +++++++++++++++++++++++++++++++--------------------
 fs/nfsd/state.h     |    2 +-
 fs/nfsd/xdr4.h      |    2 +-
 4 files changed, 49 insertions(+), 31 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index f955176..1d2396b 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -40,6 +40,7 @@
 #include "xdr4.h"
 #include "vfs.h"
 #include "current_stateid.h"
+#include "netns.h"
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
@@ -304,6 +305,8 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	__be32 status;
 	struct nfsd4_compoundres *resp;
+	struct net *net = SVC_NET(rqstp);
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	dprintk("NFSD: nfsd4_open filename %.*s op_openowner %p\n",
 		(int)open->op_fname.len, open->op_fname.data,
@@ -331,7 +334,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	/* check seqid for replay. set nfs4_owner */
 	resp = rqstp->rq_resp;
-	status = nfsd4_process_open1(&resp->cstate, open);
+	status = nfsd4_process_open1(&resp->cstate, open, nn);
 	if (status == nfserr_replay_me) {
 		struct nfs4_replay *rp = &open->op_openowner->oo_owner.so_replay;
 		fh_put(&cstate->current_fh);
@@ -354,10 +357,10 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	/* Openowner is now set, so sequence id will get bumped.  Now we need
 	 * these checks before we do any creates: */
 	status = nfserr_grace;
-	if (locks_in_grace(SVC_NET(rqstp)) && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
+	if (locks_in_grace(net) && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
 		goto out;
 	status = nfserr_no_grace;
-	if (!locks_in_grace(SVC_NET(rqstp)) && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
+	if (!locks_in_grace(net) && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
 		goto out;
 
 	switch (open->op_claim_type) {
@@ -370,7 +373,9 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			break;
 		case NFS4_OPEN_CLAIM_PREVIOUS:
 			open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
-			status = nfs4_check_open_reclaim(&open->op_clientid, cstate->minorversion);
+			status = nfs4_check_open_reclaim(&open->op_clientid,
+							 cstate->minorversion,
+							 nn);
 			if (status)
 				goto out;
 		case NFS4_OPEN_CLAIM_FH:
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d55136e..1382ef0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2601,14 +2601,13 @@ static __be32 nfsd4_check_seqid(struct nfsd4_compound_state *cstate, struct nfs4
 
 __be32
 nfsd4_process_open1(struct nfsd4_compound_state *cstate,
-		    struct nfsd4_open *open)
+		    struct nfsd4_open *open, struct nfsd_net *nn)
 {
 	clientid_t *clientid = &open->op_clientid;
 	struct nfs4_client *clp = NULL;
 	unsigned int strhashval;
 	struct nfs4_openowner *oo = NULL;
 	__be32 status;
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
 
 	if (STALE_CLIENTID(&open->op_clientid, nn))
 		return nfserr_stale_clientid;
@@ -3389,10 +3388,11 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	return nfs_ok;
 }
 
-static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask, struct nfs4_stid **s, bool sessions)
+static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
+				   struct nfs4_stid **s, bool sessions,
+				   struct nfsd_net *nn)
 {
 	struct nfs4_client *cl;
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
 
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return nfserr_bad_stateid;
@@ -3420,6 +3420,7 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 	struct nfs4_delegation *dp = NULL;
 	struct svc_fh *current_fh = &cstate->current_fh;
 	struct inode *ino = current_fh->fh_dentry->d_inode;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 	__be32 status;
 
 	if (filpp)
@@ -3431,7 +3432,8 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return check_special_stateids(net, current_fh, stateid, flags);
 
-	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID, &s, cstate->minorversion);
+	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
+				      &s, cstate->minorversion, nn);
 	if (status)
 		return status;
 	status = check_stateid_generation(stateid, &s->sc_stateid, nfsd4_has_session(cstate));
@@ -3572,7 +3574,8 @@ static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_
 static __be32
 nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 			 stateid_t *stateid, char typemask,
-			 struct nfs4_ol_stateid **stpp)
+			 struct nfs4_ol_stateid **stpp,
+			 struct nfsd_net *nn)
 {
 	__be32 status;
 	struct nfs4_stid *s;
@@ -3581,7 +3584,8 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		seqid, STATEID_VAL(stateid));
 
 	*stpp = NULL;
-	status = nfsd4_lookup_stateid(stateid, typemask, &s, cstate->minorversion);
+	status = nfsd4_lookup_stateid(stateid, typemask, &s,
+				      cstate->minorversion, nn);
 	if (status)
 		return status;
 	*stpp = openlockstateid(s);
@@ -3590,13 +3594,14 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	return nfs4_seqid_op_checks(cstate, stateid, seqid, *stpp);
 }
 
-static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid, stateid_t *stateid, struct nfs4_ol_stateid **stpp)
+static __be32 nfs4_preprocess_confirmed_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
+						 stateid_t *stateid, struct nfs4_ol_stateid **stpp, struct nfsd_net *nn)
 {
 	__be32 status;
 	struct nfs4_openowner *oo;
 
 	status = nfs4_preprocess_seqid_op(cstate, seqid, stateid,
-						NFS4_OPEN_STID, stpp);
+						NFS4_OPEN_STID, stpp, nn);
 	if (status)
 		return status;
 	oo = openowner((*stpp)->st_stateowner);
@@ -3612,6 +3617,7 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status;
 	struct nfs4_openowner *oo;
 	struct nfs4_ol_stateid *stp;
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	dprintk("NFSD: nfsd4_open_confirm on file %.*s\n",
 			(int)cstate->current_fh.fh_dentry->d_name.len,
@@ -3625,7 +3631,7 @@ nfsd4_open_confirm(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	status = nfs4_preprocess_seqid_op(cstate,
 					oc->oc_seqid, &oc->oc_req_stateid,
-					NFS4_OPEN_STID, &stp);
+					NFS4_OPEN_STID, &stp, nn);
 	if (status)
 		goto out;
 	oo = openowner(stp->st_stateowner);
@@ -3689,6 +3695,7 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 {
 	__be32 status;
 	struct nfs4_ol_stateid *stp;
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	dprintk("NFSD: nfsd4_open_downgrade on file %.*s\n", 
 			(int)cstate->current_fh.fh_dentry->d_name.len,
@@ -3701,7 +3708,7 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 
 	nfs4_lock_state();
 	status = nfs4_preprocess_confirmed_seqid_op(cstate, od->od_seqid,
-					&od->od_stateid, &stp);
+					&od->od_stateid, &stp, nn);
 	if (status)
 		goto out; 
 	status = nfserr_inval;
@@ -3764,6 +3771,8 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	__be32 status;
 	struct nfs4_openowner *oo;
 	struct nfs4_ol_stateid *stp;
+	struct net *net = SVC_NET(rqstp);
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	dprintk("NFSD: nfsd4_close on file %.*s\n", 
 			(int)cstate->current_fh.fh_dentry->d_name.len,
@@ -3773,7 +3782,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	status = nfs4_preprocess_seqid_op(cstate, close->cl_seqid,
 					&close->cl_stateid,
 					NFS4_OPEN_STID|NFS4_CLOSED_STID,
-					&stp);
+					&stp, nn);
 	if (status)
 		goto out; 
 	oo = openowner(stp->st_stateowner);
@@ -3812,12 +3821,14 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	stateid_t *stateid = &dr->dr_stateid;
 	struct nfs4_stid *s;
 	__be32 status;
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)))
 		return status;
 
 	nfs4_lock_state();
-	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID, &s, cstate->minorversion);
+	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID, &s,
+				      cstate->minorversion, nn);
 	if (status)
 		goto out;
 	dp = delegstateid(s);
@@ -4066,7 +4077,8 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	bool new_state = false;
 	int lkflg;
 	int err;
-	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	struct net *net = SVC_NET(rqstp);
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	dprintk("NFSD: nfsd4_lock: start=%Ld length=%Ld\n",
 		(long long) lock->lk_offset,
@@ -4100,7 +4112,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfs4_preprocess_confirmed_seqid_op(cstate,
 				        lock->lk_new_open_seqid,
 		                        &lock->lk_new_open_stateid,
-					&open_stp);
+					&open_stp, nn);
 		if (status)
 			goto out;
 		open_sop = openowner(open_stp->st_stateowner);
@@ -4114,7 +4126,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		status = nfs4_preprocess_seqid_op(cstate,
 				       lock->lk_old_lock_seqid,
 				       &lock->lk_old_lock_stateid,
-				       NFS4_LOCK_STID, &lock_stp);
+				       NFS4_LOCK_STID, &lock_stp, nn);
 	if (status)
 		goto out;
 	lock_sop = lockowner(lock_stp->st_stateowner);
@@ -4125,10 +4137,10 @@ nfsd4_lock(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 
 	status = nfserr_grace;
-	if (locks_in_grace(SVC_NET(rqstp)) && !lock->lk_reclaim)
+	if (locks_in_grace(net) && !lock->lk_reclaim)
 		goto out;
 	status = nfserr_no_grace;
-	if (!locks_in_grace(SVC_NET(rqstp)) && lock->lk_reclaim)
+	if (!locks_in_grace(net) && lock->lk_reclaim)
 		goto out;
 
 	file_lock = locks_alloc_lock();
@@ -4314,7 +4326,8 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct file_lock *file_lock = NULL;
 	__be32 status;
 	int err;
-						        
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+
 	dprintk("NFSD: nfsd4_locku: start=%Ld length=%Ld\n",
 		(long long) locku->lu_offset,
 		(long long) locku->lu_length);
@@ -4325,7 +4338,8 @@ nfsd4_locku(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 									        
 	status = nfs4_preprocess_seqid_op(cstate, locku->lu_seqid,
-					&locku->lu_stateid, NFS4_LOCK_STID, &stp);
+					&locku->lu_stateid, NFS4_LOCK_STID,
+					&stp, nn);
 	if (status)
 		goto out;
 	filp = find_any_file(stp->st_file);
@@ -4546,10 +4560,9 @@ nfsd4_find_reclaim_client(struct nfs4_client *clp)
 * Called from OPEN. Look for clientid in reclaim list.
 */
 __be32
-nfs4_check_open_reclaim(clientid_t *clid, bool sessions)
+nfs4_check_open_reclaim(clientid_t *clid, bool sessions, struct nfsd_net *nn)
 {
 	struct nfs4_client *clp;
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
 
 	/* find clientid in conf_id_hashtbl */
 	clp = find_confirmed_client(clid, sessions, nn);
@@ -4565,7 +4578,7 @@ void nfsd_forget_clients(u64 num)
 {
 	struct nfs4_client *clp, *next;
 	int count = 0;
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
 
 	nfs4_lock_state();
 	list_for_each_entry_safe(clp, next, &nn->client_lru, cl_lru) {
@@ -4885,8 +4898,8 @@ __nfs4_state_shutdown(struct net *net)
 		unhash_delegation(dp);
 	}
 
-	nfsd4_client_tracking_exit(&init_net);
-	put_net(&init_net);
+	nfsd4_client_tracking_exit(net);
+	put_net(net);
 }
 
 void
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f350805..739b851 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -468,7 +468,7 @@ extern void nfs4_unlock_state(void);
 extern int nfs4_in_grace(void);
 extern void nfs4_release_reclaim(struct net *net);
 extern struct nfs4_client_reclaim *nfsd4_find_reclaim_client(struct nfs4_client *crp);
-extern __be32 nfs4_check_open_reclaim(clientid_t *clid, bool sessions);
+extern __be32 nfs4_check_open_reclaim(clientid_t *clid, bool sessions, struct nfsd_net *nn);
 extern void nfs4_free_openowner(struct nfs4_openowner *);
 extern void nfs4_free_lockowner(struct nfs4_lockowner *);
 extern int set_callback_cred(void);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 71c5c47..3c414c1 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -581,7 +581,7 @@ extern __be32 nfsd4_destroy_session(struct svc_rqst *,
 extern __be32 nfsd4_destroy_clientid(struct svc_rqst *, struct nfsd4_compound_state *, struct nfsd4_destroy_clientid *);
 __be32 nfsd4_reclaim_complete(struct svc_rqst *, struct nfsd4_compound_state *, struct nfsd4_reclaim_complete *);
 extern __be32 nfsd4_process_open1(struct nfsd4_compound_state *,
-		struct nfsd4_open *open);
+		struct nfsd4_open *open, struct nfsd_net *nn);
 extern __be32 nfsd4_process_open2(struct svc_rqst *rqstp,
 		struct svc_fh *current_fh, struct nfsd4_open *open);
 extern void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status);

