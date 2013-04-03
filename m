Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:27013 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761666Ab3DCXdb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 19:33:31 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/4] NFSv4: Be less aggressive about returning delegations for open files
Date: Wed,  3 Apr 2013 19:33:24 -0400
Message-Id: <1365032007-59876-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, if the application that holds the file open isn't doing
I/O, we may end up returning the delegation. This means that we can
no longer cache the file as aggressively, and often also that we
multiply the state that both the server and the client needs to track.

This patch adds a check for open files to the routine that scans
for delegations that are unreferenced.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/delegation.c | 30 +++++++++++++++++++++++++++---
 fs/nfs/delegation.h |  1 +
 2 files changed, 28 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index fc8a213..a377ea36 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -389,6 +389,24 @@ out:
 	return err;
 }
 
+static bool nfs_delegation_need_return(struct nfs_delegation *delegation)
+{
+	bool ret = false;
+
+	if (test_and_clear_bit(NFS_DELEGATION_RETURN, &delegation->flags))
+		ret = true;
+	if (test_and_clear_bit(NFS_DELEGATION_RETURN_IF_CLOSED, &delegation->flags) && !ret) {
+		struct inode *inode;
+
+		spin_lock(&delegation->lock);
+		inode = delegation->inode;
+		if (inode && list_empty(&NFS_I(inode)->open_files))
+			ret = true;
+		spin_unlock(&delegation->lock);
+	}
+	return ret;
+}
+
 /**
  * nfs_client_return_marked_delegations - return previously marked delegations
  * @clp: nfs_client to process
@@ -411,8 +429,7 @@ restart:
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		list_for_each_entry_rcu(delegation, &server->delegations,
 								super_list) {
-			if (!test_and_clear_bit(NFS_DELEGATION_RETURN,
-							&delegation->flags))
+			if (!nfs_delegation_need_return(delegation))
 				continue;
 			inode = nfs_delegation_grab_inode(delegation);
 			if (inode == NULL)
@@ -471,6 +488,13 @@ int nfs4_inode_return_delegation(struct inode *inode)
 	return err;
 }
 
+static void nfs_mark_return_if_closed_delegation(struct nfs_server *server,
+		struct nfs_delegation *delegation)
+{
+	set_bit(NFS_DELEGATION_RETURN_IF_CLOSED, &delegation->flags);
+	set_bit(NFS4CLNT_DELEGRETURN, &server->nfs_client->cl_state);
+}
+
 static void nfs_mark_return_delegation(struct nfs_server *server,
 		struct nfs_delegation *delegation)
 {
@@ -574,7 +598,7 @@ static void nfs_mark_return_unreferenced_delegations(struct nfs_server *server)
 	list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
 		if (test_and_clear_bit(NFS_DELEGATION_REFERENCED, &delegation->flags))
 			continue;
-		nfs_mark_return_delegation(server, delegation);
+		nfs_mark_return_if_closed_delegation(server, delegation);
 	}
 }
 
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 88573d1..22f0a13 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -28,6 +28,7 @@ struct nfs_delegation {
 enum {
 	NFS_DELEGATION_NEED_RECLAIM = 0,
 	NFS_DELEGATION_RETURN,
+	NFS_DELEGATION_RETURN_IF_CLOSED,
 	NFS_DELEGATION_REFERENCED,
 	NFS_DELEGATION_RETURNING,
 };
-- 
1.8.1.4

