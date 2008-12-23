From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 18/69] NFS: Use atomic bitops when changing struct
 nfs_delegation->flags
Date: Tue, 23 Dec 2008 18:02:10 -0500
Message-ID: <20081223230210.13743.13268.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44861 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752585AbYLWXXs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:48 -0500
Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNaFn006177
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:42 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/delegation.c |    6 +++---
 fs/nfs/delegation.h |    4 ++--
 fs/nfs/nfs4proc.c   |    8 ++++----
 3 files changed, 9 insertions(+), 9 deletions(-)


diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 13f2044..646ba3e 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -119,7 +119,7 @@ void nfs_inode_reclaim_delegation(struct inode *inode, struct rpc_cred *cred, st
 	delegation->maxsize = res->maxsize;
 	oldcred = delegation->cred;
 	delegation->cred = get_rpccred(cred);
-	delegation->flags &= ~NFS_DELEGATION_NEED_RECLAIM;
+	clear_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags);
 	NFS_I(inode)->delegation_state = delegation->type;
 	smp_wmb();
 	put_rpccred(oldcred);
@@ -499,7 +499,7 @@ void nfs_delegation_mark_reclaim(struct nfs_client *clp)
 	struct nfs_delegation *delegation;
 	rcu_read_lock();
 	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list)
-		delegation->flags |= NFS_DELEGATION_NEED_RECLAIM;
+		set_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags);
 	rcu_read_unlock();
 }
 
@@ -513,7 +513,7 @@ void nfs_delegation_reap_unclaimed(struct nfs_client *clp)
 restart:
 	rcu_read_lock();
 	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
-		if ((delegation->flags & NFS_DELEGATION_NEED_RECLAIM) == 0)
+		if (test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags) == 0)
 			continue;
 		inode = nfs_delegation_grab_inode(delegation);
 		if (inode == NULL)
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 8299c62..5e9f40e 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -18,10 +18,10 @@ struct nfs_delegation {
 	struct inode *inode;
 	nfs4_stateid stateid;
 	int type;
-#define NFS_DELEGATION_NEED_RECLAIM 1
-	long flags;
 	loff_t maxsize;
 	__u64 change_attr;
+#define NFS_DELEGATION_NEED_RECLAIM 0
+	unsigned long flags;
 	spinlock_t lock;
 	struct rcu_head rcu;
 };
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 254cbff..d53aa2d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -344,7 +344,7 @@ static int can_open_delegated(struct nfs_delegation *delegation, mode_t open_fla
 {
 	if ((delegation->type & open_flags) != open_flags)
 		return 0;
-	if (delegation->flags & NFS_DELEGATION_NEED_RECLAIM)
+	if (test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags))
 		return 0;
 	return 1;
 }
@@ -536,7 +536,7 @@ static struct nfs4_state *nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data
 		if (delegation)
 			delegation_flags = delegation->flags;
 		rcu_read_unlock();
-		if (!(delegation_flags & NFS_DELEGATION_NEED_RECLAIM))
+		if ((delegation_flags & 1UL<<NFS_DELEGATION_NEED_RECLAIM) == 0)
 			nfs_inode_set_delegation(state->inode,
 					data->owner->so_cred,
 					&data->o_res);
@@ -667,7 +667,7 @@ static int _nfs4_do_open_reclaim(struct nfs_open_context *ctx, struct nfs4_state
 	opendata->o_arg.fh = NFS_FH(state->inode);
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(state->inode)->delegation);
-	if (delegation != NULL && (delegation->flags & NFS_DELEGATION_NEED_RECLAIM) != 0)
+	if (delegation != NULL && test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags) != 0)
 		delegation_type = delegation->type;
 	rcu_read_unlock();
 	opendata->o_arg.u.delegation_type = delegation_type;
@@ -839,7 +839,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 		rcu_read_lock();
 		delegation = rcu_dereference(NFS_I(data->state->inode)->delegation);
 		if (delegation != NULL &&
-		   (delegation->flags & NFS_DELEGATION_NEED_RECLAIM) == 0) {
+		    test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags) == 0) {
 			rcu_read_unlock();
 			goto out_no_action;
 		}

