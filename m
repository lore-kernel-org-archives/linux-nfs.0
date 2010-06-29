From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: pnfs: check for read_buf error in decode_pnfs_layoutrecall_args
Date: Tue, 29 Jun 2010 13:55:56 +0300
Message-ID: <1277808956-7694-1-git-send-email-bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:22521 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755385Ab0F2K4D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 06:56:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

read_buf may return NULL. return NFS4ERR_RESOURCE in this case.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_xdr.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 7e34bb3..2f69f0d 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -247,6 +247,10 @@ static __be32 decode_pnfs_layoutrecall_args(struct svc_rqst *rqstp,
 			goto out;
 
 		p = read_buf(xdr, 2 * sizeof(uint64_t));
+		if (unlikely(p == NULL)) {
+			status = htonl(NFS4ERR_RESOURCE);
+			goto out;
+		}
 		p = xdr_decode_hyper(p, &args->cbl_seg.offset);
 		p = xdr_decode_hyper(p, &args->cbl_seg.length);
 		status = decode_stateid(xdr, &args->cbl_stateid);
@@ -254,6 +258,10 @@ static __be32 decode_pnfs_layoutrecall_args(struct svc_rqst *rqstp,
 			goto out;
 	} else if (args->cbl_recall_type == RETURN_FSID) {
 		p = read_buf(xdr, 2 * sizeof(uint64_t));
+		if (unlikely(p == NULL)) {
+			status = htonl(NFS4ERR_RESOURCE);
+			goto out;
+		}
 		p = xdr_decode_hyper(p, &args->cbl_fsid.major);
 		p = xdr_decode_hyper(p, &args->cbl_fsid.minor);
 	}
-- 
1.6.6.1

