From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 16/69] NFSv4: Fix up another delegation related race
Date: Tue, 23 Dec 2008 18:02:10 -0500
Message-ID: <20081223230210.13743.82814.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44861 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752294AbYLWXXm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:42 -0500
Received: from svlrsexc1-prd.hq.netapp.com ([10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNbsU006182
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:39 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we can update_open_stateid(), we need to be certain that we don't
race with a delegation return. While we could do this by grabbing the
nfs_client->cl_lock, a dedicated spin lock in the delegation structure
will scale better.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/delegation.c |    7 ++++
 fs/nfs/delegation.h |    1 +
 fs/nfs/nfs4proc.c   |   80 ++++++++++++++++++++++++++++++++++-----------------
 3 files changed, 60 insertions(+), 28 deletions(-)


diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index cc563cf..e0cb4ee 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -140,13 +140,17 @@ static struct nfs_delegation *nfs_detach_delegation_locked(struct nfs_inode *nfs
 
 	if (delegation == NULL)
 		goto nomatch;
+	spin_lock(&delegation->lock);
 	if (stateid != NULL && memcmp(delegation->stateid.data, stateid->data,
 				sizeof(delegation->stateid.data)) != 0)
-		goto nomatch;
+		goto nomatch_unlock;
 	list_del_rcu(&delegation->super_list);
 	nfsi->delegation_state = 0;
 	rcu_assign_pointer(nfsi->delegation, NULL);
+	spin_unlock(&delegation->lock);
 	return delegation;
+nomatch_unlock:
+	spin_unlock(&delegation->lock);
 nomatch:
 	return NULL;
 }
@@ -172,6 +176,7 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	delegation->change_attr = nfsi->change_attr;
 	delegation->cred = get_rpccred(cred);
 	delegation->inode = inode;
+	spin_lock_init(&delegation->lock);
 
 	spin_lock(&clp->cl_lock);
 	if (rcu_dereference(nfsi->delegation) != NULL) {
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index f1c5e2a..8299c62 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -22,6 +22,7 @@ struct nfs_delegation {
 	long flags;
 	loff_t maxsize;
 	__u64 change_attr;
+	spinlock_t lock;
 	struct rcu_head rcu;
 };
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 83e700a..254cbff 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -388,9 +388,8 @@ static void nfs_set_open_stateid(struct nfs4_state *state, nfs4_stateid *stateid
 	write_sequnlock(&state->seqlock);
 }
 
-static void update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, nfs4_stateid *deleg_stateid, int open_flags)
+static void __update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, const nfs4_stateid *deleg_stateid, int open_flags)
 {
-	open_flags &= (FMODE_READ|FMODE_WRITE);
 	/*
 	 * Protect the call to nfs4_state_set_mode_locked and
 	 * serialise the stateid update
@@ -408,6 +407,45 @@ static void update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_sta
 	spin_unlock(&state->owner->so_lock);
 }
 
+static int update_open_stateid(struct nfs4_state *state, nfs4_stateid *open_stateid, nfs4_stateid *delegation, int open_flags)
+{
+	struct nfs_inode *nfsi = NFS_I(state->inode);
+	struct nfs_delegation *deleg_cur;
+	int ret = 0;
+
+	open_flags &= (FMODE_READ|FMODE_WRITE);
+
+	rcu_read_lock();
+	deleg_cur = rcu_dereference(nfsi->delegation);
+	if (deleg_cur == NULL)
+		goto no_delegation;
+
+	spin_lock(&deleg_cur->lock);
+	if (nfsi->delegation != deleg_cur ||
+	    (deleg_cur->type & open_flags) != open_flags)
+		goto no_delegation_unlock;
+
+	if (delegation == NULL)
+		delegation = &deleg_cur->stateid;
+	else if (memcmp(deleg_cur->stateid.data, delegation->data, NFS4_STATEID_SIZE) != 0)
+		goto no_delegation_unlock;
+
+	__update_open_stateid(state, open_stateid, &deleg_cur->stateid, open_flags);
+	ret = 1;
+no_delegation_unlock:
+	spin_unlock(&deleg_cur->lock);
+no_delegation:
+	rcu_read_unlock();
+
+	if (!ret && open_stateid != NULL) {
+		__update_open_stateid(state, open_stateid, NULL, open_flags);
+		ret = 1;
+	}
+
+	return ret;
+}
+
+
 static void nfs4_return_incompatible_delegation(struct inode *inode, mode_t open_flags)
 {
 	struct nfs_delegation *delegation;
@@ -431,23 +469,23 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 	nfs4_stateid stateid;
 	int ret = -EAGAIN;
 
-	rcu_read_lock();
-	delegation = rcu_dereference(nfsi->delegation);
 	for (;;) {
 		if (can_open_cached(state, open_mode)) {
 			spin_lock(&state->owner->so_lock);
 			if (can_open_cached(state, open_mode)) {
 				update_open_stateflags(state, open_mode);
 				spin_unlock(&state->owner->so_lock);
-				rcu_read_unlock();
 				goto out_return_state;
 			}
 			spin_unlock(&state->owner->so_lock);
 		}
-		if (delegation == NULL)
-			break;
-		if (!can_open_delegated(delegation, open_mode))
+		rcu_read_lock();
+		delegation = rcu_dereference(nfsi->delegation);
+		if (delegation == NULL ||
+		    !can_open_delegated(delegation, open_mode)) {
+			rcu_read_unlock();
 			break;
+		}
 		/* Save the delegation */
 		memcpy(stateid.data, delegation->stateid.data, sizeof(stateid.data));
 		rcu_read_unlock();
@@ -455,19 +493,11 @@ static struct nfs4_state *nfs4_try_open_cached(struct nfs4_opendata *opendata)
 		if (ret != 0)
 			goto out;
 		ret = -EAGAIN;
-		rcu_read_lock();
-		delegation = rcu_dereference(nfsi->delegation);
-		/* If no delegation, try a cached open */
-		if (delegation == NULL)
-			continue;
-		/* Is the delegation still valid? */
-		if (memcmp(stateid.data, delegation->stateid.data, sizeof(stateid.data)) != 0)
-			continue;
-		rcu_read_unlock();
-		update_open_stateid(state, NULL, &stateid, open_mode);
-		goto out_return_state;
+
+		/* Try to update the stateid using the delegation */
+		if (update_open_stateid(state, NULL, &stateid, open_mode))
+			goto out_return_state;
 	}
-	rcu_read_unlock();
 out:
 	return ERR_PTR(ret);
 out_return_state:
@@ -480,7 +510,6 @@ static struct nfs4_state *nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data
 	struct inode *inode;
 	struct nfs4_state *state = NULL;
 	struct nfs_delegation *delegation;
-	nfs4_stateid *deleg_stateid = NULL;
 	int ret;
 
 	if (!data->rpc_done) {
@@ -516,12 +545,9 @@ static struct nfs4_state *nfs4_opendata_to_nfs4_state(struct nfs4_opendata *data
 					data->owner->so_cred,
 					&data->o_res);
 	}
-	rcu_read_lock();
-	delegation = rcu_dereference(NFS_I(inode)->delegation);
-	if (delegation != NULL)
-		deleg_stateid = &delegation->stateid;
-	update_open_stateid(state, &data->o_res.stateid, deleg_stateid, data->o_arg.open_flags);
-	rcu_read_unlock();
+
+	update_open_stateid(state, &data->o_res.stateid, NULL,
+			data->o_arg.open_flags);
 	iput(inode);
 out:
 	return state;

