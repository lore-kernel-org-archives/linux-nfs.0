Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:34360 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754004AbbHXQl7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2015 12:41:59 -0400
Received: by qkfh127 with SMTP id h127so75539399qkf.1
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2015 09:41:58 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Andrew W Elble <aweits@rit.edu>, linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/2] nfsd: ensure that delegation stateid hash references are only put once
Date: Mon, 24 Aug 2015 12:41:48 -0400
Message-Id: <1440434508-16046-3-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1440434508-16046-1-git-send-email-jeff.layton@primarydata.com>
References: <1440434508-16046-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible that a DELEGRETURN could race with (e.g.) client expiry,
in which case we could end up putting the delegation hash reference more
than once.

Have unhash_delegation_locked return a bool that indicates whether it
was already unhashed. In the case of destroy_delegation we only
conditionally put the hash reference if that returns true.

The other callers of unhash_delegation_locked call it while walking
list_heads that shouldn't yet be detached. If we find that it doesn't
return true in those cases, then throw a WARN_ON as that indicates that
we have a partially hashed delegation, and that something is likely very
wrong.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4b4faf5e4bc7..0a82daa41555 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -777,13 +777,16 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 }
 
-static void
+static bool
 unhash_delegation_locked(struct nfs4_delegation *dp)
 {
 	struct nfs4_file *fp = dp->dl_stid.sc_file;
 
 	lockdep_assert_held(&state_lock);
 
+	if (list_empty(&dp->dl_perfile))
+		return false;
+
 	dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
 	/* Ensure that deleg break won't try to requeue it */
 	++dp->dl_time;
@@ -792,16 +795,21 @@ unhash_delegation_locked(struct nfs4_delegation *dp)
 	list_del_init(&dp->dl_recall_lru);
 	list_del_init(&dp->dl_perfile);
 	spin_unlock(&fp->fi_lock);
+	return true;
 }
 
 static void destroy_delegation(struct nfs4_delegation *dp)
 {
+	bool unhashed;
+
 	spin_lock(&state_lock);
-	unhash_delegation_locked(dp);
+	unhashed = unhash_delegation_locked(dp);
 	spin_unlock(&state_lock);
-	put_clnt_odstate(dp->dl_clnt_odstate);
-	nfs4_put_deleg_lease(dp->dl_stid.sc_file);
-	nfs4_put_stid(&dp->dl_stid);
+	if (unhashed) {
+		put_clnt_odstate(dp->dl_clnt_odstate);
+		nfs4_put_deleg_lease(dp->dl_stid.sc_file);
+		nfs4_put_stid(&dp->dl_stid);
+	}
 }
 
 static void revoke_delegation(struct nfs4_delegation *dp)
@@ -1730,7 +1738,7 @@ __destroy_client(struct nfs4_client *clp)
 	spin_lock(&state_lock);
 	while (!list_empty(&clp->cl_delegations)) {
 		dp = list_entry(clp->cl_delegations.next, struct nfs4_delegation, dl_perclnt);
-		unhash_delegation_locked(dp);
+		WARN_ON(!unhash_delegation_locked(dp));
 		list_add(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&state_lock);
@@ -4357,7 +4365,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 			new_timeo = min(new_timeo, t);
 			break;
 		}
-		unhash_delegation_locked(dp);
+		WARN_ON(!unhash_delegation_locked(dp));
 		list_add(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&state_lock);
@@ -6314,7 +6322,7 @@ static u64 nfsd_find_all_delegations(struct nfs4_client *clp, u64 max,
 				continue;
 
 			atomic_inc(&clp->cl_refcount);
-			unhash_delegation_locked(dp);
+			WARN_ON(!unhash_delegation_locked(dp));
 			list_add(&dp->dl_recall_lru, victims);
 		}
 		++count;
@@ -6645,7 +6653,7 @@ nfs4_state_shutdown_net(struct net *net)
 	spin_lock(&state_lock);
 	list_for_each_safe(pos, next, &nn->del_recall_lru) {
 		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
-		unhash_delegation_locked(dp);
+		WARN_ON(!unhash_delegation_locked(dp));
 		list_add(&dp->dl_recall_lru, &reaplist);
 	}
 	spin_unlock(&state_lock);
-- 
2.4.3

