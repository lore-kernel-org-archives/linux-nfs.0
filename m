Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51329 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757812Ab1BKSAn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 13:00:43 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 05/17] SQUASHME rename nfs_read_data call_ops TWO
Date: Thu, 10 Feb 2011 20:52:38 -0500
Message-Id: <1297389170-26702-6-git-send-email-andros@netapp.com>
In-Reply-To: <1297389170-26702-5-git-send-email-andros@netapp.com>
References: <1297389170-26702-1-git-send-email-andros@netapp.com>
 <1297389170-26702-2-git-send-email-andros@netapp.com>
 <1297389170-26702-3-git-send-email-andros@netapp.com>
 <1297389170-26702-4-git-send-email-andros@netapp.com>
 <1297389170-26702-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs-submit wave3 filelayout read done

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9dee49d..64a0d4f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3115,7 +3115,7 @@ void nfs4_reset_read(struct rpc_task *task, struct nfs_read_data *data)
 	data->ds_clp = NULL;
 	data->args.fh     = NFS_FH(data->inode);
 	data->read_done_cb = nfs4_read_done_cb;
-	task->tk_ops = data->call_ops;
+	task->tk_ops = data->mds_ops;
 	rpc_task_reset_client(task, NFS_CLIENT(data->inode));
 }
 EXPORT_SYMBOL_GPL(nfs4_reset_read);
-- 
1.6.6

