Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:52108 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643AbaBCVCZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 16:02:25 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/8] SUNRPC: Display tk_pid where possible
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 03 Feb 2014 16:02:23 -0500
Message-ID: <20140203210223.3533.92167.stgit@manet.1015granger.net>
In-Reply-To: <20140203205903.3533.39213.stgit@manet.1015granger.net>
References: <20140203205903.3533.39213.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Until we get around to adding trace points to xprtrdma.ko, take the
easy road and try to polish up the existing debugging messages.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c  |   76 +++++++++++++++++++++++----------------
 net/sunrpc/xprtrdma/transport.c |   19 ++++++----
 2 files changed, 56 insertions(+), 39 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 96ead52..4ab505b 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -216,8 +216,9 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 			xdr_encode_hyper(
 					(__be32 *)&cur_rchunk->rc_target.rs_offset,
 					seg->mr_base);
-			dprintk("RPC:       %s: read chunk "
-				"elem %d@0x%llx:0x%x pos %u (%s)\n", __func__,
+			dprintk("RPC: %5u %s: read chunk "
+				"elem %d@0x%llx:0x%x pos %u (%s)\n",
+				rqst->rq_task->tk_pid, __func__,
 				seg->mr_len, (unsigned long long)seg->mr_base,
 				seg->mr_rkey, pos, n < nsegs ? "more" : "last");
 			cur_rchunk++;
@@ -228,8 +229,9 @@ rpcrdma_create_chunks(struct rpc_rqst *rqst, struct xdr_buf *target,
 			xdr_encode_hyper(
 					(__be32 *)&cur_wchunk->wc_target.rs_offset,
 					seg->mr_base);
-			dprintk("RPC:       %s: %s chunk "
-				"elem %d@0x%llx:0x%x (%s)\n", __func__,
+			dprintk("RPC: %5u %s: %s chunk "
+				"elem %d@0x%llx:0x%x (%s)\n",
+				rqst->rq_task->tk_pid, __func__,
 				(type == rpcrdma_replych) ? "reply" : "write",
 				seg->mr_len, (unsigned long long)seg->mr_base,
 				seg->mr_rkey, n < nsegs ? "more" : "last");
@@ -310,8 +312,9 @@ rpcrdma_inline_pullup(struct rpc_rqst *rqst, int pad)
 	if (pad < 0 || rqst->rq_slen - curlen < RPCRDMA_INLINE_PAD_THRESH)
 		pad = 0;	/* don't pad this request */
 
-	dprintk("RPC:       %s: pad %d destp 0x%p len %d hdrlen %d\n",
-		__func__, pad, destp, rqst->rq_slen, curlen);
+	dprintk("RPC: %5u %s: pad %d destp 0x%p len %d hdrlen %d\n",
+		rqst->rq_task->tk_pid, __func__,
+		pad, destp, rqst->rq_slen, curlen);
 
 	copy_len = rqst->rq_snd_buf.page_len;
 
@@ -322,8 +325,9 @@ rpcrdma_inline_pullup(struct rpc_rqst *rqst, int pad)
 				rqst->rq_snd_buf.tail[0].iov_base, curlen);
 			r_xprt->rx_stats.pullup_copy_count += curlen;
 		}
-		dprintk("RPC:       %s: tail destp 0x%p len %d\n",
-			__func__, destp + copy_len, curlen);
+		dprintk("RPC: %5u %s: tail destp 0x%p len %d\n",
+			rqst->rq_task->tk_pid, __func__,
+			destp + copy_len, curlen);
 		rqst->rq_svec[0].iov_len += curlen;
 	}
 	r_xprt->rx_stats.pullup_copy_count += copy_len;
@@ -336,8 +340,9 @@ rpcrdma_inline_pullup(struct rpc_rqst *rqst, int pad)
 		curlen = PAGE_SIZE - page_base;
 		if (curlen > copy_len)
 			curlen = copy_len;
-		dprintk("RPC:       %s: page %d destp 0x%p len %d curlen %d\n",
-			__func__, i, destp, copy_len, curlen);
+		dprintk("RPC: %5u %s: page %d destp 0x%p len %d curlen %d\n",
+			rqst->rq_task->tk_pid, __func__,
+			i, destp, copy_len, curlen);
 		srcp = kmap_atomic(ppages[i]);
 		memcpy(destp, srcp+page_base, curlen);
 		kunmap_atomic(srcp);
@@ -446,8 +451,9 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	if (r_xprt->rx_ia.ri_memreg_strategy == RPCRDMA_BOUNCEBUFFERS &&
 	    (rtype != rpcrdma_noch || wtype != rpcrdma_noch)) {
 		/* forced to "pure inline"? */
-		dprintk("RPC:       %s: too much data (%d/%d) for inline\n",
-			__func__, rqst->rq_rcv_buf.len, rqst->rq_snd_buf.len);
+		dprintk("RPC: %5u %s: too much data (%d/%d) for inline\n",
+			rqst->rq_task->tk_pid, __func__,
+			rqst->rq_rcv_buf.len, rqst->rq_snd_buf.len);
 		return -1;
 	}
 
@@ -515,9 +521,10 @@ rpcrdma_marshal_req(struct rpc_rqst *rqst)
 	if (hdrlen == 0)
 		return -1;
 
-	dprintk("RPC:       %s: %s: hdrlen %zd rpclen %zd padlen %zd"
+	dprintk("RPC: %5u %s: %s: hdrlen %zd rpclen %zd padlen %zd"
 		" headerp 0x%p base 0x%p lkey 0x%x\n",
-		__func__, transfertypes[wtype], hdrlen, rpclen, padlen,
+		rqst->rq_task->tk_pid, __func__,
+		transfertypes[wtype], hdrlen, rpclen, padlen,
 		headerp, base, req->rl_iov.lkey);
 
 	/*
@@ -614,8 +621,9 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 		rqst->rq_rcv_buf.head[0].iov_len = curlen;
 	}
 
-	dprintk("RPC:       %s: srcp 0x%p len %d hdrlen %d\n",
-		__func__, srcp, copy_len, curlen);
+	dprintk("RPC: %5u %s: srcp 0x%p len %d hdrlen %d\n",
+		rqst->rq_task->tk_pid, __func__,
+		srcp, copy_len, curlen);
 
 	/* Shift pointer for first receive segment only */
 	rqst->rq_rcv_buf.head[0].iov_base = srcp;
@@ -636,9 +644,10 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 			curlen = PAGE_SIZE - page_base;
 			if (curlen > copy_len)
 				curlen = copy_len;
-			dprintk("RPC:       %s: page %d"
+			dprintk("RPC: %5u %s: page %d"
 				" srcp 0x%p len %d curlen %d\n",
-				__func__, i, srcp, copy_len, curlen);
+				rqst->rq_task->tk_pid, __func__,
+				i, srcp, copy_len, curlen);
 			destp = kmap_atomic(ppages[i]);
 			memcpy(destp + page_base, srcp, curlen);
 			flush_dcache_page(ppages[i]);
@@ -657,8 +666,9 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 			curlen = rqst->rq_rcv_buf.tail[0].iov_len;
 		if (rqst->rq_rcv_buf.tail[0].iov_base != srcp)
 			memmove(rqst->rq_rcv_buf.tail[0].iov_base, srcp, curlen);
-		dprintk("RPC:       %s: tail srcp 0x%p len %d curlen %d\n",
-			__func__, srcp, copy_len, curlen);
+		dprintk("RPC: %5u %s: tail srcp 0x%p len %d curlen %d\n",
+			rqst->rq_task->tk_pid, __func__,
+			srcp, copy_len, curlen);
 		rqst->rq_rcv_buf.tail[0].iov_len = curlen;
 		copy_len -= curlen; ++i;
 	} else
@@ -672,9 +682,10 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 	}
 
 	if (copy_len)
-		dprintk("RPC:       %s: %d bytes in"
+		dprintk("RPC: %5u %s: %d bytes in"
 			" %d extra segments (%d lost)\n",
-			__func__, olen, i, copy_len);
+			rqst->rq_task->tk_pid, __func__,
+			olen, i, copy_len);
 
 	/* TBD avoid a warning from call_decode() */
 	rqst->rq_private_buf = rqst->rq_rcv_buf;
@@ -771,15 +782,17 @@ repost:
 	req = rpcr_to_rdmar(rqst);
 	if (req->rl_reply) {
 		spin_unlock(&xprt->transport_lock);
-		dprintk("RPC:       %s: duplicate reply 0x%p to RPC "
-			"request 0x%p: xid 0x%08x\n", __func__, rep, req,
-			headerp->rm_xid);
+		dprintk("RPC: %5u %s: duplicate reply 0x%p to RPC "
+			"request 0x%p: xid 0x%08x\n",
+			rqst->rq_task->tk_pid, __func__,
+			rep, req, headerp->rm_xid);
 		goto repost;
 	}
 
-	dprintk("RPC:       %s: reply 0x%p completes request 0x%p\n"
+	dprintk("RPC: %5u %s: reply 0x%p completes request 0x%p\n"
 		"                   RPC request 0x%p xid 0x%08x\n",
-			__func__, rep, req, rqst, headerp->rm_xid);
+		rqst->rq_task->tk_pid, __func__,
+		rep, req, rqst, headerp->rm_xid);
 
 	/* from here on, the reply is no longer an orphan */
 	req->rl_reply = rep;
@@ -844,10 +857,11 @@ repost:
 
 badheader:
 	default:
-		dprintk("%s: invalid rpcrdma reply header (type %d):"
+		dprintk("RPC: %5u %s: invalid rpcrdma reply header (type %d):"
 				" chunks[012] == %d %d %d"
 				" expected chunks <= %d\n",
-				__func__, ntohl(headerp->rm_type),
+				rqst->rq_task->tk_pid, __func__,
+				ntohl(headerp->rm_type),
 				headerp->rm_body.rm_chunks[0],
 				headerp->rm_body.rm_chunks[1],
 				headerp->rm_body.rm_chunks[2],
@@ -878,8 +892,8 @@ badheader:
 		break;
 	}
 
-	dprintk("RPC:       %s: xprt_complete_rqst(0x%p, 0x%p, %d)\n",
-			__func__, xprt, rqst, status);
+	dprintk("RPC: %5u %s: xprt_complete_rqst(0x%p, 0x%p, %d)\n",
+		rqst->rq_task->tk_pid, __func__, xprt, rqst, status);
 	xprt_complete_rqst(rqst->rq_task, status);
 	spin_unlock(&xprt->transport_lock);
 }
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 1eb9c46..5f31775 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -456,7 +456,8 @@ xprt_rdma_reserve_xprt(struct rpc_xprt *xprt, struct rpc_task *task)
 	/* == RPC_CWNDSCALE @ init, but *after* setup */
 	if (r_xprt->rx_buf.rb_cwndscale == 0UL) {
 		r_xprt->rx_buf.rb_cwndscale = xprt->cwnd;
-		dprintk("RPC:       %s: cwndscale %lu\n", __func__,
+		dprintk("RPC: %5u %s: cwndscale %lu\n",
+			task->tk_pid, __func__,
 			r_xprt->rx_buf.rb_cwndscale);
 		BUG_ON(r_xprt->rx_buf.rb_cwndscale <= 0);
 	}
@@ -482,9 +483,9 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size)
 	BUG_ON(NULL == req);
 
 	if (size > req->rl_size) {
-		dprintk("RPC:       %s: size %zd too large for buffer[%zd]: "
+		dprintk("RPC: %5u %s: size %zd too large for buffer[%zd]: "
 			"prog %d vers %d proc %d\n",
-			__func__, size, req->rl_size,
+			task->tk_pid, __func__, size, req->rl_size,
 			task->tk_client->cl_prog, task->tk_client->cl_vers,
 			task->tk_msg.rpc_proc->p_proc);
 		/*
@@ -506,8 +507,9 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size)
 		if (rpcx_to_rdmax(xprt)->rx_ia.ri_memreg_strategy ==
 				RPCRDMA_BOUNCEBUFFERS) {
 			/* forced to "pure inline" */
-			dprintk("RPC:       %s: too much data (%zd) for inline "
-					"(r/w max %d/%d)\n", __func__, size,
+			dprintk("RPC: %5u %s: too much data (%zd) for inline "
+					"(r/w max %d/%d)\n",
+					task->tk_pid, __func__, size,
 					rpcx_to_rdmad(xprt).inline_rsize,
 					rpcx_to_rdmad(xprt).inline_wsize);
 			size = req->rl_size;
@@ -542,7 +544,8 @@ xprt_rdma_allocate(struct rpc_task *task, size_t size)
 		req->rl_reply = NULL;
 		req = nreq;
 	}
-	dprintk("RPC:       %s: size %zd, request 0x%p\n", __func__, size, req);
+	dprintk("RPC: %5u %s: size %zd, request 0x%p\n",
+		task->tk_pid, __func__, size, req);
 out:
 	req->rl_connect_cookie = 0;	/* our reserved value */
 	return req->rl_xdr_buf;
@@ -634,8 +637,8 @@ xprt_rdma_send_request(struct rpc_task *task)
 	/* marshal the send itself */
 	if (req->rl_niovs == 0 && rpcrdma_marshal_req(rqst) != 0) {
 		r_xprt->rx_stats.failed_marshal_count++;
-		dprintk("RPC:       %s: rpcrdma_marshal_req failed\n",
-			__func__);
+		dprintk("RPC: %5u %s: rpcrdma_marshal_req failed\n",
+			task->tk_pid, __func__);
 		return -EIO;
 	}
 

