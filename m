Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:35925 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbbEDQSo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2015 12:18:44 -0400
Received: by qku63 with SMTP id 63so87953242qku.3
        for <linux-nfs@vger.kernel.org>; Mon, 04 May 2015 09:18:44 -0700 (PDT)
Received: from klimt.1015granger.net ([2604:8800:100:81fc:be5f:f4ff:fed6:c3ba])
        by mx.google.com with ESMTPSA id r17sm10050725qkh.12.2015.05.04.09.18.42
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 09:18:43 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 1/8] svcrdma: Fix byte-swapping in svc_rdma_sendto.c
To: linux-nfs@vger.kernel.org
Date: Mon, 04 May 2015 12:18:41 -0400
Message-ID: <20150504161841.16870.25415.stgit@klimt.1015granger.net>
In-Reply-To: <20150504160738.16870.19295.stgit@klimt.1015granger.net>
References: <20150504160738.16870.19295.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In send_write_chunks(), we have:

	for (xdr_off = rqstp->rq_res.head[0].iov_len, chunk_no = 0;
	     xfer_len && chunk_no < arg_ary->wc_nchunks;
	     chunk_no++) {
		 . . .
	}

Note that arg_ary->wc_nchunk is in network byte-order. For the
comparison to work correctly, both have to be in native byte-order.

In send_reply_chunks, we have:

	write_len = min(xfer_len, htonl(ch->rs_length));

xfer_len is in native byte-order, and ch->rs_length is in
network byte-order. be32_to_cpu() is the correct byte swap
for ch->rs_length.

As an additional clean up, replace ntohl() with be32_to_cpu() in
a few other places.

This appears to address a problem with large rsize hangs while
using PHYSICAL memory registration. I suspect that is the only
registration mode that uses more than one chunk element.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=248
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/svc_rdma_sendto.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 7de33d1..109e967 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -240,6 +240,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 	u32 xdr_off;
 	int chunk_off;
 	int chunk_no;
+	int nchunks;
 	struct rpcrdma_write_array *arg_ary;
 	struct rpcrdma_write_array *res_ary;
 	int ret;
@@ -251,14 +252,15 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 		&rdma_resp->rm_body.rm_chunks[1];
 
 	/* Write chunks start at the pagelist */
+	nchunks = be32_to_cpu(arg_ary->wc_nchunks);
 	for (xdr_off = rqstp->rq_res.head[0].iov_len, chunk_no = 0;
-	     xfer_len && chunk_no < arg_ary->wc_nchunks;
+	     xfer_len && chunk_no < nchunks;
 	     chunk_no++) {
 		struct rpcrdma_segment *arg_ch;
 		u64 rs_offset;
 
 		arg_ch = &arg_ary->wc_array[chunk_no].wc_target;
-		write_len = min(xfer_len, ntohl(arg_ch->rs_length));
+		write_len = min(xfer_len, be32_to_cpu(arg_ch->rs_length));
 
 		/* Prepare the response chunk given the length actually
 		 * written */
@@ -270,7 +272,7 @@ static int send_write_chunks(struct svcxprt_rdma *xprt,
 		chunk_off = 0;
 		while (write_len) {
 			ret = send_write(xprt, rqstp,
-					 ntohl(arg_ch->rs_handle),
+					 be32_to_cpu(arg_ch->rs_handle),
 					 rs_offset + chunk_off,
 					 xdr_off,
 					 write_len,
@@ -318,13 +320,13 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
 		&rdma_resp->rm_body.rm_chunks[2];
 
 	/* xdr offset starts at RPC message */
-	nchunks = ntohl(arg_ary->wc_nchunks);
+	nchunks = be32_to_cpu(arg_ary->wc_nchunks);
 	for (xdr_off = 0, chunk_no = 0;
 	     xfer_len && chunk_no < nchunks;
 	     chunk_no++) {
 		u64 rs_offset;
 		ch = &arg_ary->wc_array[chunk_no].wc_target;
-		write_len = min(xfer_len, htonl(ch->rs_length));
+		write_len = min(xfer_len, be32_to_cpu(ch->rs_length));
 
 		/* Prepare the reply chunk given the length actually
 		 * written */
@@ -335,7 +337,7 @@ static int send_reply_chunks(struct svcxprt_rdma *xprt,
 		chunk_off = 0;
 		while (write_len) {
 			ret = send_write(xprt, rqstp,
-					 ntohl(ch->rs_handle),
+					 be32_to_cpu(ch->rs_handle),
 					 rs_offset + chunk_off,
 					 xdr_off,
 					 write_len,

