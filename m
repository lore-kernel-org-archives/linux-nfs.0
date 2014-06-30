Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:43142 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558AbaF3Puu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:50:50 -0400
Received: by mail-qc0-f180.google.com with SMTP id r5so7070935qcx.25
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:50:49 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 012/114] nfsd: clean up nfsd4_release_lockowner
Date: Mon, 30 Jun 2014 11:48:41 -0400
Message-Id: <1404143423-24381-13-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we know that we won't have several lockowners with the same,
owner->data, we can simplify nfsd4_release_lockowner and get rid of
the lo_list in the process.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 46 ++++++++++++++++++++++------------------------
 fs/nfsd/state.h     |  1 -
 2 files changed, 22 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e7b77c0ff15a..65b093d2aa16 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4794,11 +4794,10 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 			struct nfsd4_release_lockowner *rlockowner)
 {
 	clientid_t *clid = &rlockowner->rl_clientid;
-	struct nfs4_stateowner *sop;
+	struct nfs4_stateowner *sop = NULL, *tmp;
 	struct nfs4_lockowner *lo;
 	struct nfs4_ol_stateid *stp;
 	struct xdr_netobj *owner = &rlockowner->rl_owner;
-	struct list_head matches;
 	unsigned int hashval = ownerstr_hashval(clid->cl_id, owner);
 	__be32 status;
 	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
@@ -4813,33 +4812,32 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 		goto out;
 
 	status = nfserr_locks_held;
-	INIT_LIST_HEAD(&matches);
 
-	list_for_each_entry(sop, &nn->ownerstr_hashtbl[hashval], so_strhash) {
-		if (sop->so_is_open_owner)
-			continue;
-		if (!same_owner_str(sop, owner, clid))
+	/* Find the matching lock stateowner */
+	list_for_each_entry(tmp, &nn->ownerstr_hashtbl[hashval], so_strhash) {
+		if (tmp->so_is_open_owner)
 			continue;
-		list_for_each_entry(stp, &sop->so_stateids,
-				st_perstateowner) {
-			lo = lockowner(sop);
-			if (check_for_locks(stp->st_file, lo))
-				goto out;
-			list_add(&lo->lo_list, &matches);
+		if (same_owner_str(tmp, owner, clid)) {
+			sop = tmp;
+			break;
 		}
 	}
-	/* Clients probably won't expect us to return with some (but not all)
-	 * of the lockowner state released; so don't release any until all
-	 * have been checked. */
-	status = nfs_ok;
-	while (!list_empty(&matches)) {
-		lo = list_entry(matches.next, struct nfs4_lockowner,
-								lo_list);
-		/* unhash_stateowner deletes so_perclient only
-		 * for openowners. */
-		list_del(&lo->lo_list);
-		release_lockowner(lo);
+
+	/* No matching owner found, maybe a replay? Just declare victory... */
+	if (!sop) {
+		status = nfs_ok;
+		goto out;
+	}
+
+	lo = lockowner(sop);
+	/* see if there are still any locks associated with it */
+	list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
+		if (check_for_locks(stp->st_file, lo))
+			goto out;
 	}
+
+	status = nfs_ok;
+	release_lockowner(lo);
 out:
 	nfs4_unlock_state();
 	return status;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 2fe58f5f4833..a7d13cd97921 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -364,7 +364,6 @@ struct nfs4_openowner {
 
 struct nfs4_lockowner {
 	struct nfs4_stateowner	lo_owner; /* must be first element */
-	struct list_head	lo_list; /* for temporary uses */
 };
 
 static inline struct nfs4_openowner * openowner(struct nfs4_stateowner *so)
-- 
1.9.3

