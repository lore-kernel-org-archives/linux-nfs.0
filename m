Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:49973 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932127AbdDGSPr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:47 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 02/34] NFS: Clean up nfs4_callback_layoutrecall()
Date: Fri, 7 Apr 2017 14:14:56 -0400
Message-ID: <20170407181528.2832-3-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

In addition to removing the dprintk(), this patch also initializes "res"
to the default return value instead of doing this through an else
condition.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/callback_proc.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index c52408055721..e61e4ccc181a 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -325,16 +325,10 @@ static u32 do_callback_layoutrecall(struct nfs_client *clp,
 __be32 nfs4_callback_layoutrecall(struct cb_layoutrecallargs *args,
 				  void *dummy, struct cb_process_state *cps)
 {
-	u32 res;
-
-	dprintk("%s: -->\n", __func__);
+	u32 res = NFS4ERR_OP_NOT_IN_SESSION;
 
 	if (cps->clp)
 		res = do_callback_layoutrecall(cps->clp, args);
-	else
-		res = NFS4ERR_OP_NOT_IN_SESSION;
-
-	dprintk("%s: exit with status = %d\n", __func__, res);
 	return cpu_to_be32(res);
 }
 
-- 
2.12.2

