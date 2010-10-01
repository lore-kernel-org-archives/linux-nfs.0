Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9112 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab0JAQDp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 12:03:45 -0400
Received: from localhost.localdomain (vpn2ntap-420885.hq.netapp.com [10.58.51.27])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o91G3Uer008238
	for <linux-nfs@vger.kernel.org>; Fri, 1 Oct 2010 09:03:44 -0700 (PDT)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 7/7] SQUASHME: pnfs_submit: only use asynch error handler for LAYOUTRETURN
Date: Fri,  1 Oct 2010 12:02:51 -0400
Message-Id: <1285948971-2048-8-git-send-email-iisaman@netapp.com>
In-Reply-To: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
References: <1285948971-2048-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4proc.c |   15 +--------------
 1 files changed, 1 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0ac77a6..d29ed4b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5662,7 +5662,7 @@ static const struct rpc_call_ops nfs4_layoutreturn_call_ops = {
 	.rpc_release = nfs4_layoutreturn_release,
 };
 
-int _nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool issync)
+int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool issync)
 {
 	struct inode *ino = lrp->args.inode;
 	struct nfs_server *server = NFS_SERVER(ino);
@@ -5698,19 +5698,6 @@ out:
 	return status;
 }
 
-int nfs4_proc_layoutreturn(struct nfs4_layoutreturn *lrp, bool issync)
-{
-	struct nfs_server *server = NFS_SERVER(lrp->args.inode);
-	struct nfs4_exception exception = { };
-	int err;
-	do {
-		err = nfs4_handle_exception(server,
-				_nfs4_proc_layoutreturn(lrp, issync),
-				&exception);
-	} while (exception.retry);
-	return err;
-}
-
 static int
 _nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
 {
-- 
1.7.2.1

