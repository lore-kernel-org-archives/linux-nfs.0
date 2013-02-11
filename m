Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:27966 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758718Ab3BKTaS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2013 14:30:18 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/6] NFSv4: Allow the state manager to mark an open_owner as being recovered
Date: Mon, 11 Feb 2013 14:29:21 -0500
Message-Id: <1360610966-15398-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1360610966-15398-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1360610966-15398-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds a seqcount_t lock for use by the state manager to
signal that an open owner has been recovered. This mechanism will be
used by the delegation, open and byte range lock code in order to
figure out if they need to replay requests due to collisions with
lock recovery.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h   | 3 +++
 fs/nfs/nfs4state.c | 9 ++++++++-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index a3f488b..b12b734 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -13,6 +13,8 @@
 
 #define NFS4_MAX_LOOP_ON_RECOVER (10)
 
+#include <linux/seqlock.h>
+
 struct idmap;
 
 enum nfs4_client_state {
@@ -90,6 +92,7 @@ struct nfs4_state_owner {
 	unsigned long	     so_flags;
 	struct list_head     so_states;
 	struct nfs_seqid_counter so_seqid;
+	seqcount_t	     so_reclaim_seqcount;
 };
 
 enum {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index e61f68d..77ba619 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -518,6 +518,7 @@ nfs4_alloc_state_owner(struct nfs_server *server,
 	nfs4_init_seqid_counter(&sp->so_seqid);
 	atomic_set(&sp->so_count, 1);
 	INIT_LIST_HEAD(&sp->so_lru);
+	seqcount_init(&sp->so_reclaim_seqcount);
 	return sp;
 }
 
@@ -1390,8 +1391,9 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 	 * recovering after a network partition or a reboot from a
 	 * server that doesn't support a grace period.
 	 */
-restart:
 	spin_lock(&sp->so_lock);
+	write_seqcount_begin(&sp->so_reclaim_seqcount);
+restart:
 	list_for_each_entry(state, &sp->so_states, open_states) {
 		if (!test_and_clear_bit(ops->state_flag_bit, &state->flags))
 			continue;
@@ -1449,12 +1451,17 @@ restart:
 				goto out_err;
 		}
 		nfs4_put_open_state(state);
+		spin_lock(&sp->so_lock);
 		goto restart;
 	}
+	write_seqcount_end(&sp->so_reclaim_seqcount);
 	spin_unlock(&sp->so_lock);
 	return 0;
 out_err:
 	nfs4_put_open_state(state);
+	spin_lock(&sp->so_lock);
+	write_seqcount_end(&sp->so_reclaim_seqcount);
+	spin_unlock(&sp->so_lock);
 	return status;
 }
 
-- 
1.8.1.2

