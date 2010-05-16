From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 22/22] pnfs_submit: remove unecessary pnfs_fl_call_data field commit_through_mds
Date: Sat, 15 May 2010 21:23:13 -0400
Message-ID: <1273972993-15369-23-git-send-email-iisaman@netapp.com>
References: <1273972993-15369-1-git-send-email-iisaman@netapp.com>
 <1273972993-15369-2-git-send-email-iisaman@netapp.com>
 <1273972993-15369-3-git-send-email-iisaman@netapp.com>
 <1273972993-15369-4-git-send-email-iisaman@netapp.com>
 <1273972993-15369-5-git-send-email-iisaman@netapp.com>
 <1273972993-15369-6-git-send-email-iisaman@netapp.com>
 <1273972993-15369-7-git-send-email-iisaman@netapp.com>
 <1273972993-15369-8-git-send-email-iisaman@netapp.com>
 <1273972993-15369-9-git-send-email-iisaman@netapp.com>
 <1273972993-15369-10-git-send-email-iisaman@netapp.com>
 <1273972993-15369-11-git-send-email-iisaman@netapp.com>
 <1273972993-15369-12-git-send-email-iisaman@netapp.com>
 <1273972993-15369-13-git-send-email-iisaman@netapp.com>
 <1273972993-15369-14-git-send-email-iisaman@netapp.com>
 <1273972993-15369-15-git-send-email-iisaman@netapp.com>
 <1273972993-15369-16-git-send-email-iisaman@netapp.com>
 <1273972993-15369-17-git-send-email-iisaman@netapp.com>
 <1273972993-15369-18-git-send-email-iisaman@netapp.com>
 <1273972993-15369-19-git-send-email-iisaman@netapp.com>
 <1273972993-15369-20-git-send-email-iisaman@netapp.com>
 <1273972993-15369-21-git-send-email-iisaman@netapp.com>
 <1273972993-15369-22-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47588 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754859Ab0ETKat (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 06:30:49 -0400
Received: from localhost.localdomain (vpn2ntap-176975.hq.netapp.com [10.58.56.200])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o4KAUQcC022655
	for <linux-nfs@vger.kernel.org>; Thu, 20 May 2010 03:30:49 -0700 (PDT)
In-Reply-To: <1273972993-15369-22-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c       |    8 ++++----
 include/linux/nfs_xdr.h |    1 -
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9786391..d62d008 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3338,17 +3338,17 @@ static void nfs4_proc_commit_setup(struct nfs_write_data *data, struct rpc_messa
 
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
index 27d811b..134e33f 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -977,7 +977,6 @@ struct pnfs_call_data {
 struct pnfs_fl_call_data {
 	struct nfs_client	*ds_nfs_client;
 	__u64			orig_offset;
-	int			commit_through_mds;
 };
 #endif /* CONFIG_NFS_V4_1 */
 
-- 
1.6.6.1

