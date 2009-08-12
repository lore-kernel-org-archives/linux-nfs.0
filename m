From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC 12/13] nfs: nfs4xdr: change COPYMEM macro into a static function
Date: Wed, 12 Aug 2009 18:22:43 +0300
Message-ID: <1250090563-9895-1-git-send-email-bhalevy@panasas.com>
References: <4A82DC7B.3090600@panasas.com>
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:10694
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752721AbZHLPWv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Aug 2009 11:22:51 -0400
In-Reply-To: <4A82DC7B.3090600@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   39 ++++++++++++++++++++-------------------
 1 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2e83aef..ed9bbd2 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2448,11 +2448,6 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
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
@@ -2464,6 +2459,12 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
 	} \
 } while (0)
 
+static __be32 *copymem(void *x, __be32 *p, u32 nbytes)
+{
+	memcpy(x, p, nbytes);
+	return p + XDR_QUADLEN(nbytes);
+}
+
 static int decode_opaque_inline(struct xdr_stream *xdr, unsigned int *len, char **string)
 {
 	__be32 *p;
@@ -3312,7 +3313,7 @@ static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
 	if (status)
 		return status;
 	READ_BUF(NFS4_STATEID_SIZE);
-	COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
+	copymem(res->stateid.data, p, NFS4_STATEID_SIZE);
 	return 0;
 }
 
@@ -3325,7 +3326,7 @@ static int decode_commit(struct xdr_stream *xdr, struct nfs_writeres *res)
 	if (status)
 		return status;
 	READ_BUF(8);
-	COPYMEM(res->verf->verifier, 8);
+	copymem(res->verf->verifier, p, 8);
 	return 0;
 }
 
@@ -3601,7 +3602,7 @@ static int decode_getfh(struct xdr_stream *xdr, struct nfs_fh *fh)
 		return -EIO;
 	fh->size = len;
 	READ_BUF(len);
-	COPYMEM(fh->data, len);
+	copymem(fh->data, p, len);
 	return 0;
 }
 
@@ -3654,7 +3655,7 @@ static int decode_lock(struct xdr_stream *xdr, struct nfs_lock_res *res)
 		goto out;
 	if (status == 0) {
 		READ_BUF(NFS4_STATEID_SIZE);
-		COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
+		copymem(res->stateid.data, p, NFS4_STATEID_SIZE);
 	} else if (status == -NFS4ERR_DENIED)
 		status = decode_lock_denied(xdr, NULL);
 	if (res->open_seqid != NULL)
@@ -3683,7 +3684,7 @@ static int decode_locku(struct xdr_stream *xdr, struct nfs_locku_res *res)
 		nfs_increment_lock_seqid(status, res->seqid);
 	if (status == 0) {
 		READ_BUF(NFS4_STATEID_SIZE);
-		COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
+		copymem(res->stateid.data, p, NFS4_STATEID_SIZE);
 	}
 	return status;
 }
@@ -3725,7 +3726,7 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
 		return 0;
 	}
 	READ_BUF(NFS4_STATEID_SIZE+4);
-	COPYMEM(res->delegation.data, NFS4_STATEID_SIZE);
+	p = copymem(res->delegation.data, p, NFS4_STATEID_SIZE);
 	p = xdr_decode_int(p, &res->do_recall);
 
 	switch (delegation_type) {
@@ -3752,7 +3753,7 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 	if (status)
 		return status;
 	READ_BUF(NFS4_STATEID_SIZE);
-	COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
+	p = copymem(res->stateid.data, p, NFS4_STATEID_SIZE);
 
 	decode_change_info(xdr, &res->cinfo);
 
@@ -3786,7 +3787,7 @@ static int decode_open_confirm(struct xdr_stream *xdr, struct nfs_open_confirmre
 	if (status)
 		return status;
 	READ_BUF(NFS4_STATEID_SIZE);
-	COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
+	copymem(res->stateid.data, p, NFS4_STATEID_SIZE);
 	return 0;
 }
 
@@ -3801,7 +3802,7 @@ static int decode_open_downgrade(struct xdr_stream *xdr, struct nfs_closeres *re
 	if (status)
 		return status;
 	READ_BUF(NFS4_STATEID_SIZE);
-	COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
+	copymem(res->stateid.data, p, NFS4_STATEID_SIZE);
 	return 0;
 }
 
@@ -3857,7 +3858,7 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
 	if (status)
 		return status;
 	READ_BUF(8);
-	COPYMEM(readdir->verifier.data, 8);
+	p = copymem(readdir->verifier.data, p, 8);
 	dprintk("%s: verifier = %08x:%08x\n",
 			__func__,
 			((u32 *)readdir->verifier.data)[0],
@@ -4097,7 +4098,7 @@ static int decode_setclientid(struct xdr_stream *xdr, struct nfs_client *clp)
 	if (nfserr == NFS_OK) {
 		READ_BUF(8 + NFS4_VERIFIER_SIZE);
 		p = xdr_decode_hyper(p, &clp->cl_clientid);
-		COPYMEM(clp->cl_confirm.data, NFS4_VERIFIER_SIZE);
+		copymem(clp->cl_confirm.data, p, NFS4_VERIFIER_SIZE);
 	} else if (nfserr == NFSERR_CLID_INUSE) {
 		uint32_t len;
 
@@ -4134,7 +4135,7 @@ static int decode_write(struct xdr_stream *xdr, struct nfs_writeres *res)
 	READ_BUF(16);
 	p = xdr_decode_int(p, &res->count);
 	p = xdr_decode_int(p, &res->verf->committed);
-	COPYMEM(res->verf->verifier, 8);
+	copymem(res->verf->verifier, p, 8);
 	return 0;
 }
 
@@ -4227,7 +4228,7 @@ static int decode_create_session(struct xdr_stream *xdr,
 
 	/* sessionid */
 	READ_BUF(NFS4_MAX_SESSIONID_LEN);
-	COPYMEM(&session->sess_id, NFS4_MAX_SESSIONID_LEN);
+	copymem(&session->sess_id, p, NFS4_MAX_SESSIONID_LEN);
 
 	/* seqid, flags */
 	READ_BUF(8);
@@ -4273,7 +4274,7 @@ static int decode_sequence(struct xdr_stream *xdr,
 
 	slot = &res->sr_session->fc_slot_table.slots[res->sr_slotid];
 	READ_BUF(NFS4_MAX_SESSIONID_LEN + 20);
-	COPYMEM(id.data, NFS4_MAX_SESSIONID_LEN);
+	p = copymem(id.data, p, NFS4_MAX_SESSIONID_LEN);
 	if (memcmp(id.data, res->sr_session->sess_id.data,
 		   NFS4_MAX_SESSIONID_LEN)) {
 		dprintk("%s Invalid session id\n", __func__);
-- 
1.6.4

