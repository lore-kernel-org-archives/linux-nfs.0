Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50307 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750900Ab2CJRWZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 10 Mar 2012 12:22:25 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/2] NFS: Don't copy read delegation stateids in setattr
Date: Sat, 10 Mar 2012 12:21:44 -0500
Message-Id: <1331400105-17204-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The server will just return an NFS4ERR_OPENMODE anyway.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
v2: Simplify the mode arguments. Use either FMODE_READ or FMODE_WRITE
    depending on whether we're reading or writing.

 fs/nfs/delegation.c |   16 ++++++++++------
 fs/nfs/delegation.h |    2 +-
 fs/nfs/nfs4proc.c   |    2 +-
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 97d5357..e27c097 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -694,21 +694,25 @@ int nfs_delegations_present(struct nfs_client *clp)
  * nfs4_copy_delegation_stateid - Copy inode's state ID information
  * @dst: stateid data structure to fill in
  * @inode: inode to check
+ * @flags: delegation type requirement
  *
- * Returns one and fills in "dst->data" * if inode had a delegation,
- * otherwise zero is returned.
+ * Returns "true" and fills in "dst->data" * if inode had a delegation,
+ * otherwise "false" is returned.
  */
-int nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode)
+bool nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode,
+		fmode_t flags)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct nfs_delegation *delegation;
-	int ret = 0;
+	bool ret;
 
+	flags &= FMODE_READ|FMODE_WRITE;
 	rcu_read_lock();
 	delegation = rcu_dereference(nfsi->delegation);
-	if (delegation != NULL) {
+	ret = (delegation != NULL && (delegation->type & flags) == flags);
+	if (ret) {
 		nfs4_stateid_copy(dst, &delegation->stateid);
-		ret = 1;
+		nfs_mark_delegation_referenced(delegation);
 	}
 	rcu_read_unlock();
 	return ret;
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 691a796..e193012 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -54,7 +54,7 @@ void nfs_delegation_reap_unclaimed(struct nfs_client *clp);
 int nfs4_proc_delegreturn(struct inode *inode, struct rpc_cred *cred, const nfs4_stateid *stateid, int issync);
 int nfs4_open_delegation_recall(struct nfs_open_context *ctx, struct nfs4_state *state, const nfs4_stateid *stateid);
 int nfs4_lock_delegation_recall(struct nfs4_state *state, struct file_lock *fl);
-int nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode);
+bool nfs4_copy_delegation_stateid(nfs4_stateid *dst, struct inode *inode, fmode_t flags);
 
 void nfs_mark_delegation_referenced(struct nfs_delegation *delegation);
 int nfs_have_delegation(struct inode *inode, fmode_t flags);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a8dd04d..3578ad3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1929,7 +1929,7 @@ static int _nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 
 	nfs_fattr_init(fattr);
 
-	if (nfs4_copy_delegation_stateid(&arg.stateid, inode)) {
+	if (nfs4_copy_delegation_stateid(&arg.stateid, inode, FMODE_WRITE)) {
 		/* Use that stateid */
 	} else if (state != NULL) {
 		nfs4_select_rw_stateid(&arg.stateid, state, current->files, current->tgid);
-- 
1.7.7.6

