From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC v2 18/21] nfs: nfs4xdr: get rid of COPYMEM
Date: Fri, 14 Aug 2009 17:20:05 +0300
Message-ID: <1250259605-14057-1-git-send-email-bhalevy@panasas.com>
References: <4A8571E2.8020800@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:27533
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932159AbZHNOUM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Aug 2009 10:20:12 -0400
In-Reply-To: <4A8571E2.8020800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just directly call memcpy.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index af08947..9187af9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2433,11 +2433,6 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
  * task to translate them into Linux-specific versions which are more
  * consistent with the style used in NFSv2/v3...
  */
-#define COPYMEM(x,nbytes) do {			\
-	memcpy((x), p, nbytes);			\
-	p += XDR_QUADLEN(nbytes);		\
-} while (0)
-
 #define READ_BUF(nbytes)  do { \
 	p = xdr_inline_decode(xdr, nbytes); \
 	if (unlikely(!p)) { \
@@ -3607,7 +3602,7 @@ static int decode_getfh(struct xdr_stream *xdr, struct nfs_fh *fh)
 		return -EIO;
 	fh->size = len;
 	READ_BUF(len);
-	COPYMEM(fh->data, len);
+	memcpy(fh->data, p, len);
 	return 0;
 }
 
@@ -4097,7 +4092,7 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 	if (nfserr == NFS_OK) {
 		READ_BUF(8 + NFS4_VERIFIER_SIZE);
 		p = xdr_decode_hyper(p, &clp->cl_clientid);
-		COPYMEM(clp->cl_confirm.data, NFS4_VERIFIER_SIZE);
+		memcpy(clp->cl_confirm.data, p, NFS4_VERIFIER_SIZE);
 	} else if (nfserr == NFSERR_CLID_INUSE) {
 		uint32_t len;
 
@@ -4134,7 +4129,7 @@ static int decode_write(struct xdr_stream *xdr, struct nfs_writeres *res)
 	READ_BUF(16);
 	res->count = be32_to_cpup(p++);
 	res->verf->committed = be32_to_cpup(p++);
-	COPYMEM(res->verf->verifier, 8);
+	memcpy(res->verf->verifier, p, 8);
 	return 0;
 }
 
-- 
1.6.4

