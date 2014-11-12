Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:44123 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933267AbaKLBda (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Nov 2014 20:33:30 -0500
Received: by mail-ig0-f177.google.com with SMTP id hl2so2104795igb.4
        for <linux-nfs@vger.kernel.org>; Tue, 11 Nov 2014 17:33:29 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix races between nfs_remove_bad_delegation() and delegation return
Date: Tue, 11 Nov 2014 20:33:23 -0500
Message-Id: <1415756003-4483-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Any attempt to call nfs_remove_bad_delegation() while a delegation is being
returned is currently a no-op. This means that we can end up looping
forever in nfs_end_delegation_return() if something causes the delegation
to be revoked.
This patch adds a mechanism whereby the state recovery code can communicate
to the delegation return code that the delegation is no longer valid and
that it should not be used when reclaiming state.
It also changes the return value for nfs4_handle_delegation_recall_error()
to ensure that nfs_end_delegation_return() does not reattempt the lock
reclaim before state recovery is done.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 23 +++++++++++++++++++++--
 fs/nfs/delegation.h |  1 +
 fs/nfs/nfs4proc.c   |  2 +-
 3 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 4904a1dba937..7f3f60641344 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -195,7 +195,11 @@ static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *
 {
 	int res = 0;
 
-	res = nfs4_proc_delegreturn(inode, delegation->cred, &delegation->stateid, issync);
+	if (!test_bit(NFS_DELEGATION_REVOKED, &delegation->flags))
+		res = nfs4_proc_delegreturn(inode,
+				delegation->cred,
+				&delegation->stateid,
+				issync);
 	nfs_free_delegation(delegation);
 	return res;
 }
@@ -382,11 +386,13 @@ static int nfs_end_delegation_return(struct inode *inode, struct nfs_delegation
 {
 	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
 	struct nfs_inode *nfsi = NFS_I(inode);
-	int err;
+	int err = 0;
 
 	if (delegation == NULL)
 		return 0;
 	do {
+		if (test_bit(NFS_DELEGATION_REVOKED, &delegation->flags))
+			break;
 		err = nfs_delegation_claim_opens(inode, &delegation->stateid);
 		if (!issync || err != -EAGAIN)
 			break;
@@ -607,10 +613,23 @@ static void nfs_client_mark_return_unused_delegation_types(struct nfs_client *cl
 	rcu_read_unlock();
 }
 
+static void nfs_revoke_delegation(struct inode *inode)
+{
+	struct nfs_delegation *delegation;
+	rcu_read_lock();
+	delegation = rcu_dereference(NFS_I(inode)->delegation);
+	if (delegation != NULL) {
+		set_bit(NFS_DELEGATION_REVOKED, &delegation->flags);
+		nfs_mark_return_delegation(NFS_SERVER(inode), delegation);
+	}
+	rcu_read_unlock();
+}
+
 void nfs_remove_bad_delegation(struct inode *inode)
 {
 	struct nfs_delegation *delegation;
 
+	nfs_revoke_delegation(inode);
 	delegation = nfs_inode_detach_delegation(inode);
 	if (delegation) {
 		nfs_inode_find_state_and_recover(inode, &delegation->stateid);
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 5c1cce39297f..e3c20a3ccc93 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -31,6 +31,7 @@ enum {
 	NFS_DELEGATION_RETURN_IF_CLOSED,
 	NFS_DELEGATION_REFERENCED,
 	NFS_DELEGATION_RETURNING,
+	NFS_DELEGATION_REVOKED,
 };
 
 int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct nfs_openres *res);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 773ebcb9eea9..a3deb6589b65 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1649,7 +1649,7 @@ static int nfs4_handle_delegation_recall_error(struct nfs_server *server, struct
 			nfs_inode_find_state_and_recover(state->inode,
 					stateid);
 			nfs4_schedule_stateid_recovery(server, state);
-			return 0;
+			return -EAGAIN;
 		case -NFS4ERR_DELAY:
 		case -NFS4ERR_GRACE:
 			set_bit(NFS_DELEGATED_STATE, &state->flags);
-- 
1.9.3

