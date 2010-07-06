From: andros@netapp.com
Subject: [PATCH 5/5] SQUASHME pnfs-submit: set layoutget status after async error handler
Date: Tue,  6 Jul 2010 17:17:02 -0400
Message-ID: <1278451022-2889-6-git-send-email-andros@netapp.com>
References: <1278451022-2889-1-git-send-email-andros@netapp.com>
 <1278451022-2889-2-git-send-email-andros@netapp.com>
 <1278451022-2889-3-git-send-email-andros@netapp.com>
 <1278451022-2889-4-git-send-email-andros@netapp.com>
 <1278451022-2889-5-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61433 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754336Ab0GFURP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jul 2010 16:17:15 -0400
In-Reply-To: <1278451022-2889-5-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 36de1b3..c5b8a2f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5450,6 +5450,7 @@ static void nfs4_pnfs_layoutget_done(struct rpc_task *task, void *calldata)
 	if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN)
 		nfs_restart_rpc(task, server->nfs_client);
 
+	lgp->status = task->tk_status;
 	dprintk("<-- %s\n", __func__);
 }
 
-- 
1.6.6

