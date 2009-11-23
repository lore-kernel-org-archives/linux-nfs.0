From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 04/10] nfs4: minor delegation cleaning
Date: Mon, 23 Nov 2009 13:54:41 -0800
Message-ID: <1259013287-3349-4-git-send-email-batsakis@netapp.com>
References: <1259013287-3349-1-git-send-email-batsakis@netapp.com>
 <1259013287-3349-2-git-send-email-batsakis@netapp.com>
 <1259013287-3349-3-git-send-email-batsakis@netapp.com>
Cc: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42997 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757281AbZKWV7Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 16:59:25 -0500
In-Reply-To: <1259013287-3349-3-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/delegation.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 4096dcf..71d5094 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -377,8 +377,7 @@ static void nfs_client_mark_return_all_delegations(struct nfs_client *clp)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
-		set_bit(NFS_DELEGATION_RETURN, &delegation->flags);
-		set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
+		nfs_mark_return_delegation(clp, delegation);
 	}
 	rcu_read_unlock();
 }
@@ -413,8 +412,7 @@ static void nfs_client_mark_return_unreferenced_delegations(struct nfs_client *c
 	list_for_each_entry_rcu(delegation, &clp->cl_delegations, super_list) {
 		if (test_and_clear_bit(NFS_DELEGATION_REFERENCED, &delegation->flags))
 			continue;
-		set_bit(NFS_DELEGATION_RETURN, &delegation->flags);
-		set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
+		nfs_mark_return_delegation(clp, delegation);
 	}
 	rcu_read_unlock();
 }
-- 
1.6.2.5

