Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:40946 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720Ab2LMGra (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2012 01:47:30 -0500
From: ycnian@gmail.com
To: Trond.Myklebust@netapp.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Yanchuan Nian <ycnian@gmail.com>
Subject: [PATCH] nfs: Don't return referenced delegations
Date: Thu, 13 Dec 2012 14:37:16 +0800
Message-Id: <1355380636-10915-1-git-send-email-ycnian@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yanchuan Nian <ycnian@gmail.com>

The client returns unreferenced delegations in state management. It scans all
delegations and tests the NFS_DELEGATION_REFERENCED flag. if this flag is not
set, NFS_DELEGATION_RETURN will be set and the delegation will be returned. 
But unfortunately NFS_DELEGATION_REFERENCED is cleared after the testing, so 
delegations which are still being used will be returned in the next state
management.

Signed-off-by: Yanchuan Nian <ycnian@gmail.com>
---
 fs/nfs/delegation.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 81c5eec..485e8c0 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -506,7 +506,7 @@ static void nfs_mark_return_unreferenced_delegations(struct nfs_server *server)
 	struct nfs_delegation *delegation;
 
 	list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
-		if (test_and_clear_bit(NFS_DELEGATION_REFERENCED, &delegation->flags))
+		if (test_bit(NFS_DELEGATION_REFERENCED, &delegation->flags))
 			continue;
 		nfs_mark_return_delegation(server, delegation);
 	}
-- 
1.7.4.4

