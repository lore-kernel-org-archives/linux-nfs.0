Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:35911 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754395AbaG2Ue6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 16:34:58 -0400
Received: by mail-qa0-f52.google.com with SMTP id j15so247742qaq.39
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 13:34:57 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 19/38] nfsd: Migrate the stateid reference into nfs4_lookup_stateid()
Date: Tue, 29 Jul 2014 16:34:02 -0400
Message-Id: <1406666061-14175-20-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
References: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
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
index e348ab1bde40..285958cd0e3c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4170,6 +4170,8 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 	*s = find_stateid_by_type(cstate->clp, stateid, typemask);
 	if (!*s)
 		return nfserr_bad_stateid;
+	/* FIXME: move into find_stateid_by_type */
+	atomic_inc(&(*s)->sc_count);
 	return nfs_ok;
 }
 
@@ -4204,7 +4206,7 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 				NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
 				&s, nn);
 	if (status)
-		goto out;
+		goto unlock_state;
 	status = check_stateid_generation(stateid, &s->sc_stateid, nfsd4_has_session(cstate));
 	if (status)
 		goto out;
@@ -4253,6 +4255,8 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 	if (file)
 		*filpp = file;
 out:
+	nfs4_put_stid(s);
+unlock_state:
 	nfs4_unlock_state();
 	return status;
 }
@@ -4390,11 +4394,10 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		cstate->replay_owner = stp->st_stateowner;
 
 	status = nfs4_seqid_op_checks(cstate, stateid, seqid, stp);
-	if (!status) {
-		/* FIXME: move into find_stateid_by_type */
-		atomic_inc(&stp->st_stid.sc_count);
+	if (!status)
 		*stpp = stp;
-	}
+	else
+		nfs4_put_stid(&stp->st_stid);
 	return status;
 }
 
@@ -4623,9 +4626,11 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	dp = delegstateid(s);
 	status = check_stateid_generation(stateid, &dp->dl_stid.sc_stateid, nfsd4_has_session(cstate));
 	if (status)
-		goto out;
+		goto put_stateid;
 
 	destroy_delegation(dp);
+put_stateid:
+	nfs4_put_stid(&dp->dl_stid);
 out:
 	nfs4_unlock_state();
 
-- 
1.9.3

