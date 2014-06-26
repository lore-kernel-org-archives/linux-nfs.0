Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:57412 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbaFZTOP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:15 -0400
Received: by mail-qa0-f42.google.com with SMTP id dc16so3247618qab.1
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:15 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 021/117] nfsd: clean up nfsd4_close_open_stateid
Date: Thu, 26 Jun 2014 15:12:01 -0400
Message-Id: <1403810017-16062-22-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Minor cleanup that should introduce no behavioral changes.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 38 ++++++++++++++++++--------------------
 1 file changed, 18 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5f79625982b8..f782ed5cad63 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4185,8 +4185,25 @@ out:
 
 static void nfsd4_close_open_stateid(struct nfs4_ol_stateid *s)
 {
-	unhash_open_stateid(s);
+	struct nfs4_client *clp = s->st_stid.sc_client;
+	struct nfs4_openowner *oo = openowner(s->st_stateowner);
+
 	s->st_stid.sc_type = NFS4_CLOSED_STID;
+	unhash_open_stateid(s);
+
+	if (clp->cl_minorversion) {
+		free_generic_stateid(s);
+		if (list_empty(&oo->oo_owner.so_stateids))
+			release_openowner(oo);
+	} else {
+		oo->oo_last_closed_stid = s;
+		/*
+		 * In the 4.0 case we need to keep the owners around a
+		 * little while to handle CLOSE replay.
+		 */
+		if (list_empty(&oo->oo_owner.so_stateids))
+			move_to_close_lru(oo, clp->net);
+	}
 }
 
 /*
@@ -4197,7 +4214,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_close *close)
 {
 	__be32 status;
-	struct nfs4_openowner *oo;
 	struct nfs4_ol_stateid *stp;
 	struct net *net = SVC_NET(rqstp);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
@@ -4213,28 +4229,10 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfsd4_bump_seqid(cstate, status);
 	if (status)
 		goto out; 
-	oo = openowner(stp->st_stateowner);
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
 	nfsd4_close_open_stateid(stp);
-
-	if (cstate->minorversion)
-		free_generic_stateid(stp);
-	else
-		oo->oo_last_closed_stid = stp;
-
-	if (list_empty(&oo->oo_owner.so_stateids)) {
-		if (cstate->minorversion)
-			release_openowner(oo);
-		else {
-			/*
-			 * In the 4.0 case we need to keep the owners around a
-			 * little while to handle CLOSE replay.
-			 */
-			move_to_close_lru(oo, SVC_NET(rqstp));
-		}
-	}
 out:
 	if (!cstate->replay_owner)
 		nfs4_unlock_state();
-- 
1.9.3

