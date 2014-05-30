Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:59534 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755624AbaE3NJr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2014 09:09:47 -0400
Received: by mail-qg0-f52.google.com with SMTP id a108so5108254qge.25
        for <linux-nfs@vger.kernel.org>; Fri, 30 May 2014 06:09:46 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, bhalevy@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH 2/9] nfsd: fix laundromat next-run-time calculation
Date: Fri, 30 May 2014 09:09:26 -0400
Message-Id: <1401455373-18207-3-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
References: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The laundromat uses two variables to calculate when it should next run,
but one is completely ignored at the end of the run. Merge the two and
rename the variable to be more descriptive of what it does.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e85b8811aad3..be6199cc8711 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3385,8 +3385,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 	struct nfs4_delegation *dp;
 	struct list_head *pos, *next, reaplist;
 	time_t cutoff = get_seconds() - nn->nfsd4_lease;
-	time_t t, clientid_val = nn->nfsd4_lease;
-	time_t u, test_val = nn->nfsd4_lease;
+	time_t t, new_timeo = nn->nfsd4_lease;
 
 	nfs4_lock_state();
 
@@ -3398,8 +3397,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 		clp = list_entry(pos, struct nfs4_client, cl_lru);
 		if (time_after((unsigned long)clp->cl_time, (unsigned long)cutoff)) {
 			t = clp->cl_time - cutoff;
-			if (clientid_val > t)
-				clientid_val = t;
+			new_timeo = min(new_timeo, t);
 			break;
 		}
 		if (mark_client_expired_locked(clp)) {
@@ -3422,9 +3420,8 @@ nfs4_laundromat(struct nfsd_net *nn)
 		if (net_generic(dp->dl_stid.sc_client->net, nfsd_net_id) != nn)
 			continue;
 		if (time_after((unsigned long)dp->dl_time, (unsigned long)cutoff)) {
-			u = dp->dl_time - cutoff;
-			if (test_val > u)
-				test_val = u;
+			t = dp->dl_time - cutoff;
+			new_timeo = min(new_timeo, t);
 			break;
 		}
 		list_move(&dp->dl_recall_lru, &reaplist);
@@ -3434,21 +3431,18 @@ nfs4_laundromat(struct nfsd_net *nn)
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
 		revoke_delegation(dp);
 	}
-	test_val = nn->nfsd4_lease;
 	list_for_each_safe(pos, next, &nn->close_lru) {
 		oo = container_of(pos, struct nfs4_openowner, oo_close_lru);
 		if (time_after((unsigned long)oo->oo_time, (unsigned long)cutoff)) {
-			u = oo->oo_time - cutoff;
-			if (test_val > u)
-				test_val = u;
+			t = oo->oo_time - cutoff;
+			new_timeo = min(new_timeo, t);
 			break;
 		}
 		release_openowner(oo);
 	}
-	if (clientid_val < NFSD_LAUNDROMAT_MINTIMEOUT)
-		clientid_val = NFSD_LAUNDROMAT_MINTIMEOUT;
+	new_timeo = max_t(time_t, new_timeo, NFSD_LAUNDROMAT_MINTIMEOUT);
 	nfs4_unlock_state();
-	return clientid_val;
+	return new_timeo;
 }
 
 static struct workqueue_struct *laundry_wq;
-- 
1.9.3

