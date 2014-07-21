Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f176.google.com ([209.85.216.176]:54875 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932332AbaGUPDa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:30 -0400
Received: by mail-qc0-f176.google.com with SMTP id i17so5652199qcy.35
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:29 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 21/40] nfsd: Migrate the stateid reference into nfs4_lookup_stateid()
Date: Mon, 21 Jul 2014 11:02:33 -0400
Message-Id: <1405954972-28904-22-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Allow nfs4_lookup_stateid to take the stateid reference, instead
of having all the callers do so.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a0e0882edd2b..92f58c36a419 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4188,6 +4188,8 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 	*s = find_stateid_by_type(cstate->clp, stateid, typemask);
 	if (!*s)
 		return nfserr_bad_stateid;
+	/* FIXME: move into find_stateid_by_type */
+	atomic_inc(&(*s)->sc_count);
 	return nfs_ok;
 }
 
@@ -4222,7 +4224,7 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 				NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
 				&s, nn);
 	if (status)
-		goto out;
+		goto unlock_state;
 	status = check_stateid_generation(stateid, &s->sc_stateid, nfsd4_has_session(cstate));
 	if (status)
 		goto out;
@@ -4271,6 +4273,8 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 	if (file)
 		*filpp = file;
 out:
+	nfs4_put_stid(s);
+unlock_state:
 	nfs4_unlock_state();
 	return status;
 }
@@ -4407,11 +4411,10 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		cstate->replay_owner = stp->st_stateowner;
 
 	status = nfs4_seqid_op_checks(cstate, stateid, seqid, stp);
-	if (!status) {
-		/* FIXME: move into find_stateid_by_type */
-		atomic_inc(&stp->st_stid.sc_count);
+	if (!status)
 		*stpp = stp;
-	}
+	else
+		put_generic_stateid(stp);
 	return status;
 }
 
@@ -4640,9 +4643,11 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	dp = delegstateid(s);
 	status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
 	if (status)
-		goto out;
+		goto put_stateid;
 
 	destroy_delegation(dp);
+put_stateid:
+	nfs4_put_delegation(dp);
 out:
 	nfs4_unlock_state();
 
-- 
1.9.3

