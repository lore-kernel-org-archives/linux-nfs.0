Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from discipline.rit.edu ([129.21.6.207]:60524 "HELO
        discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with SMTP id S1751324AbdJaT3p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Oct 2017 15:29:45 -0400
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org
Cc: Andrew Elble <aweits@rit.edu>
Subject: [PATCH] nfsd: deal with revoked delegations appropriately
Date: Tue, 31 Oct 2017 15:22:38 -0400
Message-Id: <20171031192238.6906-1-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a delegation has been revoked by the server, operations using that
delegation should error out with NFS4ERR_DELEG_REVOKED in the >4.1
case, and NFS4ERR_BAD_STATEID otherwise. DELEGRETURN has also been
optimized to return NFS4_OK when called with a revoked delegation.

Thread on DELEGRETURN optimization is here:
https://www.spinics.net/lists/linux-nfs/msg55216.html

Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfsd/nfs4state.c | 53 +++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 43 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0c04f81aa63b..2545ca69a6b5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3966,7 +3966,8 @@ static struct nfs4_delegation *find_deleg_stateid(struct nfs4_client *cl, statei
 {
 	struct nfs4_stid *ret;
 
-	ret = find_stateid_by_type(cl, s, NFS4_DELEG_STID);
+	ret = find_stateid_by_type(cl, s,
+				NFS4_DELEG_STID|NFS4_REVOKED_DELEG_STID);
 	if (!ret)
 		return NULL;
 	return delegstateid(ret);
@@ -3989,6 +3990,12 @@ nfs4_check_deleg(struct nfs4_client *cl, struct nfsd4_open *open,
 	deleg = find_deleg_stateid(cl, &open->op_delegate_stateid);
 	if (deleg == NULL)
 		goto out;
+	if (deleg->dl_stid.sc_type == NFS4_REVOKED_DELEG_STID) {
+		nfs4_put_stid(&deleg->dl_stid);
+		if (cl->cl_minorversion)
+			status = nfserr_deleg_revoked;
+		goto out;
+	}
 	flags = share_access_to_flags(open->op_share_access);
 	status = nfs4_check_delegmode(deleg, flags);
 	if (status) {
@@ -4858,6 +4865,16 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     struct nfs4_stid **s, struct nfsd_net *nn)
 {
 	__be32 status;
+	bool return_revoked = false;
+
+	/*
+	 *  only return revoked delegations if explicitly asked.
+	 *  otherwise we report revoked or bad_stateid status.
+	 */
+	if (typemask & NFS4_REVOKED_DELEG_STID)
+		return_revoked = true;
+	else if (typemask & NFS4_DELEG_STID)
+		typemask |= NFS4_REVOKED_DELEG_STID;
 
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return nfserr_bad_stateid;
@@ -4872,6 +4889,12 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 	*s = find_stateid_by_type(cstate->clp, stateid, typemask);
 	if (!*s)
 		return nfserr_bad_stateid;
+	if (((*s)->sc_type == NFS4_REVOKED_DELEG_STID) && !return_revoked) {
+		nfs4_put_stid(*s);
+		if (cstate->minorversion)
+			return nfserr_deleg_revoked;
+		return nfserr_bad_stateid;
+	}
 	return nfs_ok;
 }
 
@@ -5106,13 +5129,11 @@ static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_
 	status = nfsd4_check_seqid(cstate, sop, seqid);
 	if (status)
 		return status;
-	if (stp->st_stid.sc_type == NFS4_CLOSED_STID
-		|| stp->st_stid.sc_type == NFS4_REVOKED_DELEG_STID)
-		/*
-		 * "Closed" stateid's exist *only* to return
-		 * nfserr_replay_me from the previous step, and
-		 * revoked delegations are kept only for free_stateid.
-		 */
+	/*
+	 * "Closed" stateid's exist *only* to return
+	 * nfserr_replay_me from the previous step
+	 */
+	if (stp->st_stid.sc_type == NFS4_CLOSED_STID)
 		return nfserr_bad_stateid;
 	mutex_lock(&stp->st_mutex);
 	status = check_stateid_generation(stateid, &stp->st_stid.sc_stateid, nfsd4_has_session(cstate));
@@ -5359,7 +5380,9 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if ((status = fh_verify(rqstp, &cstate->current_fh, S_IFREG, 0)))
 		return status;
 
-	status = nfsd4_lookup_stateid(cstate, stateid, NFS4_DELEG_STID, &s, nn);
+	status = nfsd4_lookup_stateid(cstate, stateid,
+				NFS4_DELEG_STID|NFS4_REVOKED_DELEG_STID,
+				&s, nn);
 	if (status)
 		goto out;
 	dp = delegstateid(s);
@@ -5367,7 +5390,17 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		goto put_stateid;
 
-	destroy_delegation(dp);
+	if (dp->dl_stid.sc_type == NFS4_DELEG_STID)
+		destroy_delegation(dp);
+	if (dp->dl_stid.sc_type == NFS4_REVOKED_DELEG_STID) {
+		/*
+		 * optimization: don't return error if client is
+		 * returning a revoked delegation
+		 */
+		list_del_init(&dp->dl_recall_lru);
+		nfs4_put_stid(s);
+	}
+
 put_stateid:
 	nfs4_put_stid(&dp->dl_stid);
 out:
-- 
2.10.1

