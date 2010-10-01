Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9112 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab0JAQDo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 12:03:44 -0400
Received: from localhost.localdomain (vpn2ntap-420885.hq.netapp.com [10.58.51.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o91G3Ueq008238
	for <linux-nfs@vger.kernel.org>; Fri, 1 Oct 2010 09:03:43 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/7] SQUASHME: pnfs_submit: Only use asynch error handler for LAYOUTCOMMIT
Date: Fri,  1 Oct 2010 12:02:50 -0400
Message-Id: <1285948971-2048-7-git-send-email-iisaman@netapp.com>
In-Reply-To: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
References: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |   18 ++----------------
 1 files changed, 2 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index e28da81..0ac77a6 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5561,8 +5561,8 @@ static const struct rpc_call_ops nfs4_layoutcommit_ops = {
 };
 
 /* Execute a layoutcommit to the server */
-static int
-_nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, int issync)
+int
+nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, int issync)
 {
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTCOMMIT],
@@ -5605,20 +5605,6 @@ out:
 	return 0;
 }
 
-int nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, int issync)
-{
-	struct nfs4_exception exception = { };
-	struct nfs_server *server = NFS_SERVER(data->args.inode);
-	int err;
-
-	do {
-		err = nfs4_handle_exception(server,
-					_nfs4_proc_layoutcommit(data, issync),
-					&exception);
-	} while (exception.retry);
-	return err;
-}
-
 static void
 nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
 {
-- 
1.7.2.1

