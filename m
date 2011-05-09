Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:39658 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073Ab1EITWi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 15:22:38 -0400
Received: by ywj3 with SMTP id 3so1912717ywj.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 12:22:37 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/6] SUNRPC: Rename xs_encode_tcp_fragment_header()
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 May 2011 15:22:34 -0400
Message-ID: <20110509192234.16449.45025.stgit@matisse.1015granger.net>
In-Reply-To: <20110509191859.16449.73749.stgit@matisse.1015granger.net>
References: <20110509191859.16449.73749.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up: Use a more generic name for xs_encode_tcp_fragment_header();
it's appropriate to use for all stream transport types.  We're about
to add new stream transport.

Also, move it to a place where it is more easily shared amongst the
various send_request methods.  And finally, replace the "htonl" macro
invocation with its modern equivalent.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index bf005d3..6d54d39 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -495,6 +495,16 @@ static int xs_nospace(struct rpc_task *task)
 	return ret;
 }
 
+/*
+ * Construct a stream transport record marker in @buf.
+ */
+static inline void xs_encode_stream_record_marker(struct xdr_buf *buf)
+{
+	u32 reclen = buf->len - sizeof(rpc_fraghdr);
+	rpc_fraghdr *base = buf->head[0].iov_base;
+	*base = cpu_to_be32(RPC_LAST_STREAM_FRAGMENT | reclen);
+}
+
 /**
  * xs_udp_send_request - write an RPC request to a UDP socket
  * @task: address of RPC task that manages the state of an RPC request
@@ -574,13 +584,6 @@ static void xs_tcp_shutdown(struct rpc_xprt *xprt)
 		kernel_sock_shutdown(sock, SHUT_WR);
 }
 
-static inline void xs_encode_tcp_record_marker(struct xdr_buf *buf)
-{
-	u32 reclen = buf->len - sizeof(rpc_fraghdr);
-	rpc_fraghdr *base = buf->head[0].iov_base;
-	*base = htonl(RPC_LAST_STREAM_FRAGMENT | reclen);
-}
-
 /**
  * xs_tcp_send_request - write an RPC request to a TCP socket
  * @task: address of RPC task that manages the state of an RPC request
@@ -603,7 +606,7 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	struct xdr_buf *xdr = &req->rq_snd_buf;
 	int status;
 
-	xs_encode_tcp_record_marker(&req->rq_snd_buf);
+	xs_encode_stream_record_marker(&req->rq_snd_buf);
 
 	xs_pktdump("packet data:",
 				req->rq_svec->iov_base,
@@ -2014,10 +2017,7 @@ static int bc_sendto(struct rpc_rqst *req)
 	unsigned long headoff;
 	unsigned long tailoff;
 
-	/*
-	 * Set up the rpc header and record marker stuff
-	 */
-	xs_encode_tcp_record_marker(xbufp);
+	xs_encode_stream_record_marker(xbufp);
 
 	tailoff = (unsigned long)xbufp->tail[0].iov_base & ~PAGE_MASK;
 	headoff = (unsigned long)xbufp->head[0].iov_base & ~PAGE_MASK;

