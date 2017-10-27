Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:51884 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751854AbdJ0UZO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Oct 2017 16:25:14 -0400
Received: by mail-io0-f178.google.com with SMTP id b186so15223704iof.8
        for <linux-nfs@vger.kernel.org>; Fri, 27 Oct 2017 13:25:14 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: On CLOSE, the state change needs to be atomic with the seqid bump
Date: Fri, 27 Oct 2017 16:25:09 -0400
Message-Id: <20171027202509.99168-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The various functions that call check_stateid_generation() in order
to compare a client-supplied stateid with the nfs4_stid state, almost
without exception need to check for closed state.

A race now exists whereby the stateid can get bumped in nfsd4_close, but
the actual change in value of st_stid.sc_type is deferred until after
all locks are dropped.
This commit ensures that the state change is logged while the state
mutex is held, but also ensures that is happens before the seqid
is bumped. It also adds locking and checks so that functions that check
the seqid will also see the correct state.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 37 +++++++++++++++++++++++++++++++------
 1 file changed, 31 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0c04f81aa63b..50b3b9870326 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4798,6 +4798,26 @@ static __be32 check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_s
 	return nfserr_old_stateid;
 }
 
+static __be32 nfsd4_stid_check_stateid_generation(stateid_t *in, struct nfs4_stid *s, bool has_session)
+{
+	__be32 ret;
+
+	spin_lock(&s->sc_lock);
+	switch (s->sc_type) {
+	case NFS4_CLOSED_STID:
+	case NFS4_CLOSED_DELEG_STID:
+		ret = nfserr_bad_stateid;
+		break;
+	case NFS4_REVOKED_DELEG_STID:
+		ret = nfserr_deleg_revoked;
+		break;
+	default:
+		ret = check_stateid_generation(in, &s->sc_stateid, has_session);
+	}
+	spin_unlock(&s->sc_lock);
+	return ret;
+}
+
 static __be32 nfsd4_check_openowner_confirmed(struct nfs4_ol_stateid *ols)
 {
 	if (ols->st_stateowner->so_is_open_owner &&
@@ -4826,7 +4846,7 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	s = find_stateid_locked(cl, stateid);
 	if (!s)
 		goto out_unlock;
-	status = check_stateid_generation(stateid, &s->sc_stateid, 1);
+	status = nfsd4_stid_check_stateid_generation(stateid, s, 1);
 	if (status)
 		goto out_unlock;
 	switch (s->sc_type) {
@@ -4971,7 +4991,7 @@ nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 				&s, nn);
 	if (status)
 		return status;
-	status = check_stateid_generation(stateid, &s->sc_stateid,
+	status = nfsd4_stid_check_stateid_generation(stateid, s,
 			nfsd4_has_session(cstate));
 	if (status)
 		goto out;
@@ -5027,7 +5047,7 @@ nfsd4_free_lock_stateid(stateid_t *stateid, struct nfs4_stid *s)
 
 	mutex_lock(&stp->st_mutex);
 
-	ret = check_stateid_generation(stateid, &s->sc_stateid, 1);
+	ret = nfsd4_stid_check_stateid_generation(stateid, s, 1);
 	if (ret)
 		goto out;
 
@@ -5060,6 +5080,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	s = find_stateid_locked(cl, stateid);
 	if (!s)
 		goto out_unlock;
+	spin_lock(&s->sc_lock);
 	switch (s->sc_type) {
 	case NFS4_DELEG_STID:
 		ret = nfserr_locks_held;
@@ -5071,11 +5092,13 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		ret = nfserr_locks_held;
 		break;
 	case NFS4_LOCK_STID:
+		spin_unlock(&s->sc_lock);
 		atomic_inc(&s->sc_count);
 		spin_unlock(&cl->cl_lock);
 		ret = nfsd4_free_lock_stateid(stateid, s);
 		goto out;
 	case NFS4_REVOKED_DELEG_STID:
+		spin_unlock(&s->sc_lock);
 		dp = delegstateid(s);
 		list_del_init(&dp->dl_recall_lru);
 		spin_unlock(&cl->cl_lock);
@@ -5084,6 +5107,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	/* Default falls through and returns nfserr_bad_stateid */
 	}
+	spin_unlock(&s->sc_lock);
 out_unlock:
 	spin_unlock(&cl->cl_lock);
 out:
@@ -5115,7 +5139,7 @@ static __be32 nfs4_seqid_op_checks(struct nfsd4_compound_state *cstate, stateid_
 		 */
 		return nfserr_bad_stateid;
 	mutex_lock(&stp->st_mutex);
-	status = check_stateid_generation(stateid, &stp->st_stid.sc_stateid, nfsd4_has_session(cstate));
+	status = nfsd4_stid_check_stateid_generation(stateid, &stp->st_stid, nfsd4_has_session(cstate));
 	if (status == nfs_ok)
 		status = nfs4_check_fh(current_fh, &stp->st_stid);
 	if (status != nfs_ok)
@@ -5294,7 +5318,7 @@ static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 	bool unhashed;
 	LIST_HEAD(reaplist);
 
-	s->st_stid.sc_type = NFS4_CLOSED_STID;
+	WARN_ON_ONCE(s->st_stid.sc_type != NFS4_CLOSED_STID);
 	spin_lock(&clp->cl_lock);
 	unhashed = unhash_open_stateid(s, &reaplist);
 
@@ -5334,6 +5358,7 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfsd4_bump_seqid(cstate, status);
 	if (status)
 		goto out; 
+	stp->st_stid.sc_type = NFS4_CLOSED_STID;
 	nfs4_inc_and_copy_stateid(&close->cl_stateid, &stp->st_stid);
 	mutex_unlock(&stp->st_mutex);
 
@@ -5363,7 +5388,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		goto out;
 	dp = delegstateid(s);
-	status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
+	status = nfsd4_stid_check_stateid_generation(stateid, &dp->dl_stid, nfsd4_has_session(cstate));
 	if (status)
 		goto put_stateid;
 
-- 
2.13.6

