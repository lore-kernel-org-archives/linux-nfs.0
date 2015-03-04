Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:43764 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755108AbbCDCyH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2015 21:54:07 -0500
Received: by iebtr6 with SMTP id tr6so63945126ieb.10
        for <linux-nfs@vger.kernel.org>; Tue, 03 Mar 2015 18:54:06 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Jorge Mora <Jorge.Mora@netapp.com>
Subject: [PATCH 1/2] NFSv4: Fix a race in NFSv4.1 server trunking discovery
Date: Tue,  3 Mar 2015 21:54:02 -0500
Message-Id: <1425437643-76439-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We do not want to allow a race with another NFS mount to cause
nfs41_walk_client_list() to establish a lease on our nfs_client before
we're done checking for trunking.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/client.c     |  2 +-
 fs/nfs/nfs4client.c |  9 ++++-----
 fs/nfs/nfs4state.c  | 14 ++++++++++++--
 3 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index f9f4845db989..19874151e95c 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -433,7 +433,7 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 
 static bool nfs_client_init_is_complete(const struct nfs_client *clp)
 {
-	return clp->cl_cons_state != NFS_CS_INITING;
+	return clp->cl_cons_state <= NFS_CS_READY;
 }
 
 int nfs_wait_client_init_complete(const struct nfs_client *clp)
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 8646af9b11d2..86d6214ea022 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -621,6 +621,9 @@ int nfs41_walk_client_list(struct nfs_client *new,
 	spin_lock(&nn->nfs_client_lock);
 	list_for_each_entry(pos, &nn->nfs_client_list, cl_share_link) {
 
+		if (pos == new)
+			goto found;
+
 		if (pos->rpc_ops != new->rpc_ops)
 			continue;
 
@@ -639,10 +642,6 @@ int nfs41_walk_client_list(struct nfs_client *new,
 			prev = pos;
 
 			status = nfs_wait_client_init_complete(pos);
-			if (pos->cl_cons_state == NFS_CS_SESSION_INITING) {
-				nfs4_schedule_lease_recovery(pos);
-				status = nfs4_wait_clnt_recover(pos);
-			}
 			spin_lock(&nn->nfs_client_lock);
 			if (status < 0)
 				break;
@@ -668,7 +667,7 @@ int nfs41_walk_client_list(struct nfs_client *new,
 		 */
 		if (!nfs4_match_client_owner_id(pos, new))
 			continue;
-
+found:
 		atomic_inc(&pos->cl_count);
 		*result = pos;
 		status = 0;
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5ad908e9ce9c..d8b43f0e08fc 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -346,9 +346,19 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
 	status = nfs4_proc_exchange_id(clp, cred);
 	if (status != NFS4_OK)
 		return status;
-	set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
 
-	return nfs41_walk_client_list(clp, result, cred);
+	status = nfs41_walk_client_list(clp, result, cred);
+	if (status < 0)
+		return status;
+	if (clp != *result)
+		return 0;
+
+	set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
+	nfs4_schedule_state_manager(clp);
+	status = nfs_wait_client_init_complete(clp);
+	if (status < 0)
+		nfs_put_client(clp);
+	return status;
 }
 
 #endif /* CONFIG_NFS_V4_1 */
-- 
2.1.0

