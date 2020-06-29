Return-Path: <SRS0=Sa69=AK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43C31C433E1
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Jun 2020 19:39:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 25B1D20672
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Jun 2020 19:39:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="D4umD+4r"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1733243AbgF2Tjd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Jun 2020 15:39:33 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47586 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2387429AbgF2Thm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2020 15:37:42 -0400
Received: from mail-qk1-x741.google.com (mail-qk1-x741.google.com [IPv6:2607:f8b0:4864:20::741])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 805DAC02F019;
        Mon, 29 Jun 2020 07:50:36 -0700 (PDT)
Received: by mail-qk1-x741.google.com with SMTP id k18so15453556qke.4;
        Mon, 29 Jun 2020 07:50:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Knp7Z7LBJqUcvyZ/FlOarstqHDZMyihmvlYEWQ67HgI=;
        b=D4umD+4rtVvPhzz6LyLvgFFqciygyHdgaWeO4RSzC/xpBnKvMAKrc+/Ib10NkKQrCh
         LfbZ3VkUWK2b+5RRkF2vOvAHo0GJ3ovuok7LAmNZuPc8RP6t2rsp4qUp407FlnEawAuw
         EAGprvbIC8XS+tEAYZ3ybGyp8Eu38bmV0qEYLuK+tnHmFR47VCyfX4t/W3dLBb7KfsuN
         0Gsq64Ml2gFgQq0iMVQxqjZqIR2yVkrronasFD4JdufftiKFrMIAU3i3MRYYyFijP1PL
         S+K6Zb71alSIIM4ra72gZcTfXDwqXmKcp1rxvqrWZ1uNQC2I/uWmLokbPPMWQiOB75mF
         Tgww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Knp7Z7LBJqUcvyZ/FlOarstqHDZMyihmvlYEWQ67HgI=;
        b=Mii7ahgcAsZ6D1zCV7kT1674NxJsIG6IzGPlf5WHtiXWgl5Er/q+p6zYhHd2lauaIK
         EJhiBR1HTlb3gEizvsWmWzpTtKTslqzAoDRwKDfqwCrBXjKIG5IRuPxfwnoRYUGuqVNj
         aOjb1peex6tiAY8xOEQexwPD4ENNlTyJZA+cGODM4tTGyg50ahMMSNfVMcdgIx175WQp
         fDgMoVXF9gk55j46FcQYAk4TDElKTunBBezWfXWXhSIrmXdsg1ztSGHVgA+RrM/v59hW
         ZatnHjSYd3iYewd+yzgsG15ewUJCljZL8HYSbenmGA7fPHiTyHMlvVl8DqFZfIy2e7bw
         dvvg==
X-Gm-Message-State: AOAM532zWkDRXMFPcqPx1riTWIkZE6Qqau+YIhUjBaJf7bZlQu8BeAQH
        d/Ic3uGZqVGdq3VF0JliJP3cBUm4
X-Google-Smtp-Source: ABdhPJyglQjjlOJ63CgAggF4qRPdlvCH/NMt6ny94quAklA6YXQCLO4Cuk81DyKUDqo4+oq4l3K0GA==
X-Received: by 2002:a37:9dd3:: with SMTP id g202mr14545468qke.432.1593442235607;
        Mon, 29 Jun 2020 07:50:35 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id b186sm42570qkd.28.2020.06.29.07.50.35
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jun 2020 07:50:35 -0700 (PDT)
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id 05TEoYZq006214;
        Mon, 29 Jun 2020 14:50:34 GMT
Subject: [PATCH v2 7/8] svcrdma: Consolidate send_error helper functions
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date:   Mon, 29 Jun 2020 10:50:34 -0400
Message-ID: <20200629145034.15024.54133.stgit@klimt.1015granger.net>
In-Reply-To: <20200629144802.15024.30635.stgit@klimt.1015granger.net>
References: <20200629144802.15024.30635.stgit@klimt.1015granger.net>
User-Agent: StGit/0.22-31-g4b47
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Final refactor: Replace internals of svc_rdma_send_error() with a
simple call to svc_rdma_send_error_msg().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |   52 +++----------------------------
 1 file changed, 5 insertions(+), 47 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
index 60d855116ae7..c072ce61b393 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_recvfrom.c
@@ -714,58 +714,16 @@ static void rdma_read_complete(struct svc_rqst *rqstp,
 	rqstp->rq_arg.buflen = head->rc_arg.buflen;
 }
 
-static void svc_rdma_send_error(struct svcxprt_rdma *xprt,
+static void svc_rdma_send_error(struct svcxprt_rdma *rdma,
 				struct svc_rdma_recv_ctxt *rctxt,
 				int status)
 {
-	__be32 *p, *rdma_argp = rctxt->rc_recv_buf;
-	struct svc_rdma_send_ctxt *ctxt;
-	int ret;
+	struct svc_rdma_send_ctxt *sctxt;
 
-	ctxt = svc_rdma_send_ctxt_get(xprt);
-	if (!ctxt)
+	sctxt = svc_rdma_send_ctxt_get(rdma);
+	if (!sctxt)
 		return;
-
-	p = xdr_reserve_space(&ctxt->sc_stream,
-			      rpcrdma_fixed_maxsz * sizeof(*p));
-	if (!p)
-		goto put_ctxt;
-
-	*p++ = *rdma_argp;
-	*p++ = *(rdma_argp + 1);
-	*p++ = xprt->sc_fc_credits;
-	*p = rdma_error;
-
-	switch (status) {
-	case -EPROTONOSUPPORT:
-		p = xdr_reserve_space(&ctxt->sc_stream, 3 * sizeof(*p));
-		if (!p)
-			goto put_ctxt;
-
-		*p++ = err_vers;
-		*p++ = rpcrdma_version;
-		*p = rpcrdma_version;
-		trace_svcrdma_err_vers(*rdma_argp);
-		break;
-	default:
-		p = xdr_reserve_space(&ctxt->sc_stream, sizeof(*p));
-		if (!p)
-			goto put_ctxt;
-
-		*p = err_chunk;
-		trace_svcrdma_err_chunk(*rdma_argp);
-	}
-
-	ctxt->sc_send_wr.num_sge = 1;
-	ctxt->sc_send_wr.opcode = IB_WR_SEND;
-	ctxt->sc_sges[0].length = ctxt->sc_hdrbuf.len;
-	ret = svc_rdma_send(xprt, &ctxt->sc_send_wr);
-	if (ret)
-		goto put_ctxt;
-	return;
-
-put_ctxt:
-	svc_rdma_send_ctxt_put(xprt, ctxt);
+	svc_rdma_send_error_msg(rdma, sctxt, rctxt, status);
 }
 
 /* By convention, backchannel calls arrive via rdma_msg type

