Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:40185 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758054AbaFSOwL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:11 -0400
Received: by mail-qa0-f52.google.com with SMTP id w8so2008460qac.25
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:10 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 050/104] nfsd: clean up nfs4_release_lockowner
Date: Thu, 19 Jun 2014 10:49:56 -0400
Message-Id: <1403189450-18729-51-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we know that we won't have several lockowners with the same,
owner->data, we can simplify nfs4_release_lockowner and get rid of
the lo_list in the process.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 46 ++++++++++++++++++++++++----------------------
 fs/nfsd/state.h     |  1 -
 2 files changed, 24 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cb8bdadb176a..17a1136ad0a1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5190,7 +5190,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 			struct nfsd4_release_lockowner *rlockowner)
 {
 	clientid_t *clid = &rlockowner->rl_clientid;
-	struct nfs4_stateowner *sop;
+	struct nfs4_stateowner *sop = NULL, *tmp;
 	struct nfs4_lockowner *lo;
 	struct nfs4_ol_stateid *stp;
 	struct xdr_netobj *owner = &rlockowner->rl_owner;
@@ -5211,31 +5211,33 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	status = nfserr_locks_held;
 	INIT_LIST_HEAD(&matches);
 
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
-			if (check_for_locks(stp->st_stid.sc_file, lo))
-				goto out;
-			list_add(&lo->lo_list, &matches);
+		if (same_owner_str(tmp, owner, clid)) {
+			sop = tmp;
+			atomic_inc(&sop->so_count);
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
 	}
+
+	lo = lockowner(sop);
+	/* see if there are still any locks associated with it */
+	list_for_each_entry(stp, &sop->so_stateids, st_perstateowner) {
+		if (check_for_locks(stp->st_stid.sc_file, lo))
+			goto out;
+	}
+
+	status = nfs_ok;
+	release_lockowner(lo);
+	nfs4_put_stateowner(sop);
 out:
 	nfs4_unlock_state();
 	return status;
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 147d0c91b819..00f2951423cc 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -370,7 +370,6 @@ struct nfs4_openowner {
 
 struct nfs4_lockowner {
 	struct nfs4_stateowner	lo_owner; /* must be first element */
-	struct list_head	lo_list; /* for temporary uses */
 };
 
 static inline struct nfs4_openowner * openowner(struct nfs4_stateowner *so)
-- 
1.9.3

