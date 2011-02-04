Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753230Ab1BDVex (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:53 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 34/40] pnfs-submit wave3 don't use nfs_read_prepare for DS
Date: Fri,  4 Feb 2011 16:33:56 -0500
Message-Id: <1296855242-2592-35-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-34-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
 <1296855242-2592-13-git-send-email-andros@netapp.com>
 <1296855242-2592-14-git-send-email-andros@netapp.com>
 <1296855242-2592-15-git-send-email-andros@netapp.com>
 <1296855242-2592-16-git-send-email-andros@netapp.com>
 <1296855242-2592-17-git-send-email-andros@netapp.com>
 <1296855242-2592-18-git-send-email-andros@netapp.com>
 <1296855242-2592-19-git-send-email-andros@netapp.com>
 <1296855242-2592-20-git-send-email-andros@netapp.com>
 <1296855242-2592-21-git-send-email-andros@netapp.com>
 <1296855242-2592-22-git-send-email-andros@netapp.com>
 <1296855242-2592-23-git-send-email-andros@netapp.com>
 <1296855242-2592-24-git-send-email-andros@netapp.com>
 <1296855242-2592-25-git-send-email-andros@netapp.com>
 <1296855242-2592-26-git-send-email-andros@netapp.com>
 <1296855242-2592-27-git-send-email-andros@netapp.com>
 <1296855242-2592-28-git-send-email-andros@netapp.com>
 <1296855242-2592-29-git-send-email-andros@netapp.com>
 <1296855242-2592-30-git-send-email-andros@netapp.com>
 <1296855242-2592-31-git-send-email-andros@netapp.com>
 <1296855242-2592-32-git-send-email-andros@netapp.com>
 <1296855242-2592-33-git-send-email-andros@netapp.com>
 <1296855242-2592-34-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/read.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 9af3048..cb0b239 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -437,19 +437,13 @@ static void nfs_readpage_release_partial(void *calldata)
 void nfs_read_prepare(struct rpc_task *task, void *calldata)
 {
 	struct nfs_read_data *data = calldata;
-	struct nfs4_session *ds_session = NULL;
 
-	if (data->fldata.ds_nfs_client) {
-		dprintk("%s DS read\n", __func__);
-		ds_session = data->fldata.ds_nfs_client->cl_session;
-	}
 	if (nfs4_setup_sequence(NFS_SERVER(data->inode),
 				&data->args.seq_args, &data->res.seq_res,
 				0, task))
 		return;
 	rpc_call_start(task);
 }
-EXPORT_SYMBOL(nfs_read_prepare);
 #endif /* CONFIG_NFS_V4_1 */
 
 static const struct rpc_call_ops nfs_read_partial_ops = {
-- 
1.6.6

