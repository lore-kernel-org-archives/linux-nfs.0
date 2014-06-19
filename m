Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:34017 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757959AbaFSOv3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:29 -0400
Received: by mail-qg0-f47.google.com with SMTP id q108so2216124qgd.34
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:29 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 022/104] NFSd: clean up nfsd4_close_open_stateid
Date: Thu, 19 Jun 2014 10:49:28 -0400
Message-Id: <1403189450-18729-23-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 47 ++++++++++++++++++++++-------------------------
 1 file changed, 22 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c01f1628c989..2af6cd2564e7 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4300,8 +4300,29 @@ out:
 
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
+		if (list_empty(&oo->oo_owner.so_stateids))
+			release_openowner(oo);
+		put_generic_stateid(s);
+	} else {
+		if (s->st_file) {
+			put_nfs4_file(s->st_file);
+			s->st_file = NULL;
+		}
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
@@ -4312,7 +4333,6 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	    struct nfsd4_close *close)
 {
 	__be32 status;
-	struct nfs4_openowner *oo;
 	struct nfs4_ol_stateid *stp;
 	struct net *net = SVC_NET(rqstp);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
@@ -4328,33 +4348,10 @@ nfsd4_close(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfsd4_bump_seqid(cstate, status);
 	if (status)
 		goto out; 
-	oo = openowner(stp->st_stateowner);
 	update_stateid(&stp->st_stid.sc_stateid);
 	memcpy(&close->cl_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
 
 	nfsd4_close_open_stateid(stp);
-
-	if (cstate->minorversion)
-		put_generic_stateid(stp);
-	else {
-		if (stp->st_file) {
-			put_nfs4_file(stp->st_file);
-			stp->st_file = NULL;
-		}
-		oo->oo_last_closed_stid = stp;
-	}
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
 	nfs4_unlock_state();
 	return status;
-- 
1.9.3

