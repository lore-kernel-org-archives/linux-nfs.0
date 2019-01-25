Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F897C282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 21:55:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3865B218D0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 21:55:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ru/tfJ8U"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726218AbfAYVzR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 16:55:17 -0500
Received: from mail-pf1-f195.google.com ([209.85.210.195]:43772 "EHLO
        mail-pf1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726179AbfAYVzR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2019 16:55:17 -0500
Received: by mail-pf1-f195.google.com with SMTP id w73so5322708pfk.10;
        Fri, 25 Jan 2019 13:55:16 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=a1pTc0eeqlf6ExDUb915bNynYKFnKKKFUuLyZrhfrtQ=;
        b=Ru/tfJ8Ur4itYdztRSSEETZC58zPS66eqPncG0wmAhqaOrLijkJAbIxhwUrJyPF11Q
         q2dMCrSp+ucPLJK/Jb4NbfqqWwGYw0GJwj0BE8U9r9CHmF4wByV4UWge8j9W2PVs5s7N
         aTp46kgEOiZpn0cvsFYprEU0qLObA7jMDfpwjEyc/hpOWCBWc1nwtrekvcOmtAW48Sig
         TvfJxMtk6PVJz1qDA6ETllOR2aBnnsH5Xb1NF+d21nI7sfqZjV1bS07QCtMZvmBe/YKN
         raTc1qsL+DDReQhCiqY+J5PxPBPGLc7nFtBWof/4UWcbghoLJWRyiaAQ53geNn7YZs1n
         uxaw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=a1pTc0eeqlf6ExDUb915bNynYKFnKKKFUuLyZrhfrtQ=;
        b=C+ps34R5JABR9m5GoyTnnficE6YnlBxhx5f+emWvgNIGiJ4STuhss1o6mZwIlgw31E
         LvBAS33v4NYzdFqDZhbFrfAS/8DT4Qmti4gvlT9CUGN+oDRKjZ7AZsn/bHPvj6YqXJHX
         GraMYmhPvwzJfM1Zk2PTgMB65uqFweIBGKaOO7pSlRmzo2gRrSuWfue8kyN2+Ds15J3l
         /5jEvfcEjzYS+KLFFAqZh3a1fRKxEGq4mBtBNL7m/hFz+lDLgObS0/gXuoZe1/c4vzzv
         Lt3iurkgEGZWXX2l13rssJxLxuq5uaVoWOJb/Q0bqlFx3Dg3xvHOfncXWBUBmm0gFkxJ
         XbeA==
X-Gm-Message-State: AJcUukebpHRSM4dxpeQ6s1PgjZBMqT5GQhdJK4DFXFneo4HkQvtb6FZa
        0LnQq8AMiwbHqY5RoWwsiG49bLxD
X-Google-Smtp-Source: ALg8bN55w3IIYRqpDw5PuWnA+QIxGi4XF/6l4zHz5gpWSbDIqj0zNwQ4CRoP11ttmlTs4YXG/JDsuA==
X-Received: by 2002:a62:f51a:: with SMTP id n26mr2681469pfh.245.1548453315833;
        Fri, 25 Jan 2019 13:55:15 -0800 (PST)
Received: from seurat.1015granger.net ([148.87.23.44])
        by smtp.gmail.com with ESMTPSA id z8sm39030795pgg.62.2019.01.25.13.55.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 13:55:15 -0800 (PST)
Subject: [PATCH v1] svcrdma: Remove max_sge check at connect time
From:   Chuck Lever <chuck.lever@oracle.com>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date:   Fri, 25 Jan 2019 16:54:54 -0500
Message-ID: <154845326910.67269.13122816140536911275.stgit@seurat.1015granger.net>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Two and a half years ago, the client was changed to use gathered
Send for larger inline messages, in commit 655fec6987b ("xprtrdma:
Use gathered Send for large inline messages"). Several fixes were
required because there are a few in-kernel device drivers whose
max_sge is 3, and these were broken by the change.

Apparently my memory is going, because some time later, I submitted
commit 25fd86eca11c ("svcrdma: Don't overrun the SGE array in
svc_rdma_send_ctxt"), and after that, commit f3c1fd0ee294 ("svcrdma:
Reduce max_send_sges"). These too incorrectly assumed in-kernel
device drivers would have more than a few Send SGEs available.

The fix for the server side is not the same. This is because the
fundamental problem on the server is that, whether or not the client
has provisioned a chunk for the RPC reply, the server must squeeze
even the most complex RPC replies into a single RDMA Send. Failing
in the send path because of Send SGE exhaustion should never be an
option.

Therefore, instead of failing when the send path runs out of SGEs,
switch to using a bounce buffer mechanism to handle RPC replies that
are too complex for the device to send directly. That allows us to
remove the max_sge check to enable drivers with small max_sge to
work again.

Reported-by: Don Dutile <ddutile@redhat.com>
Fixes: 25fd86eca11c ("svcrdma: Don't overrun the SGE array in ...")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |  105 ++++++++++++++++++++++++++++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    9 +--
 2 files changed, 102 insertions(+), 12 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_sendto.c b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
index 1aab305fbbb6..8235ca2159d1 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_sendto.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_sendto.c
@@ -531,6 +531,99 @@ void svc_rdma_sync_reply_hdr(struct svcxprt_rdma *rdma,
 				      DMA_TO_DEVICE);
 }
 
+/* If the xdr_buf has more elements than the device can
+ * transmit in a single RDMA Send, then the reply will
+ * have to be copied into a bounce buffer.
+ */
+static bool svc_rdma_pull_up_needed(struct svcxprt_rdma *rdma,
+				    struct xdr_buf *xdr,
+				    __be32 *wr_lst)
+{
+	int elements;
+
+	/* xdr->head */
+	elements = 1;
+
+	/* xdr->pages */
+	if (!wr_lst) {
+		unsigned int remaining;
+		unsigned long pageoff;
+
+		pageoff = xdr->page_base & ~PAGE_MASK;
+		remaining = xdr->page_len;
+		while (remaining) {
+			++elements;
+			remaining -= min_t(u32, PAGE_SIZE - pageoff,
+					   remaining);
+			pageoff = 0;
+		}
+	}
+
+	/* xdr->tail */
+	if (xdr->tail[0].iov_len)
+		++elements;
+
+	/* assume 1 SGE is needed for the transport header */
+	return elements >= rdma->sc_max_send_sges;
+}
+
+/* The device is not capable of sending the reply directly.
+ * Assemble the elements of @xdr into the transport header
+ * buffer.
+ */
+static int svc_rdma_pull_up_reply_msg(struct svcxprt_rdma *rdma,
+				      struct svc_rdma_send_ctxt *ctxt,
+				      struct xdr_buf *xdr, __be32 *wr_lst)
+{
+	unsigned char *dst, *tailbase;
+	unsigned int taillen;
+
+	dst = ctxt->sc_xprt_buf;
+	dst += ctxt->sc_sges[0].length;
+
+	memcpy(dst, xdr->head[0].iov_base, xdr->head[0].iov_len);
+	dst += xdr->head[0].iov_len;
+
+	tailbase = xdr->tail[0].iov_base;
+	taillen = xdr->tail[0].iov_len;
+	if (wr_lst) {
+		u32 xdrpad;
+
+		xdrpad = xdr_padsize(xdr->page_len);
+		if (taillen && xdrpad) {
+			tailbase += xdrpad;
+			taillen -= xdrpad;
+		}
+	} else {
+		unsigned int len, remaining;
+		unsigned long pageoff;
+		struct page **ppages;
+
+		ppages = xdr->pages + (xdr->page_base >> PAGE_SHIFT);
+		pageoff = xdr->page_base & ~PAGE_MASK;
+		remaining = xdr->page_len;
+		while (remaining) {
+			len = min_t(u32, PAGE_SIZE - pageoff, remaining);
+
+			memcpy(dst, page_address(*ppages), len);
+			remaining -= len;
+			dst += len;
+			pageoff = 0;
+		}
+	}
+
+	if (taillen)
+		memcpy(dst, tailbase, taillen);
+
+	ctxt->sc_sges[0].length += xdr->len;
+	ib_dma_sync_single_for_device(rdma->sc_pd->device,
+				      ctxt->sc_sges[0].addr,
+				      ctxt->sc_sges[0].length,
+				      DMA_TO_DEVICE);
+
+	return 0;
+}
+
 /* svc_rdma_map_reply_msg - Map the buffer holding RPC message
  * @rdma: controlling transport
  * @ctxt: send_ctxt for the Send WR
@@ -553,8 +646,10 @@ int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma,
 	u32 xdr_pad;
 	int ret;
 
-	if (++ctxt->sc_cur_sge_no >= rdma->sc_max_send_sges)
-		return -EIO;
+	if (svc_rdma_pull_up_needed(rdma, xdr, wr_lst))
+		return svc_rdma_pull_up_reply_msg(rdma, ctxt, xdr, wr_lst);
+
+	++ctxt->sc_cur_sge_no;
 	ret = svc_rdma_dma_map_buf(rdma, ctxt,
 				   xdr->head[0].iov_base,
 				   xdr->head[0].iov_len);
@@ -585,8 +680,7 @@ int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma,
 	while (remaining) {
 		len = min_t(u32, PAGE_SIZE - page_off, remaining);
 
-		if (++ctxt->sc_cur_sge_no >= rdma->sc_max_send_sges)
-			return -EIO;
+		++ctxt->sc_cur_sge_no;
 		ret = svc_rdma_dma_map_page(rdma, ctxt, *ppages++,
 					    page_off, len);
 		if (ret < 0)
@@ -600,8 +694,7 @@ int svc_rdma_map_reply_msg(struct svcxprt_rdma *rdma,
 	len = xdr->tail[0].iov_len;
 tail:
 	if (len) {
-		if (++ctxt->sc_cur_sge_no >= rdma->sc_max_send_sges)
-			return -EIO;
+		++ctxt->sc_cur_sge_no;
 		ret = svc_rdma_dma_map_buf(rdma, ctxt, base, len);
 		if (ret < 0)
 			return ret;
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 6f9f4654338c..027a3b07d329 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -419,12 +419,9 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	/* Transport header, head iovec, tail iovec */
 	newxprt->sc_max_send_sges = 3;
 	/* Add one SGE per page list entry */
-	newxprt->sc_max_send_sges += svcrdma_max_req_size / PAGE_SIZE;
-	if (newxprt->sc_max_send_sges > dev->attrs.max_send_sge) {
-		pr_err("svcrdma: too few Send SGEs available (%d needed)\n",
-		       newxprt->sc_max_send_sges);
-		goto errout;
-	}
+	newxprt->sc_max_send_sges += (svcrdma_max_req_size / PAGE_SIZE) + 1;
+	if (newxprt->sc_max_send_sges > dev->attrs.max_send_sge)
+		newxprt->sc_max_send_sges = dev->attrs.max_send_sge;
 	newxprt->sc_max_req_size = svcrdma_max_req_size;
 	newxprt->sc_max_requests = svcrdma_max_requests;
 	newxprt->sc_max_bc_requests = svcrdma_max_bc_requests;

