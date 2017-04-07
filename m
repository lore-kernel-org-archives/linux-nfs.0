Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:54936 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932127AbdDGSPu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:50 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 08/34] NFS: Clean up decode_notify_lock_args()
Date: Fri, 7 Apr 2017 14:15:02 -0400
Message-ID: <20170407181528.2832-9-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Let's cut out the goto and return any errors immedately

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/callback_xdr.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index ce1e293b8a18..4cf70dc59933 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -518,11 +518,8 @@ static __be32 decode_notify_lock_args(struct svc_rqst *rqstp, struct xdr_stream
 
 	status = decode_fh(xdr, &args->cbnl_fh);
 	if (unlikely(status != 0))
-		goto out;
-	status = decode_lockowner(xdr, args);
-out:
-	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
-	return status;
+		return status;
+	return decode_lockowner(xdr, args);
 }
 
 #endif /* CONFIG_NFS_V4_1 */
-- 
2.12.2

