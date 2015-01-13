Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:64399 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbbAMQDr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Jan 2015 11:03:47 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 09/10] svcrdma: Move read list XDR round-up logic
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Tue, 13 Jan 2015 11:03:45 -0500
Message-ID: <20150113160345.8118.69576.stgit@klimt.1015granger.net>
In-Reply-To: <20150113155904.8118.57718.stgit@klimt.1015granger.net>
References: <20150113155904.8118.57718.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a pre-requisite for a subsequent patch.

Read list XDR round-up needs to be done _before_ additional inline
content is copied to the end of the XDR buffer's page list. Move
the logic added by commit e560e3b510d2 ("svcrdma: Add zero padding
if the client doesn't send it").

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

