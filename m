Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f53.google.com ([74.125.83.53]:38835 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790Ab3LOPvz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Dec 2013 10:51:55 -0500
Received: by mail-ee0-f53.google.com with SMTP id b57so1723771eek.26
        for <linux-nfs@vger.kernel.org>; Sun, 15 Dec 2013 07:51:54 -0800 (PST)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH v2 1/2] nfsd4: break from inner lookup loop in nfsd4_release_lockowner on first match
Date: Sun, 15 Dec 2013 17:51:50 +0200
Message-Id: <1387122710-23603-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52ADCFC2.7060504@gmail.com>
References: <52ADCFC2.7060504@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Otherwise the lockowner may by added to "matches" more than once.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0874998..b04f765 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4192,6 +4192,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
 	/* It is the openowner seqid that will be incremented in encode in the
 	 * case of new lockowners; so increment the lock seqid manually: */
 	lo->lo_owner.so_seqid = lock->lk_new_lock_seqid + 1;
+	INIT_LIST_HEAD(&lo->lo_list);
 	hash_lockowner(lo, strhashval, clp, open_stp);
 	return lo;
 }
@@ -4646,7 +4647,6 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 	if (status)
 		goto out;
 
-	status = nfserr_locks_held;
 	INIT_LIST_HEAD(&matches);
 
 	list_for_each_entry(sop, &nn->ownerstr_hashtbl[hashval], so_strhash) {
@@ -4654,25 +4654,30 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
 			continue;
 		if (!same_owner_str(sop, owner, clid))
 			continue;
+		lo = lockowner(sop);
 		list_for_each_entry(stp, &sop->so_stateids,
 				st_perstateowner) {
-			lo = lockowner(sop);
-			if (check_for_locks(stp->st_file, lo))
-				goto out;
+			if (check_for_locks(stp->st_file, lo)) {
+				status = nfserr_locks_held;
+				goto locks_held;
+			}
 			list_add(&lo->lo_list, &matches);
+			break;
 		}
 	}
 	/* Clients probably won't expect us to return with some (but not all)
 	 * of the lockowner state released; so don't release any until all
 	 * have been checked. */
 	status = nfs_ok;
+locks_held:
 	while (!list_empty(&matches)) {
-		lo = list_entry(matches.next, struct nfs4_lockowner,
+		lo = list_first_entry(&matches, struct nfs4_lockowner,
 								lo_list);
 		/* unhash_stateowner deletes so_perclient only
 		 * for openowners. */
 		list_del(&lo->lo_list);
-		release_lockowner(lo);
+		if (status == nfs_ok)
+			release_lockowner(lo);
 	}
 out:
 	nfs4_unlock_state();
-- 
1.8.3.1

