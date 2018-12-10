Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EE14C5CFFE
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:31:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E7D4520821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:31:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dJWuLfid"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E7D4520821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728382AbeLJQbb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:31:31 -0500
Received: from mail-io1-f68.google.com ([209.85.166.68]:42478 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728314AbeLJQba (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:31:30 -0500
Received: by mail-io1-f68.google.com with SMTP id x6so9208383ioa.9;
        Mon, 10 Dec 2018 08:31:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=H/9tOZULCQlho7UpMYtT0z0OUN++LMCE3R4wcRTcq7E=;
        b=dJWuLfidNgoEinKLYcbPFUoJ9PJWHqxcX+5YrnMzrYe+Y2az29yA4xv6yPtSDSdtLd
         qfEcG2Knt1RXY3NHYscGQV4ZItIHf/MZAcDty6UHSZVMkLFpV4kyBMM68JuAkrxEzoCz
         wBwZDSrr+ovhfNDB68iDrx7E5oqzy4zmIekwy4x2+KDkFY+5RpwfZvU9WGdlr7f/uj3S
         jPHGCrU49VTqFNnlN2eBgUuIBgkEAZDjCUFF/9X5hpgHt0TluCJG+h24p/iN6Hx9wpxx
         WCReNn7svmv03LUVq9Quo3MZdVdehus6L454g1toGc0/IwNXCS3nkjvgY/S2z2u93+21
         a86w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=H/9tOZULCQlho7UpMYtT0z0OUN++LMCE3R4wcRTcq7E=;
        b=unOdkwwuekUiwsvRApKTRjU7hqYaKwkfujrqZI17NnnbqQz2XO8zLlqEfEecjcIwDv
         0BIw9hLYS5rfMj+dXUXaODur9R5oaRCcWbCC5QhEMUjNuOVwhyKGWg7K1rBueTI/8MPN
         lL993lmnPPa/yGaWHwj0XS+4JP4Sij+bRlCeSCDymBs+M14NEc6ID3JpKscS9MBDSWjq
         yFVF1Nd7H/bHW6nX8cJ2iXTQS73eNr3YaRawCfsd3KZk/1HHS0RUI1F8LFvqM3JcOhbd
         iAWwXTwkDqEav5a6uJb8+yG8GH3Qjq66H2c7kRacM9ElNGMKVtxNHWgfNSJDRtr7XQfW
         4eIw==
X-Gm-Message-State: AA+aEWbN75NV5A10st/egkvIPg/6/toTWRz5SvyuQc4UeOtNPqxddDtc
        RLnbbhi/q0SNAQgdT1TmBQg=
X-Google-Smtp-Source: AFSGD/WmHcNl1n5WHMWyy9c16WCTBOpqQMeS9vsNczb+IgqDAkoBvEv5bCvEj8pQ3Gt6/GU1I5uNQg==
X-Received: by 2002:a5e:9703:: with SMTP id w3mr10846165ioj.28.1544459488787;
        Mon, 10 Dec 2018 08:31:28 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id f10sm5894093itf.41.2018.12.10.08.31.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:31:28 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGVRus031095;
        Mon, 10 Dec 2018 16:31:27 GMT
Subject: [PATCH v3 24/24] xprtrdma: Clarify comments in rpcrdma_ia_remove
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:31:27 -0500
Message-ID: <20181210163127.4198.6992.stgit@manet.1015granger.net>
In-Reply-To: <20181210161723.4198.51071.stgit@manet.1015granger.net>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Comments are clarified to note how transport data structures are
protected.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 78a1200..473de08 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -442,8 +442,7 @@
  * rpcrdma_ia_remove - Handle device driver unload
  * @ia: interface adapter being removed
  *
- * Divest transport H/W resources associated with this adapter,
- * but allow it to be restored later.
+ * Callers must serialize calls to this function.
  */
 void
 rpcrdma_ia_remove(struct rpcrdma_ia *ia)
@@ -474,16 +473,23 @@
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

