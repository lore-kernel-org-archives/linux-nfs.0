From: andros@netapp.com
Subject: [PATCH 5/6] SQUASHME pnfs-submit: handle async layoutcommit errors
Date: Wed,  2 Jun 2010 11:54:26 -0400
Message-ID: <1275494067-4058-6-git-send-email-andros@netapp.com>
References: <1275494067-4058-1-git-send-email-andros@netapp.com>
 <1275494067-4058-2-git-send-email-andros@netapp.com>
 <1275494067-4058-3-git-send-email-andros@netapp.com>
 <1275494067-4058-4-git-send-email-andros@netapp.com>
 <1275494067-4058-5-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38483 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758337Ab0FBRz0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jun 2010 13:55:26 -0400
In-Reply-To: <1275494067-4058-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

nfs4_async_handle_error handles session level and grace,delay errors.

NOTE: Layout specific errors (NFS4ERR_BADIOMODE, NFS4ERR_BAD_LAYOUT,
NFS4ERR_UNKNOWN_LAYOUTTYPE) need to be handled.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 2826ada..514c5c6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5628,6 +5628,9 @@ pnfs_layoutcommit_rpc_done(struct rpc_task *task, void *calldata)
 	put_rpccred(data->cred);
 
 	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
+
+	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN)
+		nfs_restart_rpc(task, server->nfs_client);
 }
 
 static void pnfs_layoutcommit_release(void *lcdata)
-- 
1.6.6

