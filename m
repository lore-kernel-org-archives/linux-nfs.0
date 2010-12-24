Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60343 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752527Ab0LXBdI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Dec 2010 20:33:08 -0500
Received: by mail-iw0-f174.google.com with SMTP id 9so6655796iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 23 Dec 2010 17:33:08 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/4] NFS: Move cl_delegations to the nfs_server struct
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 23 Dec 2010 20:33:04 -0500
Message-ID: <20101224013304.2445.53552.stgit@matisse.1015granger.net>
In-Reply-To: <20101224012636.2445.41411.stgit@matisse.1015granger.net>
References: <20101224012636.2445.41411.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Delegations are per-inode, not per-nfs_client.  When a server file
system is migrated, delegations on the client must be moved from the
source to the destination nfs_server.  Make it easier to manage a
mount point's delegation list across a migration event by moving the
list to the nfs_server struct.

Clean up: I added documenting comments to public functions I changed
in this patch.  For consistency I added comments to all the other
public functions in fs/nfs/delegation.c.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |    2 
 fs/nfs/delegation.c       |  337 +++++++++++++++++++++++++++++++++------------
 fs/nfs/delegation.h       |    1 
 fs/nfs/nfs4renewd.c       |    2 
 include/linux/nfs_fs_sb.h |    2 
 5 files changed, 251 insertions(+), 93 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 05e2ee2..4007031 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -144,7 +144,6 @@ static struct nfs_client *nfs_alloc_client(const struct nfs_client_initdata *cl_
 	clp->cl_proto = cl_init->proto;
 
 #ifdef CONFIG_NFS_V4
-	INIT_LIST_HEAD(&clp->cl_delegations);
 	spin_lock_init(&clp->cl_lock);
 	INIT_DELAYED_WORK(&clp->cl_renewd, nfs4_renew_state);
 	rpc_init_wait_queue(&clp->cl_rpcwaitq, "NFS client");
@@ -1025,6 +1024,7 @@ static struct nfs_server *nfs_alloc_server(void)
 	/* Zero out the NFS state stuff */
 	INIT_LIST_HEAD(&server->client_link);
 	INIT_LIST_HEAD(&server->master_link);
+	INIT_LIST_HEAD(&server->delegations);
 
 	atomic_set(&server->active, 0);
 
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 521d71b..364e432 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -40,11 +40,23 @@ static void nfs_free_delegation(struct nfs_delegation *delegation)
 	call_rcu(&delegation->rcu, nfs_free_delegation_callback);
 }
 
+/**
+ * nfs_mark_delegation_referenced - set delegation's REFERENCED flag
+ * @delegation: delegation to process
+ *
+ */
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation)
 {
 	set_bit(NFS_DELEGATION_REFERENCED, &delegation->flags);
 }
 
+/**
+ * nfs_have_delegation - check if inode has a delegation
+ * @inode: inode to check
+ * @flags: delegation types to check for
+ *
+ * Returns one if inode has the indicated delegation, otherwise zero.
+ */
 int nfs_have_delegation(struct inode *inode, fmode_t flags)
 {
 	struct nfs_delegation *delegation;
@@ -119,10 +131,15 @@ again:
 	return 0;
 }
 
-/*
- * Set up a delegation on an inode
+/**
+ * nfs_inode_reclaim_delegation - process a delegation reclaim request
+ * @inode: inode to process
+ * @cred: credential to use for request
+ * @res: new delegation state from server
+ *
  */
-void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res)
+void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred,
+				  struct nfs_openres *res)
 {
 	struct nfs_delegation *delegation;
 	struct rpc_cred *oldcred = NULL;
@@ -177,11 +194,11 @@ static struct inode *nfs_delegation_grab_inode(struct nfs_delegation *delegation
 
 static struct nfs_delegation *
 nfs_detach_delegation_locked(struct nfs_inode *nfsi,
-			     struct nfs_client *clp)
+			     struct nfs_server *server)
 {
 	struct nfs_delegation *delegation =
 		rcu_dereference_protected(nfsi->delegation,
-					  lockdep_is_held(&clp->cl_lock));
+				lockdep_is_held(&server->nfs_client->cl_lock));
 
 	if (delegation == NULL)
 		goto nomatch;
@@ -198,22 +215,29 @@ nomatch:
 }
 
 static struct nfs_delegation *nfs_detach_delegation(struct nfs_inode *nfsi,
-						    struct nfs_client *clp)
+						    struct nfs_server *server)
 {
+	struct nfs_client *clp = server->nfs_client;
 	struct nfs_delegation *delegation;
 
 	spin_lock(&clp->cl_lock);
-	delegation = nfs_detach_delegation_locked(nfsi, clp);
+	delegation = nfs_detach_delegation_locked(nfsi, server);
 	spin_unlock(&clp->cl_lock);
 	return delegation;
 }
 
-/*
- * Set up a delegation on an inode
+/**
+ * nfs_inode_set_delegation - set up a delegation on an inode
+ * @inode: inode to which delegation applies
+ * @cred: cred to use for subsequent delegation processing
+ * @res: new delegation state from server
+ *
+ * Returns zero on success, or a negative errno value.
  */
 int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res)
 {
-	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs_client *clp = server->nfs_client;
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_delegation *delegation, *old_delegation;
 	struct nfs_delegation *freeme = NULL;
@@ -234,7 +258,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 
 	spin_lock(&clp->cl_lock);
 	old_delegation = rcu_dereference_protected(nfsi->delegation,
-						   lockdep_is_held(&clp->cl_lock));
+					lockdep_is_held(&clp->cl_lock));
 	if (old_delegation != NULL) {
 		if (memcmp(&delegation->stateid, &old_delegation->stateid,
 					sizeof(old_delegation->stateid)) == 0 &&
@@ -253,9 +277,9 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 			delegation = NULL;
 			goto out;
 		}
-		freeme = nfs_detach_delegation_locked(nfsi, clp);
+		freeme = nfs_detach_delegation_locked(nfsi, server);
 	}
-	list_add_rcu(&delegation->super_list, &clp->cl_delegations);
+	list_add_rcu(&delegation->super_list, &server->delegations);
 	nfsi->delegation_state = delegation->type;
 	rcu_assign_pointer(nfsi->delegation, delegation);
 	delegation = NULL;
@@ -297,67 +321,85 @@ out:
 	return err;
 }
 
-/*
- * Return all delegations that have been marked for return
+/**
+ * nfs_client_return_marked_delegations - return previously marked delegations
+ * @clp: nfs_client to process
+ *
+ * Returns zero on success, or a negative errno value.
  */
 int nfs_client_return_marked_delegations(struct nfs_client *clp)
 {
 	struct nfs_delegation *delegation;
+	struct nfs_server *server;
 	struct inode *inode;
 	int err = 0;
 
 restart:
 	rcu_read_lock();
-	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
-		if (!test_and_clear_bit(NFS_DELEGATION_RETURN, &delegation->flags))
-			continue;
-		inode = nfs_delegation_grab_inode(delegation);
-		if (inode == NULL)
-			continue;
-		delegation = nfs_detach_delegation(NFS_I(inode), clp);
-		rcu_read_unlock();
-		if (delegation != NULL) {
-			filemap_flush(inode->i_mapping);
-			err = __nfs_inode_return_delegation(inode, delegation, 0);
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
+		list_for_each_entry_rcu(delegation, &server->delegations,
+								super_list) {
+			if (!test_and_clear_bit(NFS_DELEGATION_RETURN,
+							&delegation->flags))
+				continue;
+			inode = nfs_delegation_grab_inode(delegation);
+			if (inode == NULL)
+				continue;
+			delegation = nfs_detach_delegation(NFS_I(inode),
+								server);
+			rcu_read_unlock();
+
+			if (delegation != NULL) {
+				filemap_flush(inode->i_mapping);
+				err = __nfs_inode_return_delegation(inode,
+								delegation, 0);
+			}
+			iput(inode);
+			if (!err)
+				goto restart;
+			set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
+			return err;
 		}
-		iput(inode);
-		if (!err)
-			goto restart;
-		set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
-		return err;
 	}
 	rcu_read_unlock();
 	return 0;
 }
 
-/*
- * This function returns the delegation without reclaiming opens
- * or protecting against delegation reclaims.
- * It is therefore really only safe to be called from
- * nfs4_clear_inode()
+/**
+ * nfs_inode_return_delegation_noreclaim - return delegation, don't reclaim opens
+ * @inode: inode to process
+ *
+ * Does not protect against delegation reclaims, therefore really only safe
+ * to be called from nfs4_clear_inode().
  */
 void nfs_inode_return_delegation_noreclaim(struct inode *inode)
 {
-	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
+	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_delegation *delegation;
 
 	if (rcu_access_pointer(nfsi->delegation) != NULL) {
-		delegation = nfs_detach_delegation(nfsi, clp);
+		delegation = nfs_detach_delegation(nfsi, server);
 		if (delegation != NULL)
 			nfs_do_return_delegation(inode, delegation, 0);
 	}
 }
 
+/**
+ * nfs_inode_return_delegation - synchronously return a delegation
+ * @inode: inode to process
+ *
+ * Returns zero on success, or a negative errno value.
+ */
 int nfs_inode_return_delegation(struct inode *inode)
 {
-	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
+	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_delegation *delegation;
 	int err = 0;
 
 	if (rcu_access_pointer(nfsi->delegation) != NULL) {
-		delegation = nfs_detach_delegation(nfsi, clp);
+		delegation = nfs_detach_delegation(nfsi, server);
 		if (delegation != NULL) {
 			nfs_wb_all(inode);
 			err = __nfs_inode_return_delegation(inode, delegation, 1);
@@ -366,46 +408,61 @@ int nfs_inode_return_delegation(struct inode *inode)
 	return err;
 }
 
-static void nfs_mark_return_delegation(struct nfs_client *clp, struct nfs_delegation *delegation)
+static void nfs_mark_return_delegation(struct nfs_delegation *delegation)
 {
+	struct nfs_client *clp = NFS_SERVER(delegation->inode)->nfs_client;
+
 	set_bit(NFS_DELEGATION_RETURN, &delegation->flags);
 	set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
 }
 
-/*
- * Return all delegations associated to a super block
+/**
+ * nfs_super_return_all_delegations - return delegations for one superblock
+ * @sb: sb to process
+ *
  */
 void nfs_super_return_all_delegations(struct super_block *sb)
 {
-	struct nfs_client *clp = NFS_SB(sb)->nfs_client;
+	struct nfs_server *server = NFS_SB(sb);
+	struct nfs_client *clp = server->nfs_client;
 	struct nfs_delegation *delegation;
 
 	if (clp == NULL)
 		return;
+
 	rcu_read_lock();
-	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
+	list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
 		spin_lock(&delegation->lock);
-		if (delegation->inode != NULL && delegation->inode->i_sb == sb)
-			set_bit(NFS_DELEGATION_RETURN, &delegation->flags);
+		set_bit(NFS_DELEGATION_RETURN, &delegation->flags);
 		spin_unlock(&delegation->lock);
 	}
 	rcu_read_unlock();
+
 	if (nfs_client_return_marked_delegations(clp) != 0)
 		nfs4_schedule_state_manager(clp);
 }
 
-static
-void nfs_client_mark_return_all_delegation_types(struct nfs_client *clp, fmode_t flags)
+static void nfs_mark_return_all_delegation_types(struct nfs_server *server,
+						 fmode_t flags)
 {
 	struct nfs_delegation *delegation;
 
-	rcu_read_lock();
-	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
+	list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
 		if ((delegation->type == (FMODE_READ|FMODE_WRITE)) && !(flags & FMODE_WRITE))
 			continue;
 		if (delegation->type & flags)
-			nfs_mark_return_delegation(clp, delegation);
+			nfs_mark_return_delegation(delegation);
 	}
+}
+
+static void nfs_client_mark_return_all_delegation_types(struct nfs_client *clp,
+							fmode_t flags)
+{
+	struct nfs_server *server;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link)
+		nfs_mark_return_all_delegation_types(server, flags);
 	rcu_read_unlock();
 }
 
@@ -420,19 +477,32 @@ static void nfs_delegation_run_state_manager(struct nfs_client *clp)
 		nfs4_schedule_state_manager(clp);
 }
 
+/**
+ * nfs_expire_all_delegation_types
+ * @clp: client to process
+ * @flags: delegation types to expire
+ *
+ */
 void nfs_expire_all_delegation_types(struct nfs_client *clp, fmode_t flags)
 {
 	nfs_client_mark_return_all_delegation_types(clp, flags);
 	nfs_delegation_run_state_manager(clp);
 }
 
+/**
+ * nfs_expire_all_delegations
+ * @clp: client to process
+ *
+ */
 void nfs_expire_all_delegations(struct nfs_client *clp)
 {
 	nfs_expire_all_delegation_types(clp, FMODE_READ|FMODE_WRITE);
 }
 
-/*
- * Return all delegations following an NFS4ERR_CB_PATH_DOWN error.
+/**
+ * nfs_handle_cb_pathdown - return all delegations after NFS4ERR_CB_PATH_DOWN
+ * @clp: client to process
+ *
  */
 void nfs_handle_cb_pathdown(struct nfs_client *clp)
 {
@@ -441,29 +511,43 @@ void nfs_handle_cb_pathdown(struct nfs_client *clp)
 	nfs_client_mark_return_all_delegations(clp);
 }
 
-static void nfs_client_mark_return_unreferenced_delegations(struct nfs_client *clp)
+static void nfs_mark_return_unreferenced_delegations(struct nfs_server *server)
 {
 	struct nfs_delegation *delegation;
 
-	rcu_read_lock();
-	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
+	list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
 		if (test_and_clear_bit(NFS_DELEGATION_REFERENCED, &delegation->flags))
 			continue;
-		nfs_mark_return_delegation(clp, delegation);
+		nfs_mark_return_delegation(delegation);
 	}
-	rcu_read_unlock();
 }
 
+/**
+ * nfs_expire_unreferenced_delegations - Eliminate unused delegations
+ * @clp: nfs_client to process
+ *
+ */
 void nfs_expire_unreferenced_delegations(struct nfs_client *clp)
 {
-	nfs_client_mark_return_unreferenced_delegations(clp);
+	struct nfs_server *server;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link)
+		nfs_mark_return_unreferenced_delegations(server);
+	rcu_read_unlock();
+
 	nfs_delegation_run_state_manager(clp);
 }
 
-/*
- * Asynchronous delegation recall!
+/**
+ * nfs_async_inode_return_delegation - asynchronously return a delegation
+ * @inode: inode to process
+ * @stateid: state ID information from CB_RECALL arguments
+ *
+ * Returns zero on success, or a negative errno value.
  */
-int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid)
+int nfs_async_inode_return_delegation(struct inode *inode,
+				      const nfs4_stateid *stateid)
 {
 	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
 	struct nfs_delegation *delegation;
@@ -475,22 +559,21 @@ int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *s
 		rcu_read_unlock();
 		return -ENOENT;
 	}
-
-	nfs_mark_return_delegation(clp, delegation);
+	nfs_mark_return_delegation(delegation);
 	rcu_read_unlock();
+
 	nfs_delegation_run_state_manager(clp);
 	return 0;
 }
 
-/*
- * Retrieve the inode associated with a delegation
- */
-struct inode *nfs_delegation_find_inode(struct nfs_client *clp, const struct nfs_fh *fhandle)
+static struct inode *
+nfs_delegation_find_inode_server(struct nfs_server *server,
+				 const struct nfs_fh *fhandle)
 {
 	struct nfs_delegation *delegation;
 	struct inode *res = NULL;
-	rcu_read_lock();
-	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
+
+	list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
 		spin_lock(&delegation->lock);
 		if (delegation->inode != NULL &&
 		    nfs_compare_fh(fhandle, &NFS_I(delegation->inode)->fh) == 0) {
@@ -500,47 +583,121 @@ struct inode *nfs_delegation_find_inode(struct nfs_client *clp, const struct nfs
 		if (res != NULL)
 			break;
 	}
+	return res;
+}
+
+/**
+ * nfs_delegation_find_inode - retrieve the inode associated with a delegation
+ * @clp: client state handle
+ * @fhandle: filehandle from a delegation recall
+ *
+ * Returns pointer to inode matching "fhandle," or NULL if a matching inode
+ * cannot be found.
+ */
+struct inode *nfs_delegation_find_inode(struct nfs_client *clp,
+					const struct nfs_fh *fhandle)
+{
+	struct nfs_server *server;
+	struct inode *res = NULL;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
+		res = nfs_delegation_find_inode_server(server, fhandle);
+		if (res != NULL)
+			break;
+	}
 	rcu_read_unlock();
 	return res;
 }
 
-/*
- * Mark all delegations as needing to be reclaimed
+static void nfs_delegation_mark_reclaim_server(struct nfs_server *server)
+{
+	struct nfs_delegation *delegation;
+
+	list_for_each_entry_rcu(delegation, &server->delegations, super_list)
+		set_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags);
+}
+
+/**
+ * nfs_delegation_mark_reclaim - mark all delegations as needing to be reclaimed
+ * @clp: nfs_client to process
+ *
  */
 void nfs_delegation_mark_reclaim(struct nfs_client *clp)
 {
-	struct nfs_delegation *delegation;
+	struct nfs_server *server;
+
 	rcu_read_lock();
-	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list)
-		set_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags);
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link)
+		nfs_delegation_mark_reclaim_server(server);
 	rcu_read_unlock();
 }
 
-/*
- * Reap all unclaimed delegations after reboot recovery is done
+/**
+ * nfs_delegation_reap_unclaimed - reap unclaimed delegations after reboot recovery is done
+ * @clp: nfs_client to process
+ *
  */
 void nfs_delegation_reap_unclaimed(struct nfs_client *clp)
 {
 	struct nfs_delegation *delegation;
+	struct nfs_server *server;
 	struct inode *inode;
+
 restart:
 	rcu_read_lock();
-	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
-		if (test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags) == 0)
-			continue;
-		inode = nfs_delegation_grab_inode(delegation);
-		if (inode == NULL)
-			continue;
-		delegation = nfs_detach_delegation(NFS_I(inode), clp);
-		rcu_read_unlock();
-		if (delegation != NULL)
-			nfs_free_delegation(delegation);
-		iput(inode);
-		goto restart;
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
+		list_for_each_entry_rcu(delegation, &server->delegations,
+								super_list) {
+			if (test_bit(NFS_DELEGATION_NEED_RECLAIM,
+						&delegation->flags) == 0)
+				continue;
+			inode = nfs_delegation_grab_inode(delegation);
+			if (inode == NULL)
+				continue;
+			delegation = nfs_detach_delegation(NFS_I(inode),
+								server);
+			rcu_read_unlock();
+
+			if (delegation != NULL)
+				nfs_free_delegation(delegation);
+			iput(inode);
+			goto restart;
+		}
 	}
 	rcu_read_unlock();
 }
 
+/**
+ * nfs_delegations_present - check for existence of delegations
+ * @clp: client state handle
+ *
+ * Returns one if there are any nfs_delegation structures attached
+ * to this nfs_client.
+ */
+int nfs_delegations_present(struct nfs_client *clp)
+{
+	struct nfs_server *server;
+	int ret = 0;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link)
+		if (!list_empty(&server->delegations)) {
+			ret = 1;
+			break;
+		}
+	rcu_read_unlock();
+	return ret;
+}
+
+/**
+ * nfs4_copy_delegation_stateid - Copy inode's state ID information
+ * @dst: stateid data structure to fill in
+ * @inode: inode to check
+ *
+ * Returns one and fills in "dst->data" * if inode had a delegation,
+ * otherwise zero is returned.
+ */
 int nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 2026304..d9322e4 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -44,6 +44,7 @@ void nfs_expire_all_delegation_types(struct nfs_client *clp, fmode_t flags);
 void nfs_expire_unreferenced_delegations(struct nfs_client *clp);
 void nfs_handle_cb_pathdown(struct nfs_client *clp);
 int nfs_client_return_marked_delegations(struct nfs_client *clp);
+int nfs_delegations_present(struct nfs_client *clp);
 
 void nfs_delegation_mark_reclaim(struct nfs_client *clp);
 void nfs_delegation_reap_unclaimed(struct nfs_client *clp);
diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index cde5650..402143d 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -80,7 +80,7 @@ nfs4_renew_state(struct work_struct *work)
 		cred = ops->get_state_renewal_cred_locked(clp);
 		spin_unlock(&clp->cl_lock);
 		if (cred == NULL) {
-			if (list_empty(&clp->cl_delegations)) {
+			if (!nfs_delegations_present(clp)) {
 				set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state);
 				goto out;
 			}
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index e96ec55..17881c0 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -47,7 +47,6 @@ struct nfs_client {
 	u64			cl_clientid;	/* constant */
 	unsigned long		cl_state;
 
-	struct list_head	cl_delegations;
 	spinlock_t		cl_lock;
 
 	unsigned long		cl_lease_time;
@@ -150,6 +149,7 @@ struct nfs_server {
 	struct rb_root		openowner_id;
 	struct rb_root		lockowner_id;
 #endif
+	struct list_head	delegations;
 	void (*destroy)(struct nfs_server *);
 
 	atomic_t active; /* Keep trace of any activity to this server */

