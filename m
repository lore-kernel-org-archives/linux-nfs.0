From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 25/67] NFS: use dynamically computed compound_hdr.replen for xdr_inline_pages offset
Date: Thu,  2 Apr 2009 16:53:40 +0300
Message-ID: <1238680420-14183-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:32545 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752784AbZDBNxt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:53:49 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As Trond suggested, rather than passing a constant to xdr_inline_pages,
keep a running count of the expected reply bytes.  In preparation for
nfs41, where additional op sequence are expteced when talking to nfs41
servers.

[NFS: cb_compoundhdr.replen is in words not bytes]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: get fs_locations replen before encoding the GETATTR]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: get getacl replen before encoding the GETATTR]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   48 ++++++++++--------------------------------------
 1 files changed, 10 insertions(+), 38 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 746c6a5..6888946 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1721,20 +1721,13 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
-	unsigned int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_readlink(&xdr, args, req, &hdr);
 
-	/* set up reply kvec
-	 *    toplevel_status + taglen + rescount + OP_PUTFH + status
-	 *      + OP_READLINK + status + string length = 8
-	 */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS4_dec_readlink_sz) << 2;
-	xdr_inline_pages(&req->rq_rcv_buf, replen, args->pages,
+	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2, args->pages,
 			args->pgbase, args->pglen);
 	encode_nops(&hdr);
 	return 0;
@@ -1749,23 +1742,16 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
-	int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_readdir(&xdr, args, req, &hdr);
 
-	/* set up reply kvec
-	 *    toplevel_status + taglen + rescount + OP_PUTFH + status
-	 *      + OP_READDIR + status + verifer(2)  = 9
-	 */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS4_dec_readdir_sz) << 2;
-	xdr_inline_pages(&req->rq_rcv_buf, replen, args->pages,
+	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2, args->pages,
 			 args->pgbase, args->count);
 	dprintk("%s: inlined page args = (%u, %p, %u, %u)\n",
-			__func__, replen, args->pages,
+			__func__, hdr.replen << 2, args->pages,
 			args->pgbase, args->count);
 	encode_nops(&hdr);
 	return 0;
@@ -1776,24 +1762,17 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
  */
 static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readargs *args)
 {
-	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	struct xdr_stream xdr;
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_read(&xdr, args, &hdr);
 
-	/* set up reply kvec
-	 *    toplevel status + taglen=0 + rescount + OP_PUTFH + status
-	 *       + OP_READ + status + eof + datalen = 9
-	 */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS4_dec_read_sz) << 2;
-	xdr_inline_pages(&req->rq_rcv_buf, replen,
+	xdr_inline_pages(&req->rq_rcv_buf, hdr.replen << 2,
 			 args->pages, args->pgbase, args->count);
 	req->rq_rcv_buf.flags |= XDRBUF_READ;
 	encode_nops(&hdr);
@@ -1827,20 +1806,18 @@ nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
 		struct nfs_getaclargs *args)
 {
 	struct xdr_stream xdr;
-	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
 	struct compound_hdr hdr = {
 		.nops   = 0,
 	};
-	int replen;
+	uint32_t replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
+	replen = hdr.replen + nfs4_fattr_bitmap_maxsz + 1;
 	encode_getattr_two(&xdr, FATTR4_WORD0_ACL, 0, &hdr);
 
-	/* set up reply buffer: */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + NFS4_dec_getacl_sz) << 2;
-	xdr_inline_pages(&req->rq_rcv_buf, replen,
+	xdr_inline_pages(&req->rq_rcv_buf, replen << 2,
 		args->acl_pages, args->acl_pgbase, args->acl_len);
 	encode_nops(&hdr);
 	return 0;
@@ -2045,21 +2022,16 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 	struct compound_hdr hdr = {
 		.nops = 0,
 	};
-	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
-	int replen;
+	uint32_t replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_lookup(&xdr, args->name, &hdr);
+	replen = hdr.replen;	/* get the attribute into args->page */
 	encode_fs_locations(&xdr, args->bitmask, &hdr);
 
-	/* set up reply
-	 *   toplevel_status + OP_PUTFH + status
-	 *   + OP_LOOKUP + status + OP_GETATTR + status = 7
-	 */
-	replen = (RPC_REPHDRSIZE + auth->au_rslack + 7) << 2;
-	xdr_inline_pages(&req->rq_rcv_buf, replen, &args->page,
+	xdr_inline_pages(&req->rq_rcv_buf, replen << 2, &args->page,
 			0, PAGE_SIZE);
 	encode_nops(&hdr);
 	return 0;
-- 
1.6.2.1

