Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAD2EC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ABFF9205C9
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:06:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qmALly9K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABFF9205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726315AbeK0HCD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:02:03 -0500
Received: from mail-io1-f67.google.com ([209.85.166.67]:33055 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726296AbeK0HCD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:02:03 -0500
Received: by mail-io1-f67.google.com with SMTP id t24so9280303ioi.0;
        Mon, 26 Nov 2018 12:06:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=kcLN7lYOWSI8tPgRxGMTxUscZ+lKKeB8P32rMcwlmPw=;
        b=qmALly9Kfy1aTLUBgPhBvGk9jn2g7MtmJSRyuf5jUlin2XAACqyuMn59HlrJnd2wdk
         gOEUlqqPAIyT38qKgFeSjAWo6jsJiN+P/OGiwUEuBTsSkihvX5Z9sq2zH7KN7Ko2ySm+
         7YogpZjlPAcX7x2ocgTISJK6MOQHtXyuCJqDTOtNb/LHuRj/NLbP2KhJGsbRC3su0GG7
         8tKWcUfgqZEeRs0BOke7oHP1rOm1YB5ehEz6gHte+RQutEfAwyDKNZHAtBEEWXr6p/7h
         f34EK/PZJZ5Tr5BZaATRHjR/NccZGKWoWFxnVLeW+KQNMTAZB5XDJUbKD1upSD/AVVFZ
         a1UQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=kcLN7lYOWSI8tPgRxGMTxUscZ+lKKeB8P32rMcwlmPw=;
        b=EALqLMDyGsK7s9CErPKy7TF/PYHU6TKwU6EQu1rDph7K4CPM1nsl+aNAfqNy7HmXbG
         tx1VzXgHtPT/vVvdmR5arzsclZjeT2mhyMmrJ/raH3z4fOnyQlXOilGmQbJuVf3M26Ce
         /vPTFQGcuGPMpdt7xHA4jDARp89kx2HFTHMG90pIDimzzmdEJKy4BVMKBqEKP8rEECiI
         1E+qYdrfQ/+krj1Ob9BaDYBRy4Q3GRrg/Dvc4WDSwRiysOtSkCTaSNTMtUPFTv35kt4H
         i99dP5yPOrJa5MZVXNpJStopWylgNw0dhvH0fCynGXXgtFll2hXYptt/gT1kKf6Pih1M
         De3g==
X-Gm-Message-State: AA+aEWbGE66+QZY98ZAap040plJkNMNgG2sELHinS3xtO46yIVm870J+
        iHp454Z6iN1vH0W32EstohEvyK8A
X-Google-Smtp-Source: AFSGD/WQHQpCiPo6Ae4SKEtVfPZJhs6HdcQQnEdqe3XdHBbyhU1PmZk3czO5X96RSZdMswQvbKHUZg==
X-Received: by 2002:a6b:8f42:: with SMTP id r63mr21324505iod.202.1543262808348;
        Mon, 26 Nov 2018 12:06:48 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id c25sm435973ioa.86.2018.11.26.12.06.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:06:47 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK6kak010675;
        Mon, 26 Nov 2018 20:06:46 GMT
Subject: [PATCH v2 11/20] xprtrdma: Prevent req creation while unloading the
 underlying device
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 26 Nov 2018 15:06:46 -0500
Message-ID: <20181126200645.10321.49169.stgit@manet.1015granger.net>
In-Reply-To: <20181126194611.10321.71714.stgit@manet.1015granger.net>
References: <20181126194611.10321.71714.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In a subsequent patch, we'll be invoking rpcrdma_req_create()
during transport operation. To protect the walk of rb_allreqs in
rpcrdma_ia_remove, block creation of rpcrdma_reqs while a removal
is in progress.

Because the caller of ->close is holding the transport send lock,
there can be only one call at a time. We don't need the test_and_set
mechanism to prevent multiple callers to rpcrdma_ia_remove.

Comments are clarified to note how the data structures are
protected.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    3 ++-
 net/sunrpc/xprtrdma/verbs.c     |   18 ++++++++++++++----
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 2ba8be1..3cbc9b7 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -446,9 +446,10 @@
 
 	dprintk("RPC:       %s: closing xprt %p\n", __func__, xprt);
 
-	if (test_and_clear_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags)) {
+	if (test_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags)) {
 		xprt_clear_connected(xprt);
 		rpcrdma_ia_remove(ia);
+		clear_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags);
 		return;
 	}
 	if (ep->rep_connected == -ENODEV)
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 42a6ef6..6308e60 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -452,8 +452,7 @@
  * rpcrdma_ia_remove - Handle device driver unload
  * @ia: interface adapter being removed
  *
- * Divest transport H/W resources associated with this adapter,
- * but allow it to be restored later.
+ * Caller holds the transport send lock.
  */
 void
 rpcrdma_ia_remove(struct rpcrdma_ia *ia)
@@ -484,16 +483,23 @@
 	ib_free_cq(ep->rep_attr.send_cq);
 	ep->rep_attr.send_cq = NULL;
 
-	/* The ULP is responsible for ensuring all DMA
-	 * mappings and MRs are gone.
+	/* The ib_drain_qp above guarantees that all posted
+	 * Receives have flushed, which returns the transport's
+	 * rpcrdma_reps to the rb_recv_bufs list.
 	 */
 	list_for_each_entry(rep, &buf->rb_recv_bufs, rr_list)
 		rpcrdma_dma_unmap_regbuf(rep->rr_rdmabuf);
+
+	/* DMA mapping happens in ->send_request with the
+	 * transport send lock held. Our caller is holding
+	 * the transport send lock.
+	 */
 	list_for_each_entry(req, &buf->rb_allreqs, rl_all) {
 		rpcrdma_dma_unmap_regbuf(req->rl_rdmabuf);
 		rpcrdma_dma_unmap_regbuf(req->rl_sendbuf);
 		rpcrdma_dma_unmap_regbuf(req->rl_recvbuf);
 	}
+
 	rpcrdma_mrs_destroy(buf);
 	ib_dealloc_pd(ia->ri_pd);
 	ia->ri_pd = NULL;
@@ -1071,9 +1077,13 @@ struct rpcrdma_sendctx *rpcrdma_sendctx_get_locked(struct rpcrdma_buffer *buf)
 struct rpcrdma_req *
 rpcrdma_req_create(struct rpcrdma_buffer *buffer, gfp_t flags)
 {
+	struct rpcrdma_ia *ia = rdmab_to_ia(buffer);
 	struct rpcrdma_regbuf *rb;
 	struct rpcrdma_req *req;
 
+	if (test_bit(RPCRDMA_IAF_REMOVING, &ia->ri_flags))
+		return NULL;
+
 	req = kzalloc(sizeof(*req), flags);
 	if (req == NULL)
 		return NULL;

