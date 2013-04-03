Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:1063 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761006Ab3DCSro (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 14:47:44 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Be less aggressive about returning delegations for open files
Date: Wed,  3 Apr 2013 14:47:41 -0400
Message-Id: <1365014861-28947-1-git-send-email-Trond.Myklebust@netapp.com>
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
 fs/nfs/delegation.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index fc8a213..5e647cd 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -570,11 +570,16 @@ void nfs_expire_all_delegations(struct nfs_client *clp)
 static void nfs_mark_return_unreferenced_delegations(struct nfs_server *server)
 {
 	struct nfs_delegation *delegation;
+	struct inode *inode;
 
 	list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
 		if (test_and_clear_bit(NFS_DELEGATION_REFERENCED, &delegation->flags))
 			continue;
-		nfs_mark_return_delegation(server, delegation);
+		spin_lock(&delegation->lock);
+		inode = delegation->inode;
+		if (inode != NULL && list_empty(&NFS_I(inode)->open_files))
+			nfs_mark_return_delegation(server, delegation);
+		spin_unlock(&delegation->lock);
 	}
 }
 
-- 
1.8.1.4

