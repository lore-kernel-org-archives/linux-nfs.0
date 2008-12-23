From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 36/69] NFSv4: Clean up the asynchronous delegation return
Date: Tue, 23 Dec 2008 18:02:16 -0500
Message-ID: <20081223230215.13743.75618.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44861 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752511AbYLWXXr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:47 -0500
Received: from svlrsexc2-prd.hq.netapp.com ([10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNa7g021304
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:42 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reuse the state management thread in order to return delegations when we
get a callback.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/delegation.c |   73 +++++++++++++--------------------------------------
 1 files changed, 19 insertions(+), 54 deletions(-)


diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 21eda6c..00c350c 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -321,6 +321,12 @@ int nfs_inode_return_delegation(struct inode *inode)
 	return err;
 }
 
+static void nfs_mark_return_delegation(struct nfs_client *clp, struct nfs_delegation *delegation)
+{
+	set_bit(NFS_DELEGATION_RETURN, &delegation->flags);
+	set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
+}
+
 /*
  * Return all delegations associated to a super block
  */
@@ -376,66 +382,25 @@ void nfs_handle_cb_pathdown(struct nfs_client *clp)
 	nfs_client_mark_return_all_delegations(clp);
 }
 
-struct recall_threadargs {
-	struct inode *inode;
-	struct nfs_client *clp;
-	const nfs4_stateid *stateid;
-
-	struct completion started;
-	int result;
-};
-
-static int recall_thread(void *data)
-{
-	struct recall_threadargs *args = (struct recall_threadargs *)data;
-	struct inode *inode = igrab(args->inode);
-	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
-	struct nfs_inode *nfsi = NFS_I(inode);
-	struct nfs_delegation *delegation;
-
-	daemonize("nfsv4-delegreturn");
-
-	nfs_msync_inode(inode);
-	down_write(&nfsi->rwsem);
-	spin_lock(&clp->cl_lock);
-	delegation = nfs_detach_delegation_locked(nfsi, args->stateid);
-	if (delegation != NULL)
-		args->result = 0;
-	else
-		args->result = -ENOENT;
-	spin_unlock(&clp->cl_lock);
-	complete(&args->started);
-	nfs_delegation_claim_opens(inode, args->stateid);
-	up_write(&nfsi->rwsem);
-	nfs_msync_inode(inode);
-
-	if (delegation != NULL)
-		nfs_do_return_delegation(inode, delegation, 1);
-	iput(inode);
-	module_put_and_exit(0);
-}
-
 /*
  * Asynchronous delegation recall!
  */
 int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *stateid)
 {
-	struct recall_threadargs data = {
-		.inode = inode,
-		.stateid = stateid,
-	};
-	int status;
+	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
+	struct nfs_delegation *delegation;
 
-	init_completion(&data.started);
-	__module_get(THIS_MODULE);
-	status = kernel_thread(recall_thread, &data, CLONE_KERNEL);
-	if (status < 0)
-		goto out_module_put;
-	wait_for_completion(&data.started);
-	return data.result;
-out_module_put:
-	module_put(THIS_MODULE);
-	return status;
+	rcu_read_lock();
+	delegation = rcu_dereference(NFS_I(inode)->delegation);
+	if (delegation == NULL || memcmp(delegation->stateid.data, stateid->data,
+				sizeof(delegation->stateid.data)) != 0) {
+		rcu_read_unlock();
+		return -ENOENT;
+	}
+	nfs_mark_return_delegation(clp, delegation);
+	rcu_read_unlock();
+	nfs_delegation_run_state_manager(clp);
+	return 0;
 }
 
 /*

