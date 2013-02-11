Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:32833 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932106Ab3BKTaa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2013 14:30:30 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] NFSv4.1: Don't lose locks when a server reboots during delegation return
Date: Mon, 11 Feb 2013 14:29:23 -0500
Message-Id: <1360610966-15398-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1360610966-15398-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1360610966-15398-1-git-send-email-Trond.Myklebust@netapp.com>
 <1360610966-15398-2-git-send-email-Trond.Myklebust@netapp.com>
 <1360610966-15398-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server reboots while we are converting a delegation into
OPEN/LOCK stateids as part of a delegation return, the current code
will simply exit with an error. This causes us to lose both
delegation state and locking state (i.e. locking atomicity).

Deal with this by exposing the delegation stateid during delegation
return, so that we can recover the delegation, and then resume
open/lock recovery.

Note that not having to hold the nfs_inode->rwsem across the
calls to nfs_delegation_claim_opens() also fixes a deadlock against
the NFSv4.1 reboot recovery code.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/delegation.c | 147 +++++++++++++++++++++++++++++++++++++---------------
 fs/nfs/delegation.h |   1 +
 fs/nfs/nfs4proc.c   |   3 ++
 3 files changed, 108 insertions(+), 43 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 81c5eec..2542cda 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -55,7 +55,8 @@ int nfs4_have_delegation(struct inode *inode, fmode_t flags)
 	flags &= FMODE_READ|FMODE_WRITE;
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
-	if (delegation != NULL && (delegation->type & flags) == flags) {
+	if (delegation != NULL && (delegation->type & flags) == flags &&
+	    !test_bit(NFS_DELEGATION_RETURNING, &delegation->flags)) {
 		nfs_mark_delegation_referenced(delegation);
 		ret = 1;
 	}
@@ -94,7 +95,9 @@ static int nfs_delegation_claim_opens(struct inode *inode, const nfs4_stateid *s
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_open_context *ctx;
+	struct nfs4_state_owner *sp;
 	struct nfs4_state *state;
+	unsigned int seq;
 	int err;
 
 again:
@@ -109,9 +112,13 @@ again:
 			continue;
 		get_nfs_open_context(ctx);
 		spin_unlock(&inode->i_lock);
+		sp = state->owner;
+		seq = raw_seqcount_begin(&sp->so_reclaim_seqcount);
 		err = nfs4_open_delegation_recall(ctx, state, stateid);
-		if (err >= 0)
+		if (!err)
 			err = nfs_delegation_claim_locks(ctx, state);
+		if (!err && read_seqcount_retry(&sp->so_reclaim_seqcount, seq))
+			err = -EAGAIN;
 		put_nfs_open_context(ctx);
 		if (err != 0)
 			return err;
@@ -182,39 +189,91 @@ static struct inode *nfs_delegation_grab_inode(struct nfs_delegation *delegation
 }
 
 static struct nfs_delegation *
+nfs_start_delegation_return_locked(struct nfs_inode *nfsi)
+{
+	struct nfs_delegation *ret = NULL;
+	struct nfs_delegation *delegation = rcu_dereference(nfsi->delegation);
+
+	if (delegation == NULL)
+		goto out;
+	spin_lock(&delegation->lock);
+	if (!test_and_set_bit(NFS_DELEGATION_RETURNING, &delegation->flags))
+		ret = delegation;
+	spin_unlock(&delegation->lock);
+out:
+	return ret;
+}
+
+static struct nfs_delegation *
+nfs_start_delegation_return(struct nfs_inode *nfsi)
+{
+	struct nfs_delegation *delegation;
+
+	rcu_read_lock();
+	delegation = nfs_start_delegation_return_locked(nfsi);
+	rcu_read_unlock();
+	return delegation;
+}
+
+static void
+nfs_abort_delegation_return(struct nfs_delegation *delegation,
+		struct nfs_client *clp)
+{
+
+	spin_lock(&delegation->lock);
+	clear_bit(NFS_DELEGATION_RETURNING, &delegation->flags);
+	set_bit(NFS_DELEGATION_RETURN, &delegation->flags);
+	spin_unlock(&delegation->lock);
+	set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
+}
+
+static struct nfs_delegation *
 nfs_detach_delegation_locked(struct nfs_inode *nfsi,
-			     struct nfs_server *server)
+		struct nfs_delegation *delegation,
+		struct nfs_client *clp)
 {
-	struct nfs_delegation *delegation =
+	struct nfs_delegation *deleg_cur =
 		rcu_dereference_protected(nfsi->delegation,
-				lockdep_is_held(&server->nfs_client->cl_lock));
+				lockdep_is_held(&clp->cl_lock));
 
-	if (delegation == NULL)
-		goto nomatch;
+	if (deleg_cur == NULL || delegation != deleg_cur)
+		return NULL;
 
 	spin_lock(&delegation->lock);
+	set_bit(NFS_DELEGATION_RETURNING, &delegation->flags);
 	list_del_rcu(&delegation->super_list);
 	delegation->inode = NULL;
 	nfsi->delegation_state = 0;
 	rcu_assign_pointer(nfsi->delegation, NULL);
 	spin_unlock(&delegation->lock);
 	return delegation;
-nomatch:
-	return NULL;
 }
 
 static struct nfs_delegation *nfs_detach_delegation(struct nfs_inode *nfsi,
-						    struct nfs_server *server)
+		struct nfs_delegation *delegation,
+		struct nfs_server *server)
 {
 	struct nfs_client *clp = server->nfs_client;
-	struct nfs_delegation *delegation;
 
 	spin_lock(&clp->cl_lock);
-	delegation = nfs_detach_delegation_locked(nfsi, server);
+	delegation = nfs_detach_delegation_locked(nfsi, delegation, clp);
 	spin_unlock(&clp->cl_lock);
 	return delegation;
 }
 
+static struct nfs_delegation *
+nfs_inode_detach_delegation(struct inode *inode)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_server *server = NFS_SERVER(inode);
+	struct nfs_delegation *delegation;
+
+	delegation = nfs_start_delegation_return(nfsi);
+	if (delegation == NULL)
+		return NULL;
+	return nfs_detach_delegation(nfsi, delegation, server);
+}
+
 /**
  * nfs_inode_set_delegation - set up a delegation on an inode
  * @inode: inode to which delegation applies
@@ -268,7 +327,10 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 			delegation = NULL;
 			goto out;
 		}
-		freeme = nfs_detach_delegation_locked(nfsi, server);
+		freeme = nfs_detach_delegation_locked(nfsi, 
+				old_delegation, clp);
+		if (freeme == NULL)
+			goto out;
 	}
 	list_add_rcu(&delegation->super_list, &server->delegations);
 	nfsi->delegation_state = delegation->type;
@@ -292,19 +354,29 @@ out:
 /*
  * Basic procedure for returning a delegation to the server
  */
-static int __nfs_inode_return_delegation(struct inode *inode, struct nfs_delegation *delegation, int issync)
+static int nfs_end_delegation_return(struct inode *inode, struct nfs_delegation *delegation, int issync)
 {
+	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int err;
 
-	/*
-	 * Guard against new delegated open/lock/unlock calls and against
-	 * state recovery
-	 */
-	down_write(&nfsi->rwsem);
-	err = nfs_delegation_claim_opens(inode, &delegation->stateid);
-	up_write(&nfsi->rwsem);
-	if (err)
+	if (delegation == NULL)
+		return 0;
+	do {
+		err = nfs_delegation_claim_opens(inode, &delegation->stateid);
+		if (!issync || err != -EAGAIN)
+			break;
+		/*
+		 * Guard against state recovery
+		 */
+		err = nfs4_wait_clnt_recover(clp);
+	} while (err == 0);
+
+	if (err) {
+		nfs_abort_delegation_return(delegation, clp);
+		goto out;
+	}
+	if (!nfs_detach_delegation(nfsi, delegation, NFS_SERVER(inode)))
 		goto out;
 
 	err = nfs_do_return_delegation(inode, delegation, issync);
@@ -340,13 +412,10 @@ restart:
 			inode = nfs_delegation_grab_inode(delegation);
 			if (inode == NULL)
 				continue;
-			delegation = nfs_detach_delegation(NFS_I(inode),
-								server);
+			delegation = nfs_start_delegation_return_locked(NFS_I(inode));
 			rcu_read_unlock();
 
-			if (delegation != NULL)
-				err = __nfs_inode_return_delegation(inode,
-								delegation, 0);
+			err = nfs_end_delegation_return(inode, delegation, 0);
 			iput(inode);
 			if (!err)
 				goto restart;
@@ -367,15 +436,11 @@ restart:
  */
 void nfs_inode_return_delegation_noreclaim(struct inode *inode)
 {
-	struct nfs_server *server = NFS_SERVER(inode);
-	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_delegation *delegation;
 
-	if (rcu_access_pointer(nfsi->delegation) != NULL) {
-		delegation = nfs_detach_delegation(nfsi, server);
-		if (delegation != NULL)
-			nfs_do_return_delegation(inode, delegation, 0);
-	}
+	delegation = nfs_inode_detach_delegation(inode);
+	if (delegation != NULL)
+		nfs_do_return_delegation(inode, delegation, 0);
 }
 
 /**
@@ -390,18 +455,14 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode)
  */
 int nfs4_inode_return_delegation(struct inode *inode)
 {
-	struct nfs_server *server = NFS_SERVER(inode);
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_delegation *delegation;
 	int err = 0;
 
 	nfs_wb_all(inode);
-	if (rcu_access_pointer(nfsi->delegation) != NULL) {
-		delegation = nfs_detach_delegation(nfsi, server);
-		if (delegation != NULL) {
-			err = __nfs_inode_return_delegation(inode, delegation, 1);
-		}
-	}
+	delegation = nfs_start_delegation_return(nfsi);
+	if (delegation != NULL)
+		err = nfs_end_delegation_return(inode, delegation, 1);
 	return err;
 }
 
@@ -471,7 +532,7 @@ void nfs_remove_bad_delegation(struct inode *inode)
 {
 	struct nfs_delegation *delegation;
 
-	delegation = nfs_detach_delegation(NFS_I(inode), NFS_SERVER(inode));
+	delegation = nfs_inode_detach_delegation(inode);
 	if (delegation) {
 		nfs_inode_find_state_and_recover(inode, &delegation->stateid);
 		nfs_free_delegation(delegation);
@@ -649,7 +710,7 @@ restart:
 			if (inode == NULL)
 				continue;
 			delegation = nfs_detach_delegation(NFS_I(inode),
-								server);
+					delegation, server);
 			rcu_read_unlock();
 
 			if (delegation != NULL)
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index bbc6a4d..d54d4fc 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -29,6 +29,7 @@ enum {
 	NFS_DELEGATION_NEED_RECLAIM = 0,
 	NFS_DELEGATION_RETURN,
 	NFS_DELEGATION_REFERENCED,
+	NFS_DELEGATION_RETURNING,
 };
 
 int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 92584c1..a1e89e2 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -896,6 +896,8 @@ static int can_open_delegated(struct nfs_delegation *delegation, fmode_t fmode)
 		return 0;
 	if (test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags))
 		return 0;
+	if (test_bit(NFS_DELEGATION_RETURNING, &delegation->flags))
+		return 0;
 	nfs_mark_delegation_referenced(delegation);
 	return 1;
 }
@@ -973,6 +975,7 @@ static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stat
 
 	spin_lock(&deleg_cur->lock);
 	if (nfsi->delegation != deleg_cur ||
+	   test_bit(NFS_DELEGATION_RETURNING, &deleg_cur->flags) ||
 	    (deleg_cur->type & fmode) != fmode)
 		goto no_delegation_unlock;
 
-- 
1.8.1.2

