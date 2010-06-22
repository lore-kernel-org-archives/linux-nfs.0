From: andros@netapp.com
Subject: [PATCH 6/8] SQUASHME pnfs-submit: handle assassinated layoutcommit
Date: Tue, 22 Jun 2010 17:56:36 -0400
Message-ID: <1277243798-8181-7-git-send-email-andros@netapp.com>
References: <1277243798-8181-1-git-send-email-andros@netapp.com>
 <1277243798-8181-2-git-send-email-andros@netapp.com>
 <1277243798-8181-3-git-send-email-andros@netapp.com>
 <1277243798-8181-4-git-send-email-andros@netapp.com>
 <1277243798-8181-5-git-send-email-andros@netapp.com>
 <1277243798-8181-6-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36643 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751493Ab0FVV4h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jun 2010 17:56:37 -0400
In-Reply-To: <1277243798-8181-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0ab875f..35e8a56 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5539,6 +5539,8 @@ pnfs_layoutcommit_done(struct rpc_task *task, void *calldata)
 	data->status = task->tk_status;
 
 	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
+	if (RPC_ASSASSINATED(task))
+		return;
 
 	if (nfs4_async_handle_error(task, server, NULL, NULL) == -EAGAIN)
 		nfs_restart_rpc(task, server->nfs_client);
-- 
1.6.6

