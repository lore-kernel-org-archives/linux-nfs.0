Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f180.google.com ([209.85.213.180]:39317 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752465AbbAITXN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jan 2015 14:23:13 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 09/10] Move read list XDR round-up logic
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 09 Jan 2015 14:23:11 -0500
Message-ID: <20150109192310.4901.62851.stgit@klimt.1015granger.net>
In-Reply-To: <20150109191910.4901.29548.stgit@klimt.1015granger.net>
References: <20150109191910.4901.29548.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simpler approach, and this needs to be done before the tail is
copied to the end of the read list (pre-requisite for a subsequent
patch).

Fixes: e560e3b510d2 ("svcrdma: Add zero padding if the client... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   37 ++++++++-----------------------
 1 files changed, 9 insertions(+), 28 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 36cf51a..a345cad 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -43,7 +43,6 @@
 #include <linux/sunrpc/debug.h>
 #include <linux/sunrpc/rpc_rdma.h>
 #include <linux/spinlock.h>
-#include <linux/highmem.h>
 #include <asm/unaligned.h>
 #include <rdma/ib_verbs.h>
 #include <rdma/rdma_cm.h>
@@ -434,6 +433,15 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 		}
 	}
 
+	/* Read list may need XDR round-up (see RFC 5666, s. 3.7) */
+	if (page_offset & 3) {
+		u32 pad = 4 - (page_offset & 3);
+
+		head->arg.page_len += pad;
+		head->arg.len += pad;
+		head->arg.buflen += pad;
+	}
+
 	ret = 1;
 	head->position = position;
 
@@ -446,32 +454,6 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 	return ret;
 }
 
-/*
- * To avoid a separate RDMA READ just for a handful of zero bytes,
- * RFC 5666 section 3.7 allows the client to omit the XDR zero pad
- * in chunk lists.
- */
-static void
-rdma_fix_xdr_pad(struct xdr_buf *buf)
-{
-	unsigned int page_len = buf->page_len;
-	unsigned int size = (XDR_QUADLEN(page_len) << 2) - page_len;
-	unsigned int offset, pg_no;
-	char *p;
-
-	if (size == 0)
-		return;
-
-	pg_no = page_len >> PAGE_SHIFT;
-	offset = page_len & ~PAGE_MASK;
-	p = page_address(buf->pages[pg_no]);
-	memset(p + offset, 0, size);
-
-	buf->page_len += size;
-	buf->buflen += size;
-	buf->len += size;
-}
-
 static int rdma_read_complete(struct svc_rqst *rqstp,
 			      struct svc_rdma_op_ctxt *head)
 {
@@ -499,7 +481,6 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
 	}
 
 	/* Point rq_arg.pages past header */
-	rdma_fix_xdr_pad(&head->arg);
 	rqstp->rq_arg.pages = &rqstp->rq_pages[head->hdr_count];
 	rqstp->rq_arg.page_len = head->arg.page_len;
 	rqstp->rq_arg.page_base = head->arg.page_base;

