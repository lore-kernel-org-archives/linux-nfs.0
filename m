From: andros@netapp.com
Subject: [PATCH 2/4] SQUASHME pnfs-submit: handle async layoutcommit errors
Date: Thu,  3 Jun 2010 12:25:25 -0400
Message-ID: <1275582327-9285-3-git-send-email-andros@netapp.com>
References: <1275582327-9285-1-git-send-email-andros@netapp.com>
 <1275582327-9285-2-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55065 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755137Ab0FCQZa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jun 2010 12:25:30 -0400
In-Reply-To: <1275582327-9285-2-git-send-email-andros@netapp.com>
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
index 8b375a7..19ac602 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5628,6 +5628,9 @@ pnfs_layoutcommit_rpc_done(struct rpc_task *task, void *calldata)
 	pnfs_layoutcommit_done(data);
 
 	nfs4_sequence_done(server, &data->res.seq_res, task->tk_status);
+
+	if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN)
+		nfs_restart_rpc(task, server->nfs_client);
 }
 
 static void pnfs_layoutcommit_release(void *lcdata)
-- 
1.6.2.5

