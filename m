Return-Path: <SRS0=RSPU=QN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNWANTED_LANGUAGE_BODY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F33ACC282C2
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 17:00:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C1F6B20823
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 17:00:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GPuG0rLb"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730851AbfBFRAz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Feb 2019 12:00:55 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:37089 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730124AbfBFRAz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2019 12:00:55 -0500
Received: by mail-it1-f194.google.com with SMTP id b5so7874197iti.2;
        Wed, 06 Feb 2019 09:00:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=ADQL5MOt3ylPhLraNIk12Xs5Dm8zEXxCoHhSgYXC+5U=;
        b=GPuG0rLbZILnYEEjkwSuKnKwNSeYEumRAkEZyyLFjGrh4U00zN2eJNQ3se+zlLpPHJ
         lyHv4vIQ/UqI+Fv8L6r1HXliv0plf8X4tujDarjcn6eHpVyk7CkgGyXyTyFRMqHJrC/p
         CVpG/BqruGABAGBDFkr2zvSrJPYjQ8iT/eRFPjTzaZJ4hh37lALlWFv8hvY4hKTzt/W6
         YuNd1qE4VKqBnNs7BsTyB4/PACJC7UWVGgJCfre2reYN1IddqUgpU9kATJn34E/MlxZE
         sYCHOmKwjmArXB+wTgS+Xs9bjxBPncWMkQypcwsnNZXPjegdIOwo0Ye2TQzeNQXc4hrD
         LKPg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=ADQL5MOt3ylPhLraNIk12Xs5Dm8zEXxCoHhSgYXC+5U=;
        b=PHhCbnx7939elWS6cqE/qlLBNdo35YtvUdE9e4r1sAM7SjhumNhvnIvFSpdNnW5FlP
         0TrImH/GhKkDVmY6oINToIz30PoTFfKfUBAdB8MlyvRBdK46wS5FeSoZ4B6EY/VpSJJw
         JTE6gItvGMu3j1aQymZkv3EuZGJzPC3SPqhLnXIj1T75Yx7skG+3EuLBVj3xf793yC0p
         CRNTtrZ/lTzVFN5raZ2NUa+6788mddIkjunwZFNwscYJpBpdTNZ4PgPBf71hWUw3t1nn
         HuYg9IcddsLhM110ltRILLo/bMVs02S7Hojrdie2jqpm4rZQMew3flDprXmwg+UBphgU
         poPQ==
X-Gm-Message-State: AHQUAub4tb2ZL4bCL7AnCnZDZ/tY2Cc4SYtEXGM1FoeQozGkF5BFQDFK
        tlt0T3TJiPsl9EO5OmPmT0Y9wE3W
X-Google-Smtp-Source: AHgI3IZ0efucqpG/ZWELpTqNfExwsKtB22ZpSwb/Vq3XpuJax2KFS+pcsg9EwKtZq/uQD6nwI1zNVg==
X-Received: by 2002:a6b:5006:: with SMTP id e6mr6688798iob.132.1549472453476;
        Wed, 06 Feb 2019 09:00:53 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id z124sm6248747itz.42.2019.02.06.09.00.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 09:00:52 -0800 (PST)
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x16H0q8X016042;
        Wed, 6 Feb 2019 17:00:52 GMT
Subject: [PATCH 1 1/2] svcrdma: Squelch compiler warning when SUNRPC_DEBUG
 is disabled
From:   Chuck Lever <chuck.lever@oracle.com>
To:     bfields@fieldses.org
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 06 Feb 2019 12:00:52 -0500
Message-ID: <20190206170051.27481.84042.stgit@klimt.1015granger.net>
In-Reply-To: <20190206170018.27481.32275.stgit@klimt.1015granger.net>
References: <20190206170018.27481.32275.stgit@klimt.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

  CC [M]  net/sunrpc/xprtrdma/svc_rdma_transport.o
linux/net/sunrpc/xprtrdma/svc_rdma_transport.c: In function ‘svc_rdma_accept’:
linux/net/sunrpc/xprtrdma/svc_rdma_transport.c:452:19: warning: variable ‘sap’ set but not used [-Wunused-but-set-variable]
  struct sockaddr *sap;
                   ^

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index 924c17d..4cbb37d 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -390,8 +390,8 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	struct ib_qp_init_attr qp_attr;
 	unsigned int ctxts, rq_depth;
 	struct ib_device *dev;
-	struct sockaddr *sap;
 	int ret = 0;
+	RPC_IFDEBUG(struct sockaddr *sap);
 
 	listen_rdma = container_of(xprt, struct svcxprt_rdma, sc_xprt);
 	clear_bit(XPT_CONN, &xprt->xpt_flags);
@@ -528,6 +528,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	if (ret)
 		goto errout;
 
+#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 	dprintk("svcrdma: new connection %p accepted:\n", newxprt);
 	sap = (struct sockaddr *)&newxprt->sc_cm_id->route.addr.src_addr;
 	dprintk("    local address   : %pIS:%u\n", sap, rpc_get_port(sap));
@@ -538,6 +539,7 @@ static struct svc_xprt *svc_rdma_accept(struct svc_xprt *xprt)
 	dprintk("    rdma_rw_ctxs    : %d\n", ctxts);
 	dprintk("    max_requests    : %d\n", newxprt->sc_max_requests);
 	dprintk("    ord             : %d\n", conn_param.initiator_depth);
+#endif
 
 	trace_svcrdma_xprt_accept(&newxprt->sc_xprt);
 	return &newxprt->sc_xprt;

