Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:51433 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092AbbAYAVH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 19:21:07 -0500
Received: by mail-ie0-f178.google.com with SMTP id rp18so3323552iec.9
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2015 16:21:06 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Deal with atomic upgrades of an existing delegation
Date: Sat, 24 Jan 2015 19:21:04 -0500
Message-Id: <1422145264-82005-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ensure that we deal correctly with the case where the server sends us a
newer instance of the same delegation. If the stateids match, but the
sequence numbers differ, then treat the new delegation as if it were
an atomic upgrade.

Signed-off-by: Trond Myklebust <Trond.Myklebust@primarydata.com>
---
 fs/nfs/delegation.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 7f3f60641344..16b754ee0d09 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -301,6 +301,17 @@ nfs_inode_detach_delegation(struct inode *inode)
 	return nfs_detach_delegation(nfsi, delegation, server);
 }
 
+static void
+nfs_update_inplace_delegation(struct nfs_delegation *delegation,
+		const struct nfs_delegation *update)
+{
+	if (nfs4_stateid_is_newer(&update->stateid, &delegation->stateid)) {
+		delegation->stateid.seqid = update->stateid.seqid;
+		smp_wmb();
+		delegation->type = update->type;
+	}
+}
+
 /**
  * nfs_inode_set_delegation - set up a delegation on an inode
  * @inode: inode to which delegation applies
@@ -334,9 +345,12 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
 	old_delegation = rcu_dereference_protected(nfsi->delegation,
 					lockdep_is_held(&clp->cl_lock));
 	if (old_delegation != NULL) {
-		if (nfs4_stateid_match(&delegation->stateid,
-					&old_delegation->stateid) &&
-				delegation->type == old_delegation->type) {
+		/* Is this an update of the existing delegation? */
+		if (nfs4_stateid_match_other(&old_delegation->stateid,
+					&delegation->stateid)) {
+			nfs_update_inplace_delegation(old_delegation,
+					delegation);
+			nfsi->delegation_state = old_delegation->type;
 			goto out;
 		}
 		/*
-- 
2.1.0

