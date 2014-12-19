Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f170.google.com ([209.85.213.170]:54337 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbaLSSL2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2014 13:11:28 -0500
Received: by mail-ig0-f170.google.com with SMTP id r2so2484446igi.5
        for <linux-nfs@vger.kernel.org>; Fri, 19 Dec 2014 10:11:27 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/2] NFSv4: Deal with atomic upgrades of an existing delegation
Date: Fri, 19 Dec 2014 13:10:40 -0500
Message-Id: <1419012641-8564-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <CAN-5tyHAckqJoAbD02rmW1jRiGDK_4_oDvm8eDosZwvd_jc3CQ@mail.gmail.com>
References: <CAN-5tyHAckqJoAbD02rmW1jRiGDK_4_oDvm8eDosZwvd_jc3CQ@mail.gmail.com>
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
index 7f3f60641344..90413cdbf254 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -301,6 +301,18 @@ nfs_inode_detach_delegation(struct inode *inode)
 	return nfs_detach_delegation(nfsi, delegation, server);
 }
 
+static void
+nfs_update_inplace_delegation(struct nfs_delegation *delegation,
+		struct nfs_delegation *update)
+{
+	if (nfs4_stateid_is_newer(&update->stateid, &delegation->stateid))
+		return;
+	delegation->stateid.seqid = update->stateid.seqid;
+	smp_wmb();
+	delegation->type == update->type;
+	nfsi->delegation_state = update->type;
+}
+
 /**
  * nfs_inode_set_delegation - set up a delegation on an inode
  * @inode: inode to which delegation applies
@@ -334,9 +346,11 @@ int nfs_inode_set_delegation(struct inode *inode, struct rpc_cred *cred, struct
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
 			goto out;
 		}
 		/*
-- 
2.1.0

