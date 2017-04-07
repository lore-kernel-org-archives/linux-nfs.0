Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:46795 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932731AbdDGSPs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:48 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 05/34] NFS: Clean up decode_recall_args()
Date: Fri, 7 Apr 2017 14:14:59 -0400
Message-ID: <20170407181528.2832-6-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Removing the dprintk() lets us simplify the function by returning status
codes directly, rather than using a goto.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/callback_xdr.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index c782261d86d5..0319230fe1a8 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -203,17 +203,12 @@ static __be32 decode_recall_args(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 
 	status = decode_delegation_stateid(xdr, &args->stateid);
 	if (unlikely(status != 0))
-		goto out;
+		return status;
 	p = read_buf(xdr, 4);
-	if (unlikely(p == NULL)) {
-		status = htonl(NFS4ERR_RESOURCE);
-		goto out;
-	}
+	if (unlikely(p == NULL))
+		return htonl(NFS4ERR_RESOURCE);
 	args->truncate = ntohl(*p);
-	status = decode_fh(xdr, &args->fh);
-out:
-	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
-	return status;
+	return decode_fh(xdr, &args->fh);
 }
 
 #if defined(CONFIG_NFS_V4_1)
-- 
2.12.2

