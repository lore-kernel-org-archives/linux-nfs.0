Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:56842 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416Ab1CVWJU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2011 18:09:20 -0400
Received: by mail-iw0-f174.google.com with SMTP id 34so7906460iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 22 Mar 2011 15:09:20 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] SUNRPC: Rename xs_encode_tcp_fragment_header()
To: linux-nfs@vger.kernel.org
Date: Tue, 22 Mar 2011 18:09:18 -0400
Message-ID: <20110322220918.4360.37689.stgit@matisse.1015granger.net>
In-Reply-To: <20110322220518.4360.51304.stgit@matisse.1015granger.net>
References: <20110322220518.4360.51304.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up: Use a more generic name for xs_encode_tcp_fragment_header();
it's appropriate to use for all stream transport types (and we're
about to add another).

Also, move it to a place where it is more easily shared amongst the
various send_request methods.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtsock.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index be96d42..caf397a 100644
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
@@ -2012,10 +2015,7 @@ static int bc_sendto(struct rpc_rqst *req)
 	unsigned long headoff;
 	unsigned long tailoff;
 
-	/*
-	 * Set up the rpc header and record marker stuff
-	 */
-	xs_encode_tcp_record_marker(xbufp);
+	xs_encode_stream_record_marker(xbufp);
 
 	tailoff = (unsigned long)xbufp->tail[0].iov_base & ~PAGE_MASK;
 	headoff = (unsigned long)xbufp->head[0].iov_base & ~PAGE_MASK;

