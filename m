Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:44346 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756154AbdKCMAb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Nov 2017 08:00:31 -0400
Received: by mail-io0-f196.google.com with SMTP id m16so5753229iod.1
        for <linux-nfs@vger.kernel.org>; Fri, 03 Nov 2017 05:00:31 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 7/7] nfsd: Fix races with check_stateid_generation()
Date: Fri,  3 Nov 2017 08:00:16 -0400
Message-Id: <20171103120016.6200-8-trond.myklebust@primarydata.com>
In-Reply-To: <20171103120016.6200-7-trond.myklebust@primarydata.com>
References: <20171103120016.6200-1-trond.myklebust@primarydata.com>
 <20171103120016.6200-2-trond.myklebust@primarydata.com>
 <20171103120016.6200-3-trond.myklebust@primarydata.com>
 <20171103120016.6200-4-trond.myklebust@primarydata.com>
 <20171103120016.6200-5-trond.myklebust@primarydata.com>
 <20171103120016.6200-6-trond.myklebust@primarydata.com>
 <20171103120016.6200-7-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The various functions that call check_stateid_generation() in order
to compare a client-supplied stateid with the nfs4_stid state, usually
need to atomically check for closed state. Those that perform the
check after locking the st_mutex using nfsd4_lock_ol_stateid()
should now be OK, but we do want to fix up the others.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cbd6a10ddda2..6f552ca62415 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4849,6 +4849,18 @@ static __be32 check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_s
 	return nfserr_old_stateid;
 }
 
+static __be32 nfsd4_stid_check_stateid_generation(stateid_t *in, struct nfs4_stid *s, bool has_session)
+{
+	__be32 ret;
+
+	spin_lock(&s->sc_lock);
+	ret = nfsd4_verify_open_stid(s);
+	if (ret == nfs_ok)
+		ret = check_stateid_generation(in, &s->sc_stateid, has_session);
+	spin_unlock(&s->sc_lock);
+	return ret;
+}
+
 static __be32 nfsd4_check_openowner_confirmed(struct nfs4_ol_stateid *ols)
 {
 	if (ols->st_stateowner->so_is_open_owner &&
@@ -4877,7 +4889,7 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	s = find_stateid_locked(cl, stateid);
 	if (!s)
 		goto out_unlock;
-	status = check_stateid_generation(stateid, &s->sc_stateid, 1);
+	status = nfsd4_stid_check_stateid_generation(stateid, s, 1);
 	if (status)
 		goto out_unlock;
 	switch (s->sc_type) {
@@ -5022,7 +5034,7 @@ nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
 				&s, nn);
 	if (status)
 		return status;
-	status = check_stateid_generation(stateid, &s->sc_stateid,
+	status = nfsd4_stid_check_stateid_generation(stateid, s,
 			nfsd4_has_session(cstate));
 	if (status)
 		goto out;
@@ -5115,6 +5127,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	s = find_stateid_locked(cl, stateid);
 	if (!s)
 		goto out_unlock;
+	spin_lock(&s->sc_lock);
 	switch (s->sc_type) {
 	case NFS4_DELEG_STID:
 		ret = nfserr_locks_held;
@@ -5126,11 +5139,13 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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
@@ -5139,6 +5154,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		goto out;
 	/* Default falls through and returns nfserr_bad_stateid */
 	}
+	spin_unlock(&s->sc_lock);
 out_unlock:
 	spin_unlock(&cl->cl_lock);
 out:
@@ -5418,7 +5434,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		goto out;
 	dp = delegstateid(s);
-	status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
+	status = nfsd4_stid_check_stateid_generation(stateid, &dp->dl_stid, nfsd4_has_session(cstate));
 	if (status)
 		goto put_stateid;
 
-- 
2.13.6

