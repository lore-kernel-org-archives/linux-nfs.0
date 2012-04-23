Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:39854 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754240Ab2DWUhD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Apr 2012 16:37:03 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFSv4: Keep dropped state owners on the LRU list for a while
Date: Mon, 23 Apr 2012 16:36:54 -0400
Message-Id: <1335213414-20826-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335213414-20826-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1335213414-20826-1-git-send-email-Trond.Myklebust@netapp.com>
 <1335213414-20826-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To ensure that we don't reuse their identifiers.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4state.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b300fb8..7f0fcfc 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -521,6 +521,14 @@ out:
 /**
  * nfs4_put_state_owner - Release a nfs4_state_owner
  * @sp: state owner data to release
+ *
+ * Note that we keep released state owners on an LRU
+ * list.
+ * This caches valid state owners so that they can be
+ * reused, to avoid the OPEN_CONFIRM on minor version 0.
+ * It also pins the uniquifier of dropped state owners for
+ * a while, to ensure that those state owner names are
+ * never reused.
  */
 void nfs4_put_state_owner(struct nfs4_state_owner *sp)
 {
@@ -530,15 +538,9 @@ void nfs4_put_state_owner(struct nfs4_state_owner *sp)
 	if (!atomic_dec_and_lock(&sp->so_count, &clp->cl_lock))
 		return;
 
-	if (!RB_EMPTY_NODE(&sp->so_server_node)) {
-		sp->so_expires = jiffies;
-		list_add_tail(&sp->so_lru, &server->state_owners_lru);
-		spin_unlock(&clp->cl_lock);
-	} else {
-		nfs4_remove_state_owner_locked(sp);
-		spin_unlock(&clp->cl_lock);
-		nfs4_free_state_owner(sp);
-	}
+	sp->so_expires = jiffies;
+	list_add_tail(&sp->so_lru, &server->state_owners_lru);
+	spin_unlock(&clp->cl_lock);
 }
 
 /**
-- 
1.7.7.6

