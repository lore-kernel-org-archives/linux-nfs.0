Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:53618 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753118Ab2AQTNk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 14:13:40 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/8] NFSv4: Replace state_owner->so_owner_id with an ida based allocator
Date: Tue, 17 Jan 2012 14:13:28 -0500
Message-Id: <1326827613-7997-3-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1326827613-7997-2-git-send-email-Trond.Myklebust@netapp.com>
References: <1326827613-7997-1-git-send-email-Trond.Myklebust@netapp.com>
 <1326827613-7997-2-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're unlikely to ever need more than 2^31 simultaneous open owners,
so let's replace the custom allocator with the generic ida allocator.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c           |    2 ++
 fs/nfs/nfs4_fs.h          |    2 +-
 fs/nfs/nfs4proc.c         |    4 ++--
 fs/nfs/nfs4state.c        |   17 ++++++++++++-----
 include/linux/nfs_fs_sb.h |    3 ++-
 5 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ca9a4aa..8d1739d 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1092,6 +1092,7 @@ static struct nfs_server *nfs_alloc_server(void)
 		return NULL;
 	}
 
+	ida_init(&server->openowner_id);
 	pnfs_init_server(server);
 
 	return server;
@@ -1117,6 +1118,7 @@ void nfs_free_server(struct nfs_server *server)
 
 	nfs_put_client(server->nfs_client);
 
+	ida_destroy(&server->openowner_id);
 	nfs_free_iostats(server->io_stats);
 	bdi_destroy(&server->backing_dev_info);
 	kfree(server);
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 6d439c2..a754f47 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -92,7 +92,6 @@ struct nfs_unique_id {
  * semantics by allowing the server to identify replayed requests.
  */
 struct nfs4_state_owner {
-	struct nfs_unique_id so_owner_id;
 	struct nfs_server    *so_server;
 	struct list_head     so_lru;
 	unsigned long        so_expires;
@@ -106,6 +105,7 @@ struct nfs4_state_owner {
 	struct list_head     so_states;
 	struct nfs_seqid_counter so_seqid;
 	struct rpc_sequence  so_sequence;
+	int		     so_owner_id;
 };
 
 enum {
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4072754..1ddedf0 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -815,7 +815,7 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct dentry *dentry,
 	p->o_arg.open_flags = flags;
 	p->o_arg.fmode = fmode & (FMODE_READ|FMODE_WRITE);
 	p->o_arg.clientid = server->nfs_client->cl_clientid;
-	p->o_arg.id = sp->so_owner_id.id;
+	p->o_arg.id = sp->so_owner_id;
 	p->o_arg.name = &dentry->d_name;
 	p->o_arg.server = server;
 	p->o_arg.bitmask = server->attr_bitmask;
@@ -1440,7 +1440,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 		rcu_read_unlock();
 	}
 	/* Update sequence id. */
-	data->o_arg.id = sp->so_owner_id.id;
+	data->o_arg.id = sp->so_owner_id;
 	data->o_arg.clientid = sp->so_server->nfs_client->cl_clientid;
 	if (data->o_arg.claim == NFS4_OPEN_CLAIM_PREVIOUS) {
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_NOATTR];
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a8a42a6..8472707 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -405,6 +405,7 @@ nfs4_insert_state_owner_locked(struct nfs4_state_owner *new)
 	struct rb_node **p = &server->state_owners.rb_node,
 		       *parent = NULL;
 	struct nfs4_state_owner *sp;
+	int err;
 
 	while (*p != NULL) {
 		parent = *p;
@@ -421,8 +422,9 @@ nfs4_insert_state_owner_locked(struct nfs4_state_owner *new)
 			return sp;
 		}
 	}
-	nfs_alloc_unique_id_locked(&server->openowner_id,
-					&new->so_owner_id, 1, 64);
+	err = ida_get_new(&server->openowner_id, &new->so_owner_id);
+	if (err)
+		return ERR_PTR(err);
 	rb_link_node(&new->so_server_node, parent, p);
 	rb_insert_color(&new->so_server_node, &server->state_owners);
 	return new;
@@ -435,7 +437,7 @@ nfs4_remove_state_owner_locked(struct nfs4_state_owner *sp)
 
 	if (!RB_EMPTY_NODE(&sp->so_server_node))
 		rb_erase(&sp->so_server_node, &server->state_owners);
-	nfs_free_unique_id(&server->openowner_id, &sp->so_owner_id);
+	ida_remove(&server->openowner_id, sp->so_owner_id);
 }
 
 /*
@@ -534,8 +536,13 @@ struct nfs4_state_owner *nfs4_get_state_owner(struct nfs_server *server,
 	new = nfs4_alloc_state_owner(server, cred, gfp_flags);
 	if (new == NULL)
 		goto out;
-	sp = nfs4_insert_state_owner_locked(new);
-	spin_unlock(&clp->cl_lock);
+	do {
+		if (ida_pre_get(&server->openowner_id, gfp_flags) == 0)
+			break;
+		spin_lock(&clp->cl_lock);
+		sp = nfs4_insert_state_owner_locked(new);
+		spin_unlock(&clp->cl_lock);
+	} while (sp == ERR_PTR(-EAGAIN));
 	if (sp != new)
 		nfs4_free_state_owner(new);
 out:
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index e0863d3..645537e 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -3,6 +3,7 @@
 
 #include <linux/list.h>
 #include <linux/backing-dev.h>
+#include <linux/idr.h>
 #include <linux/wait.h>
 #include <linux/nfs_xdr.h>
 #include <linux/sunrpc/xprt.h>
@@ -151,9 +152,9 @@ struct nfs_server {
 
 	/* the following fields are protected by nfs_client->cl_lock */
 	struct rb_root		state_owners;
-	struct rb_root		openowner_id;
 	struct rb_root		lockowner_id;
 #endif
+	struct ida		openowner_id;
 	struct list_head	state_owners_lru;
 	struct list_head	layouts;
 	struct list_head	delegations;
-- 
1.7.7.5

