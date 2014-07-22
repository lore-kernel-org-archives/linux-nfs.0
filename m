Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:56347 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756681AbaGVUAm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 16:00:42 -0400
Received: by mail-ie0-f175.google.com with SMTP id x19so139424ier.20
        for <linux-nfs@vger.kernel.org>; Tue, 22 Jul 2014 13:00:41 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] svcrdma: Add zero padding if the client doesn't send it
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 22 Jul 2014 16:00:40 -0400
Message-ID: <20140722200040.6011.86756.stgit@klimt.1015granger.net>
In-Reply-To: <20140722195840.6011.87861.stgit@klimt.1015granger.net>
References: <20140722195840.6011.87861.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

See RFC 5666 section 3.7: clients don't have to send zero XDR
padding.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=246
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 8f92a61..e011027 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -43,6 +43,7 @@
 #include <linux/sunrpc/debug.h>
 #include <linux/sunrpc/rpc_rdma.h>
 #include <linux/spinlock.h>
+#include <linux/highmem.h>
 #include <asm/unaligned.h>
 #include <rdma/ib_verbs.h>
 #include <rdma/rdma_cm.h>
@@ -435,6 +436,32 @@ static int rdma_read_chunks(struct svcxprt_rdma *xprt,
 	return ret;
 }
 
+/*
+ * To avoid a separate RDMA READ just for a handful of zero bytes,
+ * RFC 5666 section 3.7 allows the client to omit the XDR zero pad
+ * in chunk lists.
+ */
+static void
+rdma_fix_xdr_pad(struct xdr_buf *buf)
+{
+	unsigned int page_len = buf->page_len;
+	unsigned int size = (XDR_QUADLEN(page_len) << 2) - page_len;
+	unsigned int offset, pg_no;
+	char *p;
+
+	if (size == 0)
+		return;
+
+	pg_no = page_len >> PAGE_SHIFT;
+	offset = page_len & ~PAGE_MASK;
+	p = page_address(buf->pages[pg_no]);
+	memset(p + offset, 0, size);
+
+	buf->page_len += size;
+	buf->buflen += size;
+	buf->len += size;
+}
+
 static int rdma_read_complete(struct svc_rqst *rqstp,
 			      struct svc_rdma_op_ctxt *head)
 {
@@ -449,6 +476,7 @@ static int rdma_read_complete(struct svc_rqst *rqstp,
 		rqstp->rq_pages[page_no] = head->pages[page_no];
 	}
 	/* Point rq_arg.pages past header */
+	rdma_fix_xdr_pad(&head->arg);
 	rqstp->rq_arg.pages = &rqstp->rq_pages[head->hdr_count];
 	rqstp->rq_arg.page_len = head->arg.page_len;
 	rqstp->rq_arg.page_base = head->arg.page_base;

