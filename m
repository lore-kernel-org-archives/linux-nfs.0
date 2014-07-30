Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f54.google.com ([209.85.192.54]:63885 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754725AbaG3Bfj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:35:39 -0400
Received: by mail-qg0-f54.google.com with SMTP id z60so632016qgd.41
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:35:38 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v3 32/38] nfsd: clean up and reorganize release_lockowner
Date: Tue, 29 Jul 2014 21:34:37 -0400
Message-Id: <1406684083-19736-33-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do more within the main loop, and simplify the function a bit. Also,
there's no need to take a stateowner reference unless we're going to call
release_lockowner.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 49 ++++++++++++++++++-------------------------------
 1 file changed, 18 insertions(+), 31 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4af4e5eff491..cd7d7df03afa 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5424,8 +5424,8 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 			struct nfsd4_release_lockowner *rlockowner)
 {
 	clientid_t *clid = &rlockowner->rl_clientid;
-	struct nfs4_stateowner *sop = NULL, *tmp;
-	struct nfs4_lockowner *lo;
+	struct nfs4_stateowner *sop;
+	struct nfs4_lockowner *lo = NULL;
 	struct nfs4_ol_stateid *stp;
 	struct xdr_netobj *owner = &rlockowner->rl_owner;
 	unsigned int hashval = ownerstr_hashval(owner);
@@ -5442,45 +5442,32 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	if (status)
 		goto out;
 
-	status = nfserr_locks_held;
-
 	clp = cstate->clp;
 	/* Find the matching lock stateowner */
 	spin_lock(&clp->cl_lock);
-	list_for_each_entry(tmp, &clp->cl_ownerstr_hashtbl[hashval],
+	list_for_each_entry(sop, &clp->cl_ownerstr_hashtbl[hashval],
 			    so_strhash) {
-		if (tmp->so_is_open_owner)
-			continue;
-		if (same_owner_str(tmp, owner)) {
-			sop = tmp;
-			atomic_inc(&sop->so_count);
-			break;
-		}
-	}
 
-	/* No matching owner found, maybe a replay? Just declare victory... */
-	if (!sop) {
-		spin_unlock(&clp->cl_lock);
-		status = nfs_ok;
-		goto out;
-	}
+		if (sop->so_is_open_owner || !same_owner_str(sop, owner))
+			continue;
 
-	lo = lockowner(sop);
-	/* see if there are still any locks associated with it */
-	list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
-		if (check_for_locks(stp->st_stid.sc_file, lo)) {
-			spin_unlock(&clp->cl_lock);
-			goto out;
+		/* see if there are still any locks associated with it */
+		lo = lockowner(sop);
+		list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
+			if (check_for_locks(stp->st_stid.sc_file, lo)) {
+				status = nfserr_locks_held;
+				spin_unlock(&clp->cl_lock);
+				goto out;
+			}
 		}
+
+		atomic_inc(&sop->so_count);
+		break;
 	}
 	spin_unlock(&clp->cl_lock);
-
-	status = nfs_ok;
-	sop = NULL;
-	release_lockowner(lo);
+	if (lo)
+		release_lockowner(lo);
 out:
-	if (sop)
-		nfs4_put_stateowner(sop);
 	nfs4_unlock_state();
 	return status;
 }
-- 
1.9.3

