Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11344 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932735Ab1DNTEn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Apr 2011 15:04:43 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: trond@netapp.com
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH] NFS: dont restart loop in nfs_delegation_reap_unclaimed
Date: Thu, 14 Apr 2011 15:04:15 -0400
Message-Id: <1302807855-84959-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The loop was being restarted after each delegation that has NFS_DELEGATION_NEED_RECLAIM
set.  Instead, build a temporary list of delegations that need to be freed and free
them after the for-each-delegation loop.

Signed-off-by: Weston Andros Adamson <dros@netapp.com>
---
 fs/nfs/delegation.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index bbbc6bf..c87fad8 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -645,8 +645,8 @@ void nfs_delegation_reap_unclaimed(struct nfs_client *clp)
 	struct nfs_delegation *delegation;
 	struct nfs_server *server;
 	struct inode *inode;
+	LIST_HEAD(tmplist);
 
-restart:
 	rcu_read_lock();
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link) {
 		list_for_each_entry_rcu(delegation, &server->delegations,
@@ -659,15 +659,21 @@ restart:
 				continue;
 			delegation = nfs_detach_delegation(NFS_I(inode),
 								server);
-			rcu_read_unlock();
-
+			/* super_list is unused now that deleg is detached */
 			if (delegation != NULL)
-				nfs_free_delegation(delegation);
+				list_add(&delegation->super_list, &tmplist);
+
 			iput(inode);
-			goto restart;
 		}
 	}
 	rcu_read_unlock();
+
+	while (!list_empty(&tmplist)) {
+		delegation = list_first_entry(&tmplist, struct nfs_delegation,
+					super_list);
+		list_del(&delegation->super_list);
+		nfs_free_delegation(delegation);
+	}
 }
 
 /**
-- 
1.7.4.2

