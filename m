Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:32866 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751766Ab1KVRw4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Nov 2011 12:52:56 -0500
Received: by iage36 with SMTP id e36so463045iag.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 Nov 2011 09:52:55 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [RFC] NFS: Cache state owners after files are closed
To: linux-nfs@vger.kernel.org
Date: Tue, 22 Nov 2011 12:52:53 -0500
Message-ID: <20111122174225.1866.25410.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Servers have a finite amount of memory to store NFSv4 open and lock
owners.  Moreover, servers may have a difficult time determining when
they can reap their state owner table, thanks to gray areas in the
NFSv4 protocol specification.  Thus clients should be careful to reuse
state owners when possible.

Currently Linux is not too careful.  When a user has closed all her
files on one mount point, the state owner's reference count goes to
zero, and it is released.  The next OPEN allocates a new one.  A
workload that serially opens and closes files can run through a large
number of open owners this way.

When a state owner's reference count goes to zero, slap it onto a free
list for that nfs_server, with an expiry time.  Garbage collect before
looking for a state owner.  This makes state owners for active users
available for re-use.

Now that there can be unused state owners remaining at umount time,
purge the state owner free list when a server is destroyed.  Also be
sure not to reclaim unused state owners during state recovery.

This change has benefits for the client as well.  For some workloads,
this approach drops the number of OPEN_CONFIRM calls from the same as
the number of OPEN calls, down to just one.  This reduces wire traffic
and thus open(2) latency.  Before this patch, untarring a kernel
source tarball shows the OPEN_CONFIRM call counter steadily increasing
through the test.  With the patch, the OPEN_CONFIRM count remains at 1
throughout the entire untar.

As long as the expiry time is kept short, I don't think garbage
collection should be terribly expensive, although it does bounce the
clp->cl_lock around a bit.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Request For Comments.  I'm sure there are some details that need to be
addressed.  I've done some light testing.

 fs/nfs/client.c           |    8 +++++
 fs/nfs/nfs4_fs.h          |    3 ++
 fs/nfs/nfs4state.c        |   76 ++++++++++++++++++++++++++++++++++++++++-----
 include/linux/nfs_fs_sb.h |    1 +
 4 files changed, 80 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index dc5f311..c7e3e80 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -257,6 +257,11 @@ static void pnfs_init_server(struct nfs_server *server)
 	rpc_init_wait_queue(&server->roc_rpcwaitq, "pNFS ROC");
 }
 
+static void nfs4_destroy_server(struct nfs_server *server)
+{
+	nfs4_purge_state_owners(server);
+}
+
 #else
 static void nfs4_shutdown_client(struct nfs_client *clp)
 {
@@ -1089,6 +1094,7 @@ static struct nfs_server *nfs_alloc_server(void)
 	INIT_LIST_HEAD(&server->master_link);
 	INIT_LIST_HEAD(&server->delegations);
 	INIT_LIST_HEAD(&server->layouts);
+	INIT_LIST_HEAD(&server->state_owners_lru);
 
 	atomic_set(&server->active, 0);
 
@@ -1739,6 +1745,7 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 		goto error;
 
 	dprintk("<-- nfs4_create_server() = %p\n", server);
+	server->destroy = nfs4_destroy_server;
 	return server;
 
 error:
@@ -1792,6 +1799,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 		goto error;
 
 	dprintk("<-- nfs_create_referral_server() = %p\n", server);
+	server->destroy = nfs4_destroy_server;
 	return server;
 
 error:
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index f792220..752fe17 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -122,6 +122,8 @@ struct nfs_unique_id {
 struct nfs4_state_owner {
 	struct nfs_unique_id so_owner_id;
 	struct nfs_server    *so_server;
+	struct list_head     so_lru;
+	unsigned long        so_expires;
 	struct rb_node	     so_server_node;
 
 	struct rpc_cred	     *so_cred;	 /* Associated cred */
@@ -360,6 +362,7 @@ static inline void nfs4_schedule_session_recovery(struct nfs4_session *session)
 
 extern struct nfs4_state_owner * nfs4_get_state_owner(struct nfs_server *, struct rpc_cred *);
 extern void nfs4_put_state_owner(struct nfs4_state_owner *);
+extern void nfs4_purge_state_owners(struct nfs_server *);
 extern struct nfs4_state * nfs4_get_open_state(struct inode *, struct nfs4_state_owner *);
 extern void nfs4_put_open_state(struct nfs4_state *);
 extern void nfs4_close_state(struct nfs4_state *, fmode_t);
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 221baf8..35ae743 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -49,6 +49,7 @@
 #include <linux/ratelimit.h>
 #include <linux/workqueue.h>
 #include <linux/bitops.h>
+#include <linux/jiffies.h>
 
 #include "nfs4_fs.h"
 #include "callback.h"
@@ -455,6 +456,7 @@ nfs4_alloc_state_owner(void)
 	spin_lock_init(&sp->so_sequence.lock);
 	INIT_LIST_HEAD(&sp->so_sequence.list);
 	atomic_set(&sp->so_count, 1);
+	INIT_LIST_HEAD(&sp->so_lru);
 	return sp;
 }
 
@@ -466,12 +468,47 @@ nfs4_drop_state_owner(struct nfs4_state_owner *sp)
 		struct nfs_client *clp = server->nfs_client;
 
 		spin_lock(&clp->cl_lock);
+		list_del_init(&sp->so_lru);
 		rb_erase(&sp->so_server_node, &server->state_owners);
 		RB_CLEAR_NODE(&sp->so_server_node);
 		spin_unlock(&clp->cl_lock);
 	}
 }
 
+static void nfs4_release_state_owner(struct nfs4_state_owner *sp)
+{
+	struct nfs_client *clp = sp->so_server->nfs_client;
+
+	spin_lock(&clp->cl_lock);
+	nfs4_remove_state_owner_locked(sp);
+	spin_unlock(&clp->cl_lock);
+	rpc_destroy_wait_queue(&sp->so_sequence.wait);
+	put_rpccred(sp->so_cred);
+	kfree(sp);
+}
+
+static void nfs4_gc_state_owners(struct nfs_server *server)
+{
+	struct nfs_client *clp = server->nfs_client;
+	struct nfs4_state_owner *sp, *tmp;
+	unsigned long now = jiffies;
+	LIST_HEAD(doomed);
+
+	spin_lock(&clp->cl_lock);
+	list_for_each_entry_safe(sp, tmp, &server->state_owners_lru, so_lru) {
+		/* NB: LRU is sorted so that oldest is at the head */
+		if (time_before(now, sp->so_expires))
+			break;
+		list_move(&sp->so_lru, &doomed);
+	}
+	spin_unlock(&clp->cl_lock);
+
+	list_for_each_entry_safe(sp, tmp, &doomed, so_lru) {
+		list_del_init(&sp->so_lru);
+		nfs4_release_state_owner(sp);
+	}
+}
+
 /**
  * nfs4_get_state_owner - Look up a state owner given a credential
  * @server: nfs_server to search
@@ -485,11 +522,13 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
 	struct nfs_client *clp = server->nfs_client;
 	struct nfs4_state_owner *sp, *new;
 
+	nfs4_gc_state_owners(server);
+
 	spin_lock(&clp->cl_lock);
 	sp = nfs4_find_state_owner_locked(server, cred);
 	spin_unlock(&clp->cl_lock);
 	if (sp != NULL)
-		return sp;
+		goto out;
 	new = nfs4_alloc_state_owner();
 	if (new == NULL)
 		return NULL;
@@ -504,26 +543,46 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
 		rpc_destroy_wait_queue(&new->so_sequence.wait);
 		kfree(new);
 	}
+out:
+	list_del_init(&sp->so_lru);
 	return sp;
 }
 
 /**
  * nfs4_put_state_owner - Release a nfs4_state_owner
  * @sp: state owner data to release
- *
  */
 void nfs4_put_state_owner(struct nfs4_state_owner *sp)
 {
-	struct nfs_client *clp = sp->so_server->nfs_client;
-	struct rpc_cred *cred = sp->so_cred;
+	struct nfs_server *server = sp->so_server;
+	struct nfs_client *clp = server->nfs_client;
 
 	if (!atomic_dec_and_lock(&sp->so_count, &clp->cl_lock))
 		return;
-	nfs4_remove_state_owner_locked(sp);
+	sp->so_expires = jiffies + clp->cl_lease_time;
+	list_move_tail(&sp->so_lru, &server->state_owners_lru);
 	spin_unlock(&clp->cl_lock);
-	rpc_destroy_wait_queue(&sp->so_sequence.wait);
-	put_rpccred(cred);
-	kfree(sp);
+}
+
+/**
+ * nfs4_purge_state_owners - Release cached state owners
+ * @server: nfs_server with cached state owners to release
+ *
+ * Called at umount time.  Any remaining state owners will be on
+ * the LRU with ref count of zero.
+ */
+void nfs4_purge_state_owners(struct nfs_server *server)
+{
+	struct nfs_client *clp = server->nfs_client;
+	unsigned long now = jiffies;
+	struct nfs4_state_owner *sp;
+
+	spin_lock(&clp->cl_lock);
+	list_for_each_entry(sp, &server->state_owners_lru, so_lru)
+		sp->so_expires = now - 1;
+	spin_unlock(&clp->cl_lock);
+
+	nfs4_gc_state_owners(server);
 }
 
 static struct nfs4_state *
@@ -1440,6 +1499,7 @@ static int nfs4_do_reclaim(struct nfs_client *clp, const struct nfs4_state_recov
 restart:
 	rcu_read_lock();
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
+		nfs4_purge_state_owners(server);
 		spin_lock(&clp->cl_lock);
 		for (pos = rb_first(&server->state_owners);
 		     pos != NULL;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 87ea88d80..b458f99 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -161,6 +161,7 @@ struct nfs_server {
 	struct rb_root		openowner_id;
 	struct rb_root		lockowner_id;
 #endif
+	struct list_head	state_owners_lru;
 	struct list_head	layouts;
 	struct list_head	delegations;
 	void (*destroy)(struct nfs_server *);

