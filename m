Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:42777 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932835Ab1AMJZg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 04:25:36 -0500
From: Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] NFSD: use nfserr for status after decode_cb_op_status
Date: Thu, 13 Jan 2011 11:25:31 +0200
Message-Id: <1294910731-18370-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4D2EC4AC.9090205@panasas.com>
References: <4D2EC4AC.9090205@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Bugs introduced in 85a56480191ca9f08fc775c129b9eb5c8c1f2c05
"NFSD: Update XDR decoders in NFSv4 callback client"

Cc: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 21a63da..5a6dcf8 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -484,7 +484,7 @@ static int decode_cb_sequence4res(struct xdr_stream *xdr,
 out:
 	return status;
 out_default:
-	return nfs_cb_stat_to_errno(status);
+	return nfs_cb_stat_to_errno(nfserr);
 }
 
 /*
@@ -564,11 +564,9 @@ static int nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp,
 	if (unlikely(status))
 		goto out;
 	if (unlikely(nfserr != NFS4_OK))
-		goto out_default;
+		status = nfs_cb_stat_to_errno(nfserr);
 out:
 	return status;
-out_default:
-	return nfs_cb_stat_to_errno(status);
 }
 
 /*
-- 
1.7.3.4

