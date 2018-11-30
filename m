Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9343C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:46:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6D0482080A
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:46:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="k0ydvM6J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D0482080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726593AbeLAH4p (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 02:56:45 -0500
Received: from mail-qt1-f193.google.com ([209.85.160.193]:39412 "EHLO
        mail-qt1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725867AbeLAH4p (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 02:56:45 -0500
Received: by mail-qt1-f193.google.com with SMTP id n21so7413000qtl.6
        for <linux-nfs@vger.kernel.org>; Fri, 30 Nov 2018 12:46:13 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=0ijSQQXfVbJbBhgTwJQm08iG9zW4J0IaoqxGu6N1F14=;
        b=k0ydvM6JOak6Mb5bGBqr4U2TunuYT235vTL/lqd8a1UtUWJQxxrovicnZDnOQCQo9Q
         5/Ttdpz+l1I05UQC4hqO3loBD8VFbkDXkr8L+iQm1QAKmHEbYzsgnyg8+uBMVTgr6QRA
         klaxG0LeUAgEj3jylMEBWbwdyu4Au8OOX99dxZ/ZeRtOUVD8jUzEEUZYyCjqwo7plSBU
         JMQOaafL0PoczZto0g3djkk8YnoSbDUkgnOcEYdasPj8HMNyWK4NsybJjCgz9eWW2IgF
         gvSNAZjgRi/73bUse/NIxJswj9j31/uyZ+LBmmoEtFhAfXIFU/d3T91JzO80KbaWNLMg
         Vrdg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=0ijSQQXfVbJbBhgTwJQm08iG9zW4J0IaoqxGu6N1F14=;
        b=a/RVIh0F6IMYlT39Nwy8CREi/IiqArYb3izb35pDik3goHoKUrVeRTpZODES8V8iRd
         qqhWinN9Vzsr4QLqpHHbq+IaGvI5viROTRp7CJnndcl0IZQyd3n2rKdv3YTUEacSPpyH
         aFiVWAU100nPRz93M2lzxn02cUCqD6T9bgvcoppgoSP7XyFZzErhG+5wS29LKEprtygu
         G4jfQQ8XoNZRz5lUU2syLU4qGAFeQ4RmyC/adJLtBSQBcFu5uYfjFLYgNUYqZNVO/ERC
         85TNv8N8PzoJSEKhFQgPthe7128F0+xPRHnw6MG4aa/oIej9arQQzsDsLjhuukNDPfh9
         KMRA==
X-Gm-Message-State: AA+aEWYX3G5BORei1f5rCQy3rekHFd9aVfT4qhjQPZrZNfckeXcbloFR
        Ap1JvzXKFnEiMVzg70Px0iw=
X-Google-Smtp-Source: AFSGD/Wbfj9dAin0f+fDy/PA75pD33GZUV/yorwFrxiVmheb7oa+0bqTg9AK4AaAjpVF/C30JbLnuA==
X-Received: by 2002:ac8:4901:: with SMTP id e1mr6787573qtq.244.1543610399962;
        Fri, 30 Nov 2018 12:39:59 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id v10sm3093929qkb.57.2018.11.30.12.39.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 12:39:58 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAUKdvFe021915;
        Fri, 30 Nov 2018 20:39:57 GMT
Subject: [PATCH] SUNRPC: Fix leak of krb5p encode pages
From:   Chuck Lever <chuck.lever@oracle.com>
To:     trond.myklebust@primarydata.com
Cc:     linux-nfs@vger.kernel.org
Date:   Fri, 30 Nov 2018 15:39:57 -0500
Message-ID: <20181130203957.2378.23724.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

call_encode can be invoked more than once per RPC call. Ensure that
each call to gss_wrap_req_priv does not overwrite pointers to
previously allocated memory.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@kernel.org
---
 net/sunrpc/auth_gss/auth_gss.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 5d3f252..ba76547 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1791,6 +1791,7 @@ static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 	for (i=0; i < rqstp->rq_enc_pages_num; i++)
 		__free_page(rqstp->rq_enc_pages[i]);
 	kfree(rqstp->rq_enc_pages);
+	rqstp->rq_release_snd_buf = NULL;
 }
 
 static int
@@ -1799,6 +1800,9 @@ static void gss_wrap_req_encode(kxdreproc_t encode, struct rpc_rqst *rqstp,
 	struct xdr_buf *snd_buf = &rqstp->rq_snd_buf;
 	int first, last, i;
 
+	if (rqstp->rq_release_snd_buf)
+		rqstp->rq_release_snd_buf(rqstp);
+
 	if (snd_buf->page_len == 0) {
 		rqstp->rq_enc_pages_num = 0;
 		return 0;

