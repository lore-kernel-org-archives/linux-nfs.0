Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:54936 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932105AbdDGSPr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:47 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 01/34] NFS: Clean up do_callback_layoutrecall()
Date: Fri, 7 Apr 2017 14:14:55 -0400
Message-ID: <20170407181528.2832-2-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Removing the dprintk()s lets us simplify the function by removing the
else condition entirely and returning the status of
initiate_{file,bulk}_draining() directly.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/callback_proc.c | 11 ++---------
 1 file changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index f073a6d2c6a5..c52408055721 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -317,16 +317,9 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
 static u32 do_callback_layoutrecall(struct nfs_client *clp,
 				    struct cb_layoutrecallargs *args)
 {
-	u32 res;
-
-	dprintk("%s enter, type=%i\n", __func__, args->cbl_recall_type);
 	if (args->cbl_recall_type == RETURN_FILE)
-		res = initiate_file_draining(clp, args);
-	else
-		res = initiate_bulk_draining(clp, args);
-	dprintk("%s returning %i\n", __func__, res);
-	return res;
-
+		return initiate_file_draining(clp, args);
+	return initiate_bulk_draining(clp, args);
 }
 
 __be32 nfs4_callback_layoutrecall(struct cb_layoutrecallargs *args,
-- 
2.12.2

