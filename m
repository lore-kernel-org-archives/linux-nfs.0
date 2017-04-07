Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:26541 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933017AbdDGSPu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:50 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 07/34] NFS: Clean up decode_cb_sequence_args()
Date: Fri, 7 Apr 2017 14:15:01 -0400
Message-ID: <20170407181528.2832-8-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/callback_xdr.c | 25 +++++--------------------
 1 file changed, 5 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index d5ddceb91a9a..ce1e293b8a18 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -413,12 +413,11 @@ static __be32 decode_cb_sequence_args(struct svc_rqst *rqstp,
 
 	status = decode_sessionid(xdr, &args->csa_sessionid);
 	if (status)
-		goto out;
+		return status;
 
-	status = htonl(NFS4ERR_RESOURCE);
 	p = read_buf(xdr, 5 * sizeof(uint32_t));
 	if (unlikely(p == NULL))
-		goto out;
+		return htonl(NFS4ERR_RESOURCE);
 
 	args->csa_addr = svc_addr(rqstp);
 	args->csa_sequenceid = ntohl(*p++);
@@ -432,7 +431,7 @@ static __be32 decode_cb_sequence_args(struct svc_rqst *rqstp,
 						  sizeof(*args->csa_rclists),
 						  GFP_KERNEL);
 		if (unlikely(args->csa_rclists == NULL))
-			goto out;
+			return htonl(NFS4ERR_RESOURCE);
 
 		for (i = 0; i < args->csa_nrclists; i++) {
 			status = decode_rc_list(xdr, &args->csa_rclists[i]);
@@ -442,27 +441,13 @@ static __be32 decode_cb_sequence_args(struct svc_rqst *rqstp,
 			}
 		}
 	}
-	status = 0;
-
-	dprintk("%s: sessionid %x:%x:%x:%x sequenceid %u slotid %u "
-		"highestslotid %u cachethis %d nrclists %u\n",
-		__func__,
-		((u32 *)&args->csa_sessionid)[0],
-		((u32 *)&args->csa_sessionid)[1],
-		((u32 *)&args->csa_sessionid)[2],
-		((u32 *)&args->csa_sessionid)[3],
-		args->csa_sequenceid, args->csa_slotid,
-		args->csa_highestslotid, args->csa_cachethis,
-		args->csa_nrclists);
-out:
-	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
-	return status;
+	return 0;
 
 out_free:
 	for (i = 0; i < args->csa_nrclists; i++)
 		kfree(args->csa_rclists[i].rcl_refcalls);
 	kfree(args->csa_rclists);
-	goto out;
+	return status;
 }
 
 static __be32 decode_recallany_args(struct svc_rqst *rqstp,
-- 
2.12.2

