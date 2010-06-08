From: Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 23/24] pnfs_submit: remove unecessary pnfs_fl_call_data field commit_through_mds
Date: Tue,  8 Jun 2010 00:19:20 -0400
Message-ID: <1275970761-31806-24-git-send-email-iisaman@netapp.com>
References: <1275970761-31806-1-git-send-email-iisaman@netapp.com>
 <1275970761-31806-2-git-send-email-iisaman@netapp.com>
 <1275970761-31806-3-git-send-email-iisaman@netapp.com>
 <1275970761-31806-4-git-send-email-iisaman@netapp.com>
 <1275970761-31806-5-git-send-email-iisaman@netapp.com>
 <1275970761-31806-6-git-send-email-iisaman@netapp.com>
 <1275970761-31806-7-git-send-email-iisaman@netapp.com>
 <1275970761-31806-8-git-send-email-iisaman@netapp.com>
 <1275970761-31806-9-git-send-email-iisaman@netapp.com>
 <1275970761-31806-10-git-send-email-iisaman@netapp.com>
 <1275970761-31806-11-git-send-email-iisaman@netapp.com>
 <1275970761-31806-12-git-send-email-iisaman@netapp.com>
 <1275970761-31806-13-git-send-email-iisaman@netapp.com>
 <1275970761-31806-14-git-send-email-iisaman@netapp.com>
 <1275970761-31806-15-git-send-email-iisaman@netapp.com>
 <1275970761-31806-16-git-send-email-iisaman@netapp.com>
 <1275970761-31806-17-git-send-email-iisaman@netapp.com>
 <1275970761-31806-18-git-send-email-iisaman@netapp.com>
 <1275970761-31806-19-git-send-email-iisaman@netapp.com>
 <1275970761-31806-20-git-send-email-iisaman@netapp.com>
 <1275970761-31806-21-git-send-email-iisaman@netapp.com>
 <1275970761-31806-22-git-send-email-iisaman@netapp.com>
 <1275970761-31806-23-git-send-email-iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37342 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752005Ab0FHETu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jun 2010 00:19:50 -0400
Received: from localhost.localdomain (navitha-lxp.hq.netapp.com [10.58.53.227] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o584JOQE014203
	for <linux-nfs@vger.kernel.org>; Mon, 7 Jun 2010 21:19:41 -0700 (PDT)
In-Reply-To: <1275970761-31806-23-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c       |    8 ++++----
 include/linux/nfs_xdr.h |    1 -
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index aa4581a..ca17872 100644
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
index 183a9c3..2acdb8e 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -982,7 +982,6 @@ struct pnfs_call_data {
 struct pnfs_fl_call_data {
 	struct nfs_client	*ds_nfs_client;
 	__u64			orig_offset;
-	int			commit_through_mds;
 };
 #endif /* CONFIG_NFS_V4_1 */
 
-- 
1.6.6.1

