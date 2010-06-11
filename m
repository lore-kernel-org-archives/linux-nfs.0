From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 23/26] pnfs_submit: remove unecessary pnfs_fl_call_data field commit_through_mds
Date: Fri, 11 Jun 2010 03:31:50 -0400
Message-ID: <1276241513-17942-24-git-send-email-iisaman@netapp.com>
References: <1276241513-17942-1-git-send-email-iisaman@netapp.com>
 <1276241513-17942-2-git-send-email-iisaman@netapp.com>
 <1276241513-17942-3-git-send-email-iisaman@netapp.com>
 <1276241513-17942-4-git-send-email-iisaman@netapp.com>
 <1276241513-17942-5-git-send-email-iisaman@netapp.com>
 <1276241513-17942-6-git-send-email-iisaman@netapp.com>
 <1276241513-17942-7-git-send-email-iisaman@netapp.com>
 <1276241513-17942-8-git-send-email-iisaman@netapp.com>
 <1276241513-17942-9-git-send-email-iisaman@netapp.com>
 <1276241513-17942-10-git-send-email-iisaman@netapp.com>
 <1276241513-17942-11-git-send-email-iisaman@netapp.com>
 <1276241513-17942-12-git-send-email-iisaman@netapp.com>
 <1276241513-17942-13-git-send-email-iisaman@netapp.com>
 <1276241513-17942-14-git-send-email-iisaman@netapp.com>
 <1276241513-17942-15-git-send-email-iisaman@netapp.com>
 <1276241513-17942-16-git-send-email-iisaman@netapp.com>
 <1276241513-17942-17-git-send-email-iisaman@netapp.com>
 <1276241513-17942-18-git-send-email-iisaman@netapp.com>
 <1276241513-17942-19-git-send-email-iisaman@netapp.com>
 <1276241513-17942-20-git-send-email-iisaman@netapp.com>
 <1276241513-17942-21-git-send-email-iisaman@netapp.com>
 <1276241513-17942-22-git-send-email-iisaman@netapp.com>
 <1276241513-17942-23-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:18981 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757983Ab0FKHch (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jun 2010 03:32:37 -0400
Received: from localhost.localdomain (lesleyk-lxp.hq.netapp.com [10.58.52.119] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5B7W3uG024376
	for <linux-nfs@vger.kernel.org>; Fri, 11 Jun 2010 00:32:36 -0700 (PDT)
In-Reply-To: <1276241513-17942-23-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c       |    8 ++++----
 include/linux/nfs_xdr.h |    1 -
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7e6cb89..192afc3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3362,17 +3362,17 @@ static void nfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_messa
 
 #if defined(CONFIG_NFS_V4_1)
 /*
- * pNFS doew not send a getattr to Data Serfers on commit.
+ * pNFS doew not send a getattr to Data Servers on commit.
  */
 static void
 pnfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_message *msg)
 {
 	struct nfs_server *server = NFS_SERVER(data->inode);
 
-	dprintk("--> %s ds_nfs_client %p commit_through_mds %d\n", __func__,
-		data->fldata.ds_nfs_client, data->fldata.commit_through_mds);
+	dprintk("--> %s ds_nfs_client %p\n", __func__,
+		data->fldata.ds_nfs_client);
 
-	if (!data->fldata.ds_nfs_client || data->fldata.commit_through_mds)
+	if (!data->fldata.ds_nfs_client)
 		return nfs4_proc_commit_setup(data, msg);
 
 	data->args.bitmask = server->attr_bitmask;
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 38a5349..22113a1 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -984,7 +984,6 @@ struct pnfs_call_data {
 struct pnfs_fl_call_data {
 	struct nfs_client	*ds_nfs_client;
 	__u64			orig_offset;
-	int			commit_through_mds;
 };
 #endif /* CONFIG_NFS_V4_1 */
 
-- 
1.6.6.1

