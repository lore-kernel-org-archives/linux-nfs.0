Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38666 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862AbaDRSqX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:46:23 -0400
Received: by mail-ig0-f169.google.com with SMTP id h18so1230901igc.0
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:46:23 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 50/70] NFSd: Use the session->se_client  in lookup_clientid()
Date: Fri, 18 Apr 2014 14:44:44 -0400
Message-Id: <1397846704-14567-51-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-50-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-34-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-36-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-37-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-38-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-39-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-40-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-41-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-42-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-43-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-44-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-45-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-46-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-47-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-48-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-49-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-50-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In NFSv4.x with x>0, we want to use the session's pointer to the
nfs4_client in order to optimise away the extra lookup of the clid.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 25 +++++++++++++++----------
 1 file changed, 15 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 888acf114e40..6e2d348d3367 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3571,13 +3571,19 @@ void nfsd4_cleanup_open_state(struct nfsd4_open *open, __be32 status)
 		put_generic_stateid(open->op_stp);
 }
 
-static __be32 lookup_clientid(clientid_t *clid, bool session, struct nfsd_net *nn, struct nfs4_client **clp)
+static __be32 lookup_clientid(clientid_t *clid, struct nfsd4_session *session, struct nfsd_net *nn, struct nfs4_client **clp)
 {
 	struct nfs4_client *found;
 
-	if (STALE_CLIENTID(clid, nn))
-		return nfserr_stale_clientid;
-	found = find_confirmed_client(clid, session, nn);
+	if (session != NULL) {
+		found = session->se_client;
+		if (!same_clid(&found->cl_clientid, clid))
+			return nfserr_stale_clientid;
+	} else {
+		if (STALE_CLIENTID(clid, nn))
+			return nfserr_stale_clientid;
+		found = find_confirmed_client(clid, false, nn);
+	}
 	if (clp)
 		*clp = found;
 	return found ? nfs_ok : nfserr_expired;
@@ -3594,7 +3600,7 @@ nfsd4_renew(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 	dprintk("process_renew(%08x/%08x): starting\n", 
 			clid->cl_boot, clid->cl_id);
-	status = lookup_clientid(clid, cstate->minorversion, nn, &clp);
+	status = lookup_clientid(clid, NULL, nn, &clp);
 	if (status)
 		goto out;
 	status = nfserr_cb_path_down;
@@ -3879,14 +3885,13 @@ static __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 {
 	struct nfs4_client *cl;
 	__be32 status;
-	bool sessions = cstate->minorversion != 0;
 
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return nfserr_bad_stateid;
-	status = lookup_clientid(&stateid->si_opaque.so_clid, sessions,
+	status = lookup_clientid(&stateid->si_opaque.so_clid, cstate->session,
 							nn, &cl);
 	if (status == nfserr_stale_clientid) {
-		if (sessions)
+		if (cstate->session)
 			return nfserr_bad_stateid;
 		return nfserr_stale_stateid;
 	}
@@ -4770,7 +4775,7 @@ nfsd4_lockt(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_lock_state();
 
 	if (!nfsd4_has_session(cstate)) {
-		status = lookup_clientid(&lockt->lt_clientid, false, nn, NULL);
+		status = lookup_clientid(&lockt->lt_clientid, NULL, nn, NULL);
 		if (status)
 			goto out;
 	}
@@ -4942,7 +4947,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 
 	nfs4_lock_state();
 
-	status = lookup_clientid(clid, cstate->minorversion, nn, NULL);
+	status = lookup_clientid(clid, NULL, nn, NULL);
 	if (status)
 		goto out;
 
-- 
1.9.0

