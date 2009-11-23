From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 05/10] nfs4: return/expire delegations depending on their type
Date: Mon, 23 Nov 2009 13:54:42 -0800
Message-ID: <1259013287-3349-5-git-send-email-batsakis@netapp.com>
References: <1259013287-3349-1-git-send-email-batsakis@netapp.com>
 <1259013287-3349-2-git-send-email-batsakis@netapp.com>
 <1259013287-3349-3-git-send-email-batsakis@netapp.com>
 <1259013287-3349-4-git-send-email-batsakis@netapp.com>
Cc: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37396 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757284AbZKWV7Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 16:59:25 -0500
In-Reply-To: <1259013287-3349-4-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/delegation.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 71d5094..a14df44 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -371,29 +371,41 @@ void nfs_super_return_all_delegations(struct super_block *sb)
 	nfs_client_return_marked_delegations(clp);
 }
 
-static void nfs_client_mark_return_all_delegations(struct nfs_client *clp)
+static
+void nfs_client_mark_return_all_delegation_types(struct nfs_client *clp, fmode_t flags)
 {
 	struct nfs_delegation *delegation;
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
-		nfs_mark_return_delegation(clp, delegation);
+		if (delegation->type & flags)
+			nfs_mark_return_delegation(clp, delegation);
 	}
 	rcu_read_unlock();
 }
 
+static void nfs_client_mark_return_all_delegations(struct nfs_client *clp)
+{
+	nfs_client_mark_return_all_delegation_types(clp, FMODE_READ|FMODE_WRITE);
+}
+
 static void nfs_delegation_run_state_manager(struct nfs_client *clp)
 {
 	if (test_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state))
 		nfs4_schedule_state_manager(clp);
 }
 
-void nfs_expire_all_delegations(struct nfs_client *clp)
+void nfs_expire_all_delegation_types(struct nfs_client *clp, fmode_t flags)
 {
-	nfs_client_mark_return_all_delegations(clp);
+	nfs_client_mark_return_all_delegation_types(clp, flags);
 	nfs_delegation_run_state_manager(clp);
 }
 
+void nfs_expire_all_delegations(struct nfs_client *clp)
+{
+	nfs_expire_all_delegation_types(clp, FMODE_READ|FMODE_WRITE);
+}
+
 /*
  * Return all delegations following an NFS4ERR_CB_PATH_DOWN error.
  */
-- 
1.6.2.5

