Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:37545 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756946Ab2ADVwN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jan 2012 16:52:13 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix a few issues with cached state owners
Date: Wed,  4 Jan 2012 16:52:07 -0500
Message-Id: <1325713927-25519-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1325697256.18462.24.camel@lade.trondhjem.org>
References: <1325697256.18462.24.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The garbage collector needs to remove the entry from the lru list
_and_ the red-black tree atomically in order avoid races in
nfs4_get_state_owner.

Fix a case in nfs4_get_state_owner in which the garbage-collector
list was being manipulated while not holding the appropriate spin
lock.

nfs4_drop_state_owner doesn't need to look at sp->so_lru: the caller
must have a reference to the state owner, so it can't be on the
garbage-collection list.

Run the garbage collector _after_ we've looked up the state owner
for efficiency reasons.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4state.c |   23 ++++++++++++++++-------
 1 files changed, 16 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index b9ade99..dc78e0e 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -389,6 +389,8 @@ nfs4_find_state_owner_locked(struct nfs_server *server, struct rpc_cred *cred)
 		else if (cred > sp->so_cred)
 			p = &parent->rb_right;
 		else {
+			if (!list_empty(&sp->so_lru))
+				list_del_init(&sp->so_lru);
 			atomic_inc(&sp->so_count);
 			return sp;
 		}
@@ -413,6 +415,8 @@ nfs4_insert_state_owner_locked(struct nfs4_state_owner *new)
 		else if (new->so_cred > sp->so_cred)
 			p = &parent->rb_right;
 		else {
+			if (!list_empty(&sp->so_lru))
+				list_del_init(&sp->so_lru);
 			atomic_inc(&sp->so_count);
 			return sp;
 		}
@@ -459,6 +463,13 @@ nfs4_alloc_state_owner(void)
 }
 
 static void
+nfs4_drop_state_owner_locked(struct nfs_server *server, struct nfs4_state_owner *sp)
+{
+	rb_erase(&sp->so_server_node, &server->state_owners);
+	RB_CLEAR_NODE(&sp->so_server_node);
+}
+
+static void
 nfs4_drop_state_owner(struct nfs4_state_owner *sp)
 {
 	if (!RB_EMPTY_NODE(&sp->so_server_node)) {
@@ -466,9 +477,8 @@ nfs4_drop_state_owner(struct nfs4_state_owner *sp)
 		struct nfs_client *clp = server->nfs_client;
 
 		spin_lock(&clp->cl_lock);
-		list_del_init(&sp->so_lru);
-		rb_erase(&sp->so_server_node, &server->state_owners);
-		RB_CLEAR_NODE(&sp->so_server_node);
+		if (!RB_EMPTY_NODE(&sp->so_server_node))
+			nfs4_drop_state_owner_locked(server, sp);
 		spin_unlock(&clp->cl_lock);
 	}
 }
@@ -499,6 +509,7 @@ static void nfs4_gc_state_owners(struct nfs_server *server)
 				sp->so_expires + clp->cl_lease_time))
 			break;
 		list_move(&sp->so_lru, &doomed);
+		nfs4_drop_state_owner_locked(server, sp);
 	}
 	spin_unlock(&clp->cl_lock);
 
@@ -521,8 +532,6 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs4_state_owner *sp, *new;
 
-	nfs4_gc_state_owners(server);
-
 	spin_lock(&clp->cl_lock);
 	sp = nfs4_find_state_owner_locked(server, cred);
 	spin_unlock(&clp->cl_lock);
@@ -530,7 +539,7 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
 		goto out;
 	new = nfs4_alloc_state_owner();
 	if (new == NULL)
-		return NULL;
+		goto out;
 	new->so_server = server;
 	new->so_cred = cred;
 	spin_lock(&clp->cl_lock);
@@ -543,7 +552,7 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
 		kfree(new);
 	}
 out:
-	list_del_init(&sp->so_lru);
+	nfs4_gc_state_owners(server);
 	return sp;
 }
 
-- 
1.7.7.5

