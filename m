Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43345 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754340Ab1EVXrI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 19:47:08 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v5 06/38] SQUASHME: use be32 res in nfs4_callback_devicenotify
Date: Mon, 23 May 2011 02:46:51 +0300
Message-Id: <1306108011-28016-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DD99F9B.2040406@panasas.com>
References: <4DD99F9B.2040406@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_proc.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 975c8f2..95107fe 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -245,14 +245,14 @@ __be32 nfs4_callback_devicenotify(struct cb_devicenotifyargs *args,
 				  void *dummy, struct cb_process_state *cps)
 {
 	int i;
-	u32 res = 0;
+	__be32 res = 0;
 	struct nfs_client *clp = cps->clp;
 	struct nfs_server *server = NULL;
 
 	dprintk("%s: -->\n", __func__);
 
 	if (!clp) {
-		res = NFS4ERR_OP_NOT_IN_SESSION;
+		res = cpu_to_be32(NFS4ERR_OP_NOT_IN_SESSION);
 		goto out;
 	}
 
@@ -276,7 +276,7 @@ __be32 nfs4_callback_devicenotify(struct cb_devicenotifyargs *args,
 
 	found:
 		if (!server->pnfs_curr_ld->delete_deviceid) {
-			res = NFS4ERR_NOTSUPP;
+			res = cpu_to_be32(NFS4ERR_NOTSUPP);
 			break;
 		}
 		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
@@ -288,8 +288,8 @@ __be32 nfs4_callback_devicenotify(struct cb_devicenotifyargs *args,
 out:
 	kfree(args->devs);
 	dprintk("%s: exit with status = %u\n",
-		__func__, res);
-	return cpu_to_be32(res);
+		__func__, be32_to_cpu(res));
+	return res;
 }
 
 int nfs41_validate_delegation_stateid(struct nfs_delegation *delegation, const nfs4_stateid *stateid)
-- 
1.7.3.4

