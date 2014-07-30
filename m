Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:58065 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754652AbaG3Bfn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:35:43 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so667473qge.11
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:35:42 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v3 35/38] nfsd: close potential race in nfsd4_free_stateid
Date: Tue, 29 Jul 2014 21:34:40 -0400
Message-Id: <1406684083-19736-36-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Once we remove the client_mutex, it'll be possible for the sc_type of a
lock stateid to change after it's found and checked, but before we can
go to destroy it. If that happens, we can end up putting the persistent
reference to the stateid more than once, and unhash it more than once.

Fix this by unhashing the lock stateid prior to dropping the cl_lock but
after finding it.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 21 +++++++++------------
 1 file changed, 9 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9358cbe2283d..9c7dcbb68094 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4397,17 +4397,6 @@ unlock_state:
 	return status;
 }
 
-static __be32
-nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
-{
-	struct nfs4_lockowner *lo = lockowner(stp->st_stateowner);
-
-	if (check_for_locks(stp->st_stid.sc_file, lo))
-		return nfserr_locks_held;
-	release_lock_stateid(stp);
-	return nfs_ok;
-}
-
 /*
  * Test if the stateid is valid
  */
@@ -4434,6 +4423,7 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	stateid_t *stateid = &free_stateid->fr_stateid;
 	struct nfs4_stid *s;
 	struct nfs4_delegation *dp;
+	struct nfs4_ol_stateid *stp;
 	struct nfs4_client *cl = cstate->session->se_client;
 	__be32 ret = nfserr_bad_stateid;
 
@@ -4456,8 +4446,15 @@ nfsd4_free_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		ret = check_stateid_generation(stateid, &s->sc_stateid, 1);
 		if (ret)
 			break;
+		stp = openlockstateid(s);
+		ret = nfserr_locks_held;
+		if (check_for_locks(stp->st_stid.sc_file,
+				    lockowner(stp->st_stateowner)))
+			break;
+		unhash_lock_stateid(stp);
 		spin_unlock(&cl->cl_lock);
-		ret = nfsd4_free_lock_stateid(openlockstateid(s));
+		nfs4_put_stid(s);
+		ret = nfs_ok;
 		goto out;
 	case NFS4_REVOKED_DELEG_STID:
 		dp = delegstateid(s);
-- 
1.9.3

