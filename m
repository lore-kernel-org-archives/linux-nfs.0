Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:46502 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965640AbbKFVvt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Nov 2015 16:51:49 -0500
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 2829128023D
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2015 22:43:13 +0100 (CET)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 1BB1214B1
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2015 22:43:11 +0100 (MET)
Received: from smtp-intra-1.desy.de (lb-40-26.desy.de) by ZITSWEEP2.win.desy.de
 (Clearswift SMTPRS 5.5.0) with ESMTP id <Tbdeb608b6c83a9616012e0@ZITSWEEP2.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Fri, 6 Nov 2015 22:43:11 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH] nfs: bump printk level to log pnfs errors
Date: Fri,  6 Nov 2015 22:43:08 +0100
Message-Id: <1446846188-13944-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

log as INFO level why pnfs client falled back to IO
through MDS.

example:

    NFS: filelayout_async_handle_error: Retry through MDS. DS [2001:638:700:10bf::1:8d]:32049 error -5

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/filelayout/filelayout.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 02ec079..0838b62 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -206,8 +206,8 @@ static int filelayout_async_handle_error(struct rpc_task *task,
 		/* fall through */
 	default:
 reset:
-		dprintk("%s Retry through MDS. Error %d\n", __func__,
-			task->tk_status);
+		printk(KERN_INFO "NFS: %s: Retry through MDS. DS %pISpc error %d\n", __func__,
+			&task->tk_client->cl_xprt->addr, task->tk_status);
 		return -NFS4ERR_RESET_TO_MDS;
 	}
 out:
-- 
2.5.0

