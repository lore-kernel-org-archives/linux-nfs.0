Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:49548 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741AbaG3Bf3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:35:29 -0400
Received: by mail-qa0-f47.google.com with SMTP id i13so596266qae.34
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:35:29 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v3 26/38] nfsd: clean up refcounting for lockowners
Date: Tue, 29 Jul 2014 21:34:31 -0400
Message-Id: <1406684083-19736-27-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that lockowner references are only held by lockstateids and
operations that are in-progress. With this, we can get rid of
release_lockowner_if_empty, which will be racy once we remove
client_mutex protection.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 29 +++++++----------------------
 1 file changed, 7 insertions(+), 22 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 88225f0bbc12..c86fe66254b0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -933,7 +933,7 @@ static void nfs4_free_lock_stateid(struct nfs4_stid *stid)
 	nfs4_free_ol_stateid(stid);
 }
 
-static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
+static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_openowner *oo = openowner(stp->st_openstp->st_stateowner);
 
@@ -957,7 +957,7 @@ static void release_lockowner_stateids(struct nfs4_lockowner *lo)
 	while (!list_empty(&lo->lo_owner.so_stateids)) {
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
-		__release_lock_stateid(stp);
+		release_lock_stateid(stp);
 	}
 }
 
@@ -968,21 +968,6 @@ static void release_lockowner(struct nfs4_lockowner *lo)
 	nfs4_put_stateowner(&lo->lo_owner);
 }
 
-static void release_lockowner_if_empty(struct nfs4_lockowner *lo)
-{
-	if (list_empty(&lo->lo_owner.so_stateids))
-		release_lockowner(lo);
-}
-
-static void release_lock_stateid(struct nfs4_ol_stateid *stp)
-{
-	struct nfs4_lockowner *lo;
-
-	lo = lockowner(stp->st_stateowner);
-	__release_lock_stateid(stp);
-	release_lockowner_if_empty(lo);
-}
-
 static void release_open_stateid_locks(struct nfs4_ol_stateid *open_stp)
 	__releases(&open_stp->st_stateowner->so_client->cl_lock)
 	__acquires(&open_stp->st_stateowner->so_client->cl_lock)
@@ -4323,7 +4308,7 @@ nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
 
 	if (check_for_locks(stp->st_stid.sc_file, lo))
 		return nfserr_locks_held;
-	release_lockowner_if_empty(lo);
+	release_lock_stateid(stp);
 	return nfs_ok;
 }
 
@@ -4938,8 +4923,6 @@ lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 		lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
 		if (lo == NULL)
 			return nfserr_jukebox;
-		/* FIXME: extra reference for new lockowners for the client */
-		atomic_inc(&lo->lo_owner.so_count);
 	} else {
 		/* with an existing lockowner, seqids must be the same */
 		status = nfserr_bad_seqid;
@@ -4950,7 +4933,6 @@ lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 
 	*lst = find_or_create_lock_stateid(lo, fi, inode, ost, new);
 	if (*lst == NULL) {
-		release_lockowner_if_empty(lo);
 		status = nfserr_jukebox;
 		goto out;
 	}
@@ -5379,6 +5361,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 			continue;
 		if (same_owner_str(tmp, owner, clid)) {
 			sop = tmp;
+			atomic_inc(&sop->so_count);
 			break;
 		}
 	}
@@ -5392,8 +5375,10 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	lo = lockowner(sop);
 	/* see if there are still any locks associated with it */
 	list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
-		if (check_for_locks(stp->st_stid.sc_file, lo))
+		if (check_for_locks(stp->st_stid.sc_file, lo)) {
+			nfs4_put_stateowner(sop);
 			goto out;
+		}
 	}
 
 	status = nfs_ok;
-- 
1.9.3

