Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:63060 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbaFZTOO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:14 -0400
Received: by mail-qc0-f181.google.com with SMTP id x13so3605249qcv.12
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:13 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 020/117] nfsd: Cleanup - Let nfsd4_lookup_stateid() take a cstate argument
Date: Thu, 26 Jun 2014 15:12:00 -0400
Message-Id: <1403810017-16062-21-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

The cstate already holds information about the session, and hence
the client id, so it makes more sense to pass that information
rather than the current practice of passing a 'minor version' number.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 44e98e5fe44a..5f79625982b8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3804,12 +3804,14 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
 	}
 }
 
-static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
-				   struct nfs4_stid **s, bool sessions,
-				   struct nfsd_net *nn)
+static __be32
+nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
+		     stateid_t *stateid, unsigned char typemask,
+		     struct nfs4_stid **s, struct nfsd_net *nn)
 {
 	struct nfs4_client *cl;
 	__be32 status;
+	bool sessions = cstate->minorversion != 0;
 
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return nfserr_bad_stateid;
@@ -3855,9 +3857,9 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 
 	nfs4_lock_state();
 
-	status = nfsd4_lookup_stateid(stateid,
+	status = nfsd4_lookup_stateid(cstate, stateid,
 				NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
-				&s, cstate->minorversion, nn);
+				&s, nn);
 	if (status)
 		goto out;
 	status = check_stateid_generation(stateid, &s->sc_stateid, nfsd4_has_session(cstate));
@@ -4027,8 +4029,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		seqid, STATEID_VAL(stateid));
 
 	*stpp = NULL;
-	status = nfsd4_lookup_stateid(stateid, typemask, &s,
-				      cstate->minorversion, nn);
+	status = nfsd4_lookup_stateid(cstate, stateid, typemask, &s, nn);
 	if (status)
 		return status;
 	stp = openlockstateid(s);
@@ -4254,8 +4255,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return status;
 
 	nfs4_lock_state();
-	status = nfsd4_lookup_stateid(stateid, NFS4_DELEG_STID, &s,
-				      cstate->minorversion, nn);
+	status = nfsd4_lookup_stateid(cstate, stateid, NFS4_DELEG_STID, &s, nn);
 	if (status)
 		goto out;
 	dp = delegstateid(s);
-- 
1.9.3

