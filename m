Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:44618 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752814AbaKLWcT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Nov 2014 17:32:19 -0500
Received: by mail-ie0-f171.google.com with SMTP id x19so14699280ier.30
        for <linux-nfs@vger.kernel.org>; Wed, 12 Nov 2014 14:32:18 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/5] NFSv4: Fix races between nfs_remove_bad_delegation() and delegation return
Date: Wed, 12 Nov 2014 17:31:52 -0500
Message-Id: <1415831514-47005-4-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1415831514-47005-3-git-send-email-trond.myklebust@primarydata.com>
References: <1415831514-47005-1-git-send-email-trond.myklebust@primarydata.com>
 <1415831514-47005-2-git-send-email-trond.myklebust@primarydata.com>
 <1415831514-47005-3-git-send-email-trond.myklebust@primarydata.com>
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

http://lkml.kernel.org/r/CAN-5tyHwG=Cn2Q9KsHWadewjpTTy_K26ee+UnSvHvG4192p-Xw@mail.gmail.com
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 23 +++++++++++++++++++++--
 fs/nfs/delegation.h |  1 +
 fs/nfs/nfs4proc.c   |  2 +-
 3 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 5853f53db732..e5f473d13e24 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -193,7 +193,11 @@ static int nfs_do_return_delegation(struct inode *inode, struct nfs_delegation *
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
@@ -380,11 +384,13 @@ static int nfs_end_delegation_return(struct inode *inode, struct nfs_delegation
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
@@ -605,10 +611,23 @@ static void nfs_client_mark_return_unused_delegation_types(struct nfs_client *cl
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
index 3b98fe752ef8..4b7166f4e1cf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1654,7 +1654,7 @@ static int nfs4_handle_delegation_recall_error(struct nfs_server *server, struct
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

