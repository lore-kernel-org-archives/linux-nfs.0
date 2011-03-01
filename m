Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1570 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756231Ab1CATZx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2011 14:25:53 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
Subject: [PATCH pnfs-submit-wave3 update 2/5] wave3: clean up nfs4_reset_read to match write
Date: Tue,  1 Mar 2011 14:25:31 -0500
Message-Id: <1299007534-4105-3-git-send-email-andros@netapp.com>
In-Reply-To: <1299007534-4105-2-git-send-email-andros@netapp.com>
References: <1299007534-4105-1-git-send-email-andros@netapp.com>
 <1299007534-4105-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

found a bug in write version of this code, make read code
match fix to write

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    2 +-
 fs/nfs/nfs4proc.c       |    2 ++
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index c26b655..45b650a 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -142,8 +142,8 @@ static int filelayout_read_done_cb(struct rpc_task *task,
 		dprintk("%s calling restart ds_clp %p ds_clp->cl_session %p\n",
 			__func__, data->ds_clp, data->ds_clp->cl_session);
 		if (reset) {
-			nfs4_reset_read(task, data);
 			filelayout_set_lo_fail(data->lseg);
+			nfs4_reset_read(task, data);
 			clp = NFS_SERVER(data->inode)->nfs_client;
 		}
 		nfs_restart_rpc(task, clp);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index a54d8e6..5742a5e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3112,6 +3112,8 @@ static void nfs4_proc_read_setup(struct nfs_read_data *data, struct rpc_message
 void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data)
 {
 	dprintk("%s Reset task for i/o through\n", __func__);
+	put_lseg(data->lseg);
+	data->lseg = NULL;
 	/* offsets will differ in the dense stripe case */
 	data->args.offset = data->mds_offset;
 	data->ds_clp = NULL;
-- 
1.6.2.5

