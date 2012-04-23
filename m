Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64858 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753828Ab2DWUhC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Apr 2012 16:37:02 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFSv4: Ensure that we don't drop a state owner more than once
Date: Mon, 23 Apr 2012 16:36:53 -0400
Message-Id: <1335213414-20826-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1335213414-20826-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1335213414-20826-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Retest the RB_EMPTY_NODE() condition under the spin lock
to ensure that we don't call rb_erase() more than once on the
same state owner.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4state.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 3b07f09..b300fb8 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -435,13 +435,17 @@ nfs4_alloc_state_owner(struct nfs_server *server,
 static void
 nfs4_drop_state_owner(struct nfs4_state_owner *sp)
 {
-	if (!RB_EMPTY_NODE(&sp->so_server_node)) {
+	struct rb_node *rb_node = &sp->so_server_node;
+
+	if (!RB_EMPTY_NODE(rb_node)) {
 		struct nfs_server *server = sp->so_server;
 		struct nfs_client *clp = server->nfs_client;
 
 		spin_lock(&clp->cl_lock);
-		rb_erase(&sp->so_server_node, &server->state_owners);
-		RB_CLEAR_NODE(&sp->so_server_node);
+		if (!RB_EMPTY_NODE(rb_node)) {
+			rb_erase(rb_node, &server->state_owners);
+			RB_CLEAR_NODE(rb_node);
+		}
 		spin_unlock(&clp->cl_lock);
 	}
 }
-- 
1.7.7.6

