Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:52983 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758064AbaFSOwM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:12 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so2286804qcz.28
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:12 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 051/104] nfsd: clean up refcounting for lockowners
Date: Thu, 19 Jun 2014 10:49:57 -0400
Message-Id: <1403189450-18729-52-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that lockowner references are only held by lockstateids and
operations that are in-progress. With this, we can get rid of
release_lockowner_if_empty, which will be racy once we remove
client_mutex protection.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 34 ++++++++--------------------------
 1 file changed, 8 insertions(+), 26 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 17a1136ad0a1..a80ba729e8b3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -804,8 +804,7 @@ static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 	nfs4_put_stid(&stp->st_stid);
 }
 
-static void __release_lock_stateid(struct nfs4_lockowner *lo,
-		struct nfs4_ol_stateid *stp)
+static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_openowner *oo = openowner(stp->st_openstp->st_stateowner);
 
@@ -829,32 +828,17 @@ static void release_lockowner_stateids(struct nfs4_lockowner *lo)
 	while (!list_empty(&lo->lo_owner.so_stateids)) {
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
-		__release_lock_stateid(lo, stp);
+		release_lock_stateid(stp);
 	}
 }
 
-static void release_lockowner(struct nfs4_lockowner *lo)
+static void destroy_lockowner(struct nfs4_lockowner *lo)
 {
 	unhash_lockowner(lo);
 	release_lockowner_stateids(lo);
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
-	__release_lock_stateid(lo, stp);
-	release_lockowner_if_empty(lo);
-}
-
 static void release_open_stateid_locks(struct nfs4_ol_stateid *open_stp)
 	__releases(&open_stp->st_stateowner->so_client->cl_lock)
 	__acquires(&open_stp->st_stateowner->so_client->cl_lock)
@@ -4144,7 +4128,7 @@ nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
 
 	if (check_for_locks(stp->st_stid.sc_file, lo))
 		return nfserr_locks_held;
-	release_lockowner_if_empty(lo);
+	release_lock_stateid(stp);
 	return nfs_ok;
 }
 
@@ -4789,8 +4773,6 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 		lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
 		if (lo == NULL)
 			return nfserr_jukebox;
-		/* FIXME: extra reference for new lockowners for the client */
-		atomic_inc(&lo->lo_owner.so_count);
 	} else {
 		/* with an existing lockowner, seqids must be the same */
 		status = nfserr_bad_seqid;
@@ -4801,7 +4783,6 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 
 	*lst = find_or_create_lock_stateid(lo, fi, ost, new);
 	if (*lst == NULL) {
-		release_lockowner_if_empty(lo);
 		status = nfserr_jukebox;
 		goto out;
 	}
@@ -5231,13 +5212,14 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
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
-	release_lockowner(lo);
-	nfs4_put_stateowner(sop);
+	destroy_lockowner(lo);
 out:
 	nfs4_unlock_state();
 	return status;
-- 
1.9.3

