Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f49.google.com ([209.85.216.49]:46577 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038AbaF3Pup (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:50:45 -0400
Received: by mail-qa0-f49.google.com with SMTP id w8so6446860qac.22
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:50:45 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 008/114] nfsd: clean up nfsd4_close_open_stateid
Date: Mon, 30 Jun 2014 11:48:37 -0400
Message-Id: <1404143423-24381-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Minor cleanup that should introduce no behavioral changes.

Currently this function just unhashes the stateid and leaves the caller
to do the work of the CLOSE processing.

Change nfsd4_close_open_stateid so that it handles doing all of the work
of closing a stateid. Move the handling of the unhashed stateid into it
instead of doing that work in nfsd4_close. This will help isolate some
coming changes to stateid handling from nfsd4_close.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 38 ++++++++++++++++++--------------------
 1 file changed, 18 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e77e34002913..08586646e962 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4140,8 +4140,25 @@ out:
 
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
@@ -4152,7 +4169,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_close *close)
 {
 	__be32 status;
-	struct nfs4_openowner *oo;
 	struct nfs4_ol_stateid *stp;
 	struct net *net = SVC_NET(rqstp);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
@@ -4168,28 +4184,10 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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

