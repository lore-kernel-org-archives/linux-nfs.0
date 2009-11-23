From: Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 03/10] nfs41: fix cb_recall bug
Date: Mon, 23 Nov 2009 13:54:40 -0800
Message-ID: <1259013287-3349-3-git-send-email-batsakis@netapp.com>
References: <1259013287-3349-1-git-send-email-batsakis@netapp.com>
 <1259013287-3349-2-git-send-email-batsakis@netapp.com>
Cc: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42997 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757246AbZKWV7Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Nov 2009 16:59:24 -0500
In-Reply-To: <1259013287-3349-2-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

in NFSv4.1 the seqid part of a stateid in CB_RECALL must be 0

Signed-off-by: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfs/delegation.c |   21 +++++++++++++++++----
 1 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 6dd48a4..4096dcf 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -432,18 +432,31 @@ int nfs_async_inode_return_delegation(struct inode *inode, const nfs4_stateid *s
 {
 	struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
 	struct nfs_delegation *delegation;
+	u32 seqid_len = 0;
 
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
-	if (delegation == NULL || memcmp(delegation->stateid.data, stateid->data,
-				sizeof(delegation->stateid.data)) != 0) {
-		rcu_read_unlock();
-		return -ENOENT;
+	if (delegation == NULL)
+		goto enoent;
+
+	if (clp->cl_minorversion > 0) {
+		if (((u32 *) &stateid->data)[0] != 0)
+			goto enoent;
+		seqid_len = 4;
 	}
+
+	if (memcmp(&delegation->stateid.data[seqid_len],
+		   &stateid->data[seqid_len],
+		   sizeof(stateid->data)-seqid_len))
+		goto enoent;
+
 	nfs_mark_return_delegation(clp, delegation);
 	rcu_read_unlock();
 	nfs_delegation_run_state_manager(clp);
 	return 0;
+enoent:
+	rcu_read_unlock();
+	return -ENOENT;
 }
 
 /*
-- 
1.6.2.5

