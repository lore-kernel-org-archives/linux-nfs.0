Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:27013 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761971Ab3DCXdd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 19:33:33 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/4] NFSv4: Fix CB_RECALL_ANY to only return delegations that are not in use
Date: Wed,  3 Apr 2013 19:33:27 -0400
Message-Id: <1365032007-59876-4-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1365032007-59876-3-git-send-email-Trond.Myklebust@netapp.com>
References: <1365032007-59876-1-git-send-email-Trond.Myklebust@netapp.com>
 <1365032007-59876-2-git-send-email-Trond.Myklebust@netapp.com>
 <1365032007-59876-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_proc.c |  2 +-
 fs/nfs/delegation.c    | 14 +++++++-------
 fs/nfs/delegation.h    |  2 +-
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 2960512..a13d26e 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -500,7 +500,7 @@ __be32 nfs4_callback_recallany(struct cb_recallanyargs *args, void *dummy,
 		     &args->craa_type_mask))
 		pnfs_recall_all_layouts(cps->clp);
 	if (flags)
-		nfs_expire_all_delegation_types(cps->clp, flags);
+		nfs_expire_unused_delegation_types(cps->clp, flags);
 out:
 	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
 	return status;
diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 60e2e6e..f30bd1e 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -564,7 +564,7 @@ void nfs_server_return_all_delegations(struct nfs_server *server)
 	}
 }
 
-static void nfs_mark_return_all_delegation_types(struct nfs_server *server,
+static void nfs_mark_return_unused_delegation_types(struct nfs_server *server,
 						 fmode_t flags)
 {
 	struct nfs_delegation *delegation;
@@ -573,18 +573,18 @@ static void nfs_mark_return_all_delegation_types(struct nfs_server *server,
 		if ((delegation->type == (FMODE_READ|FMODE_WRITE)) && !(flags & FMODE_WRITE))
 			continue;
 		if (delegation->type & flags)
-			nfs_mark_return_delegation(server, delegation);
+			nfs_mark_return_if_closed_delegation(server, delegation);
 	}
 }
 
-static void nfs_client_mark_return_all_delegation_types(struct nfs_client *clp,
+static void nfs_client_mark_return_unused_delegation_types(struct nfs_client *clp,
 							fmode_t flags)
 {
 	struct nfs_server *server;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(server, &clp->cl_superblocks, client_link)
-		nfs_mark_return_all_delegation_types(server, flags);
+		nfs_mark_return_unused_delegation_types(server, flags);
 	rcu_read_unlock();
 }
 
@@ -601,14 +601,14 @@ void nfs_remove_bad_delegation(struct inode *inode)
 EXPORT_SYMBOL_GPL(nfs_remove_bad_delegation);
 
 /**
- * nfs_expire_all_delegation_types
+ * nfs_expire_unused_delegation_types
  * @clp: client to process
  * @flags: delegation types to expire
  *
  */
-void nfs_expire_all_delegation_types(struct nfs_client *clp, fmode_t flags)
+void nfs_expire_unused_delegation_types(struct nfs_client *clp, fmode_t flags)
 {
-	nfs_client_mark_return_all_delegation_types(clp, flags);
+	nfs_client_mark_return_unused_delegation_types(clp, flags);
 	nfs_delegation_run_state_manager(clp);
 }
 
diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
index 22f0a13..9a79c7a 100644
--- a/fs/nfs/delegation.h
+++ b/fs/nfs/delegation.h
@@ -42,7 +42,7 @@ void nfs_inode_return_delegation_noreclaim(struct inode *inode);
 struct inode *nfs_delegation_find_inode(struct nfs_client *clp, const struct nfs_fh *fhandle);
 void nfs_server_return_all_delegations(struct nfs_server *);
 void nfs_expire_all_delegations(struct nfs_client *clp);
-void nfs_expire_all_delegation_types(struct nfs_client *clp, fmode_t flags);
+void nfs_expire_unused_delegation_types(struct nfs_client *clp, fmode_t flags);
 void nfs_expire_unreferenced_delegations(struct nfs_client *clp);
 int nfs_client_return_marked_delegations(struct nfs_client *clp);
 int nfs_delegations_present(struct nfs_client *clp);
-- 
1.8.1.4

