Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:34946 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbbGMQbj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 12:31:39 -0400
Subject: [PATCH v2 12/14] xprtrdma: Fix large NFS SYMLINK calls
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 13 Jul 2015 12:31:36 -0400
Message-ID: <20150713163136.17630.5572.stgit@manet.1015granger.net>
In-Reply-To: <20150713160617.17630.97475.stgit@manet.1015granger.net>
References: <20150713160617.17630.97475.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Repair how rpcrdma_marshal_req() chooses which RDMA message type
to use for large non-WRITE operations so that it picks RDMA_NOMSG
in the correct situations, and sets up the marshaling logic to
SEND only the RPC/RDMA header.

Large NFSv2 SYMLINK requests now use RDMA_NOMSG calls. The Linux NFS
server XDR decoder for NFSv2 SYMLINK does not handle having the
pathname argument arrive in a separate buffer. The decoder could be
fixed, but this is simpler and RDMA_NOMSG can be used in a variety
of other situations.

Ensure that the Linux client continues to use "RDMA_MSG + read
list" when sending large NFSv3 SYMLINK requests, which is more
efficient than using RDMA_NOMSG.

Large NFSv4 CREATE(NF4LNK) requests are changed to use "RDMA_MSG +
read list" just like NFSv3 (see Section 5 of RFC 5667). Before,
these did not work at all.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs3xdr.c               |    1 +
 fs/nfs/nfs4xdr.c               |    4 +++-
 net/sunrpc/xprtrdma/rpc_rdma.c |   25 ++++++++++++++++---------
 3 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 9b04c2e..267126d 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1103,6 +1103,7 @@ static void nfs3_xdr_enc_symlink3args(struct rpc_rqst *req,
 {
 	encode_diropargs3(xdr, args->fromfh, args->fromname, args->fromlen);
 	encode_symlinkdata3(xdr, args);
+	xdr->buf->flags |= XDRBUF_WRITE;
 }
 
 /*
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 558cd65d..c42459e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1154,7 +1154,9 @@ static void encode_create(struct xdr_stream *xdr, const struct nfs4_create_arg *
 	case NF4LNK:
 		p = reserve_space(xdr, 4);
 		*p = cpu_to_be32(create->u.symlink.len);
-		xdr_write_pages(xdr, create->u.symlink.pages, 0, create->u.symlink.len);
+		xdr_write_pages(xdr, create->u.symlink.pages, 0,
+				create->u.symlink.len);
+		xdr->buf->flags |= XDRBUF_WRITE;
 		break;
 
 	case NF4BLK: case NF4CHR:
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 1dd48f2..2721586 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -475,21 +475,24 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	 *
 	 * o If the total request is under the inline threshold, all ops
 	 *   are sent as inline.
-	 * o Large non-write ops are sent with the entire message as a
-	 *   single read chunk (protocol 0-position special case).
 	 * o Large write ops transmit data as read chunk(s), header as
 	 *   inline.
+	 * o Large non-write ops are sent with the entire message as a
+	 *   single read chunk (protocol 0-position special case).
 	 *
-	 * Note: the NFS code sending down multiple argument segments
-	 * implies the op is a write.
-	 * TBD check NFSv4 setacl
+	 * This assumes that the upper layer does not present a request
+	 * that both has a data payload, and whose non-data arguments
+	 * by themselves are larger than the inline threshold.
 	 */
-	if (rpcrdma_args_inline(rqst))
+	if (rpcrdma_args_inline(rqst)) {
 		rtype = rpcrdma_noch;
-	else if (rqst->rq_snd_buf.page_len == 0)
-		rtype = rpcrdma_areadch;
-	else
+	} else if (rqst->rq_snd_buf.flags & XDRBUF_WRITE) {
 		rtype = rpcrdma_readch;
+	} else {
+		headerp->rm_type = htonl(RDMA_NOMSG);
+		rtype = rpcrdma_areadch;
+		rpclen = 0;
+	}
 
 	/* The following simplification is not true forever */
 	if (rtype != rpcrdma_noch && wtype == rpcrdma_replych)
@@ -546,6 +549,10 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	req->rl_send_iov[0].length = hdrlen;
 	req->rl_send_iov[0].lkey = rdmab_lkey(req->rl_rdmabuf);
 
+	req->rl_niovs = 1;
+	if (rtype == rpcrdma_areadch)
+		return 0;
+
 	req->rl_send_iov[1].addr = rdmab_addr(req->rl_sendbuf);
 	req->rl_send_iov[1].length = rpclen;
 	req->rl_send_iov[1].lkey = rdmab_lkey(req->rl_sendbuf);

