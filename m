Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:49765 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751286AbaF3Pux (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:50:53 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so2139007qge.39
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:50:52 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 014/114] nfsd: Cleanup - Let nfsd4_lookup_stateid() take a cstate argument
Date: Mon, 30 Jun 2014 11:48:43 -0400
Message-Id: <1404143423-24381-15-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

The cstate already holds information about the session, and hence
the client id, so it makes more sense to pass that information
rather than the current practice of passing a 'minor version' number.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8c9b1498aa38..e9bb39ecebae 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3792,12 +3792,14 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
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
@@ -3843,9 +3845,9 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 
 	nfs4_lock_state();
 
-	status = nfsd4_lookup_stateid(stateid,
+	status = nfsd4_lookup_stateid(cstate, stateid,
 				NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
-				&s, cstate->minorversion, nn);
+				&s, nn);
 	if (status)
 		goto out;
 	status = check_stateid_generation(stateid, &s->sc_stateid, nfsd4_has_session(cstate));
@@ -4015,8 +4017,7 @@ nfs4_preprocess_seqid_op(struct nfsd4_compound_state *cstate, u32 seqid,
 		seqid, STATEID_VAL(stateid));
 
 	*stpp = NULL;
-	status = nfsd4_lookup_stateid(stateid, typemask, &s,
-				      cstate->minorversion, nn);
+	status = nfsd4_lookup_stateid(cstate, stateid, typemask, &s, nn);
 	if (status)
 		return status;
 	stp = openlockstateid(s);
@@ -4240,8 +4241,7 @@ nfsd4_delegreturn(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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

