Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:52119 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754260AbaF3Pvx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:53 -0400
Received: by mail-qc0-f175.google.com with SMTP id i8so7248061qcq.34
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:53 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 057/114] nfsd: Migrate the stateid reference into nfs4_lookup_stateid()
Date: Mon, 30 Jun 2014 11:49:26 -0400
Message-Id: <1404143423-24381-58-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
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
index 2b7ce084eb04..9d9cb26c391c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4124,6 +4124,8 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 	*s = find_stateid_by_type(cstate->clp, stateid, typemask);
 	if (!*s)
 		return nfserr_bad_stateid;
+	/* FIXME: move into find_stateid_by_type */
+	atomic_inc(&(*s)->sc_count);
 	return nfs_ok;
 }
 
@@ -4158,7 +4160,7 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 				NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
 				&s, nn);
 	if (status)
-		goto out;
+		goto unlock_state;
 	status = check_stateid_generation(stateid, &s->sc_stateid, nfsd4_has_session(cstate));
 	if (status)
 		goto out;
@@ -4207,6 +4209,8 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 	if (file)
 		*filpp = file;
 out:
+	nfs4_put_stid(s);
+unlock_state:
 	nfs4_unlock_state();
 	return status;
 }
@@ -4341,11 +4345,10 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 	nfsd4_cstate_assign_replay(cstate, stp->st_stateowner);
 
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
 
@@ -4571,9 +4574,11 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	dp = delegstateid(s);
 	status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
 	if (status)
-		goto out;
+		goto put_stateid;
 
 	unhash_and_destroy_delegation(dp);
+put_stateid:
+	nfs4_put_delegation(dp);
 out:
 	nfs4_unlock_state();
 
-- 
1.9.3

