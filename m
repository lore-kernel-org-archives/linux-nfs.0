From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfs: fix printout of multiword bitfields
Date: Wed,  2 Apr 2008 15:21:15 +0300
Message-ID: <1207138875-1109-1-git-send-email-bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, pnfs@linux-nfs.org,
	Fred Isaman <iisaman@citi.umich.edu>,
	Benny Halevy <bhalevy@panasas.com>
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bzq-219-195-70.pop.bezeqint.net ([62.219.195.70]:48130 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503AbYDBMVj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Apr 2008 08:21:39 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Fred Isaman <iisaman@citi.umich.edu>

Benny points out that zero-padding of multiword bitfields is necessary,
and that delimiting each word is nice to avoid endianess confusion.

bhalevy: without zero padding output can be ambiguous. Also,
since the printed array of two 32-bit unsigned integers is not a
64-bit number, delimiting the output with a semicolon makes more sense.

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 85fae46..f97aa1f 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1191,8 +1191,8 @@ static int encode_readdir(struct xdr_stream *xdr, const struct nfs4_readdir_arg
 		attrs[1] &= ~FATTR4_WORD1_MOUNTED_ON_FILEID;
 	WRITE32(attrs[0] & readdir->bitmask[0]);
 	WRITE32(attrs[1] & readdir->bitmask[1]);
-	dprintk("%s: cookie = %Lu, verifier = 0x%x%x, bitmap = 0x%x%x\n",
-			__FUNCTION__,
+	dprintk("%s: cookie = %Lu, verifier = %08x:%08x, bitmap = %08x:%08x\n",
+			__func__,
 			(unsigned long long)readdir->cookie,
 			((u32 *)readdir->verifier.data)[0],
 			((u32 *)readdir->verifier.data)[1],
@@ -2291,7 +2291,7 @@ static int decode_attr_supported(struct xdr_stream *xdr, uint32_t *bitmap, uint3
 		bitmap[0] &= ~FATTR4_WORD0_SUPPORTED_ATTRS;
 	} else
 		bitmask[0] = bitmask[1] = 0;
-	dprintk("%s: bitmask=0x%x%x\n", __FUNCTION__, bitmask[0], bitmask[1]);
+	dprintk("%s: bitmask=%08x:%08x\n", __func__, bitmask[0], bitmask[1]);
 	return 0;
 }
 
@@ -3489,8 +3489,8 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 		return status;
 	READ_BUF(8);
 	COPYMEM(readdir->verifier.data, 8);
-	dprintk("%s: verifier = 0x%x%x\n",
-			__FUNCTION__,
+	dprintk("%s: verifier = %08x:%08x\n",
+			__func__,
 			((u32 *)readdir->verifier.data)[0],
 			((u32 *)readdir->verifier.data)[1]);
 
-- 
1.5.3.3

