Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:35203 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465AbbAITWz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jan 2015 14:22:55 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 07/10] svcrdma: rc_position sanity checking
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 09 Jan 2015 14:22:53 -0500
Message-ID: <20150109192253.4901.19640.stgit@klimt.1015granger.net>
In-Reply-To: <20150109191910.4901.29548.stgit@klimt.1015granger.net>
References: <20150109191910.4901.29548.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An RPC/RDMA client may send large data payloads via a read chunk
list. This is a list of scatter/gather elements which are RPC call
arguments too large to fit in a small RDMA SEND.

Each read chunk list entry has a "position" which is the offset in
the RPC header where the chunk list payload should be inserted. Thus
content can exist in the RPC header both before _and_ after a chunk
list (see RFC 5666).

Currently the Linux NFS/RDMA server cannot handle receiving read
chunks in more than one position. Fortunately no client currently
sends more than one read list per RPC.

Ensure that all received chunks have the same "rc_position."

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index c3aebc1..a67dd1a 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -365,6 +365,7 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 	int page_no, ret;
 	struct rpcrdma_read_chunk *ch;
 	u32 handle, page_offset, byte_count;
+	u32 position;
 	u64 rs_offset;
 	bool last;
 
@@ -389,10 +390,17 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 	head->arg.len = rqstp->rq_arg.len;
 	head->arg.buflen = rqstp->rq_arg.buflen;
 
-	page_no = 0; page_offset = 0;
-	for (ch = (struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
-	     ch->rc_discrim != 0; ch++) {
-		handle = be32_to_cpu(ch->rc_target.rs_handle);
+	ch = (struct rpcrdma_read_chunk *)&rmsgp->rm_body.rm_chunks[0];
+	position = be32_to_cpu(ch->rc_position);
+
+	ret = 0;
+	page_no = 0;
+	page_offset = 0;
+	for (; ch->rc_discrim != xdr_zero; ch++) {
+		if (be32_to_cpu(ch->rc_position) != position)
+			goto err;
+
+		handle = be32_to_cpu(ch->rc_target.rs_handle),
 		byte_count = be32_to_cpu(ch->rc_target.rs_length);
 		xdr_decode_hyper((__be32 *)&ch->rc_target.rs_offset,
 				 &rs_offset);

