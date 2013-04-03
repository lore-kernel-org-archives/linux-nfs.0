Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:27013 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761774Ab3DCXdc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Apr 2013 19:33:32 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/4] NFSv4: Fix nfs_server_return_all_delegations
Date: Wed,  3 Apr 2013 19:33:25 -0400
Message-Id: <1365032007-59876-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1365032007-59876-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1365032007-59876-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the state manager thread is already running, we may end up
racing with it in nfs_client_return_marked_delegations. Better to
just allow the state manager thread to do the job.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/delegation.c | 24 +++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index a377ea36..213f1bb 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -502,6 +502,18 @@ static void nfs_mark_return_delegation(struct nfs_server *server,
 	set_bit(NFS4CLNT_DELEGRETURN, &server->nfs_client->cl_state);
 }
 
+static bool nfs_server_mark_return_all_delegations(struct nfs_server *server)
+{
+	struct nfs_delegation *delegation;
+	bool ret = false;
+
+	list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
+		nfs_mark_return_delegation(server, delegation);
+		ret = true;
+	}
+	return ret;
+}
+
 /**
  * nfs_super_return_all_delegations - return delegations for one superblock
  * @sb: sb to process
@@ -510,21 +522,19 @@ static void nfs_mark_return_delegation(struct nfs_server *server,
 void nfs_server_return_all_delegations(struct nfs_server *server)
 {
 	struct nfs_client *clp = server->nfs_client;
-	struct nfs_delegation *delegation;
+	bool need_wait;
 
 	if (clp == NULL)
 		return;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
-		spin_lock(&delegation->lock);
-		set_bit(NFS_DELEGATION_RETURN, &delegation->flags);
-		spin_unlock(&delegation->lock);
-	}
+	need_wait = nfs_server_mark_return_all_delegations(server);
 	rcu_read_unlock();
 
-	if (nfs_client_return_marked_delegations(clp) != 0)
+	if (need_wait) {
 		nfs4_schedule_state_manager(clp);
+		nfs4_wait_clnt_recover(clp);
+	}
 }
 
 static void nfs_mark_return_all_delegation_types(struct nfs_server *server,
-- 
1.8.1.4

