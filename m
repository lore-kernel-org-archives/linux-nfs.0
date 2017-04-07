Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:41488 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933010AbdDGSPt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:49 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 06/34] NFS: Clean up decode_layoutrecall_args()
Date: Fri, 7 Apr 2017 14:15:00 -0400
Message-ID: <20170407181528.2832-7-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Additionally, this change lets us cut out the goto by returning errors
immediately.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/callback_xdr.c | 38 +++++++++++---------------------------
 1 file changed, 11 insertions(+), 27 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 0319230fe1a8..d5ddceb91a9a 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -227,10 +227,8 @@ static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
 	uint32_t iomode;
 
 	p = read_buf(xdr, 4 * sizeof(uint32_t));
-	if (unlikely(p == NULL)) {
-		status = htonl(NFS4ERR_BADXDR);
-		goto out;
-	}
+	if (unlikely(p == NULL))
+		return htonl(NFS4ERR_BADXDR);
 
 	args->cbl_layout_type = ntohl(*p++);
 	/* Depite the spec's xdr, iomode really belongs in the FILE switch,
@@ -244,37 +242,23 @@ static __be32 decode_layoutrecall_args(struct svc_rqst *rqstp,
 		args->cbl_range.iomode = iomode;
 		status = decode_fh(xdr, &args->cbl_fh);
 		if (unlikely(status != 0))
-			goto out;
+			return status;
 
 		p = read_buf(xdr, 2 * sizeof(uint64_t));
-		if (unlikely(p == NULL)) {
-			status = htonl(NFS4ERR_BADXDR);
-			goto out;
-		}
+		if (unlikely(p == NULL))
+			return htonl(NFS4ERR_BADXDR);
 		p = xdr_decode_hyper(p, &args->cbl_range.offset);
 		p = xdr_decode_hyper(p, &args->cbl_range.length);
-		status = decode_layout_stateid(xdr, &args->cbl_stateid);
-		if (unlikely(status != 0))
-			goto out;
+		return decode_layout_stateid(xdr, &args->cbl_stateid);
 	} else if (args->cbl_recall_type == RETURN_FSID) {
 		p = read_buf(xdr, 2 * sizeof(uint64_t));
-		if (unlikely(p == NULL)) {
-			status = htonl(NFS4ERR_BADXDR);
-			goto out;
-		}
+		if (unlikely(p == NULL))
+			return htonl(NFS4ERR_BADXDR);
 		p = xdr_decode_hyper(p, &args->cbl_fsid.major);
 		p = xdr_decode_hyper(p, &args->cbl_fsid.minor);
-	} else if (args->cbl_recall_type != RETURN_ALL) {
-		status = htonl(NFS4ERR_BADXDR);
-		goto out;
-	}
-	dprintk("%s: ltype 0x%x iomode %d changed %d recall_type %d\n",
-		__func__,
-		args->cbl_layout_type, iomode,
-		args->cbl_layoutchanged, args->cbl_recall_type);
-out:
-	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
-	return status;
+	} else if (args->cbl_recall_type != RETURN_ALL)
+		return htonl(NFS4ERR_BADXDR);
+	return 0;
 }
 
 static
-- 
2.12.2

