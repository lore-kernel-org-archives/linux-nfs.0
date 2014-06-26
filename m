Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:44362 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbaFZTPS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:15:18 -0400
Received: by mail-qc0-f174.google.com with SMTP id x13so3549433qcv.33
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:15:18 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 068/117] nfsd: clean up refcounting for lockowners
Date: Thu, 26 Jun 2014 15:12:48 -0400
Message-Id: <1403810017-16062-69-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
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
index 649b2e829981..d8de65e0a457 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -926,7 +926,7 @@ static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 	nfs4_put_stid(&stp->st_stid);
 }
 
-static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
+static void release_lock_stateid(struct nfs4_ol_stateid *stp)
 {
 	struct nfs4_openowner *oo = openowner(stp->st_openstp->st_stateowner);
 
@@ -950,7 +950,7 @@ static void release_lockowner_stateids(struct nfs4_lockowner *lo)
 	while (!list_empty(&lo->lo_owner.so_stateids)) {
 		stp = list_first_entry(&lo->lo_owner.so_stateids,
 				struct nfs4_ol_stateid, st_perstateowner);
-		__release_lock_stateid(stp);
+		release_lock_stateid(stp);
 	}
 }
 
@@ -961,21 +961,6 @@ static void release_lockowner(struct nfs4_lockowner *lo)
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
@@ -4285,7 +4270,7 @@ nfsd4_free_lock_stateid(struct nfs4_ol_stateid *stp)
 
 	if (check_for_locks(stp->st_stid.sc_file, lo))
 		return nfserr_locks_held;
-	release_lockowner_if_empty(lo);
+	release_lock_stateid(stp);
 	return nfs_ok;
 }
 
@@ -4907,8 +4892,6 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 		lo = alloc_init_lock_stateowner(strhashval, cl, ost, lock);
 		if (lo == NULL)
 			return nfserr_jukebox;
-		/* FIXME: extra reference for new lockowners for the client */
-		atomic_inc(&lo->lo_owner.so_count);
 	} else {
 		/* with an existing lockowner, seqids must be the same */
 		status = nfserr_bad_seqid;
@@ -4919,7 +4902,6 @@ static __be32 lookup_or_create_lock_state(struct nfsd4_compound_state *cstate,
 
 	*lst = find_or_create_lock_stateid(lo, fi, ost, new);
 	if (*lst == NULL) {
-		release_lockowner_if_empty(lo);
 		status = nfserr_jukebox;
 		goto out;
 	}
@@ -5341,6 +5323,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 			continue;
 		if (same_owner_str(tmp, owner, clid)) {
 			sop = tmp;
+			atomic_inc(&sop->so_count);
 			break;
 		}
 	}
@@ -5354,8 +5337,10 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
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

