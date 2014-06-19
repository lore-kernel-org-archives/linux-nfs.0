Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f45.google.com ([209.85.216.45]:53908 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757917AbaFSOwW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:22 -0400
Received: by mail-qa0-f45.google.com with SMTP id v10so2014726qac.18
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:22 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 058/104] NFSd: Cache the client that was looked up in lookup_clientid()
Date: Thu, 19 Jun 2014 10:50:04 -0400
Message-Id: <1403189450-18729-59-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

We want to use the nfsd4_compound_state to cache the nfs4_client
in order to optimise away extra lookups of the clid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 44 +++++++++++++++++++++++++++++---------------
 1 file changed, 29 insertions(+), 15 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7034db2d00b3..428944aef83f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3814,15 +3814,31 @@ void nfsd4_cleanup_open_state(struct nfsd4_compound_state *cstate,
 		put_generic_stateid(open->op_stp);
 }
 
-static __be32 lookup_clientid(clientid_t *clid, bool session, struct nfsd_net *nn, struct nfs4_client **clp)
+static __be32 lookup_clientid(clientid_t *clid,
+		struct nfsd4_compound_state *cstate,
+		struct nfsd_net *nn)
 {
 	struct nfs4_client *found;
 
-	if (STALE_CLIENTID(clid, nn))
-		return nfserr_stale_clientid;
-	found = find_confirmed_client(clid, session, nn);
-	if (clp)
-		*clp = found;
+	if (cstate->clp != NULL) {
+		found = cstate->clp;
+		if (!same_clid(&found->cl_clientid, clid))
+			return nfserr_stale_clientid;
+	} else {
+		if (STALE_CLIENTID(clid, nn))
+			return nfserr_stale_clientid;
+		/*
+		 * Usually for v4.1+ we get the client in the SEQUENCE op, so
+		 * if we don't have one cached already then we know this is for
+		 * is for v4.0 and "sessions" will be false.
+		 */
+		found = find_confirmed_client(clid, false, nn);
+		/* Cache the nfs4_client in cstate! */
+		if (found) {
+			cstate->clp = found;
+			atomic_inc(&found->cl_refcount);
+		}
+	}
 	return found ? nfs_ok : nfserr_expired;
 }
 
@@ -3837,9 +3853,10 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 	dprintk("process_renew(%08x/%08x): starting\n", 
 			clid->cl_boot, clid->cl_id);
-	status = lookup_clientid(clid, cstate->minorversion, nn, &clp);
+	status = lookup_clientid(clid, cstate, nn);
 	if (status)
 		goto out;
+	clp = cstate->clp;
 	status = nfserr_cb_path_down;
 	if (!list_empty(&clp->cl_delegations)
 			&& clp->cl_cb_state != NFSD4_CB_UP)
@@ -4111,22 +4128,19 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     stateid_t *stateid, unsigned char typemask,
 		     struct nfs4_stid **s, struct nfsd_net *nn)
 {
-	struct nfs4_client *cl;
 	__be32 status;
-	bool sessions = cstate->minorversion != 0;
 
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return nfserr_bad_stateid;
-	status = lookup_clientid(&stateid->si_opaque.so_clid, sessions,
-							nn, &cl);
+	status = lookup_clientid(&stateid->si_opaque.so_clid, cstate, nn);
 	if (status == nfserr_stale_clientid) {
-		if (sessions)
+		if (cstate->session)
 			return nfserr_bad_stateid;
 		return nfserr_stale_stateid;
 	}
 	if (status)
 		return status;
-	*s = find_stateid_by_type(cl, stateid, typemask);
+	*s = find_stateid_by_type(cstate->clp, stateid, typemask);
 	if (!*s)
 		return nfserr_bad_stateid;
 	return nfs_ok;
@@ -5119,7 +5133,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 
 	if (!nfsd4_has_session(cstate)) {
-		status = lookup_clientid(&lockt->lt_clientid, false, nn, NULL);
+		status = lookup_clientid(&lockt->lt_clientid, cstate, nn);
 		if (status)
 			goto out;
 	}
@@ -5294,7 +5308,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 
 	nfs4_lock_state();
 
-	status = lookup_clientid(clid, cstate->minorversion, nn, NULL);
+	status = lookup_clientid(clid, cstate, nn);
 	if (status)
 		goto out;
 
-- 
1.9.3

