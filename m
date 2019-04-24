Return-Path: <SRS0=08pM=S2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4271BC10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:38:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0FA1C21773
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Apr 2019 13:38:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YOWs/vql"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730424AbfDXNi5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Apr 2019 09:38:57 -0400
Received: from mail-io1-f65.google.com ([209.85.166.65]:45991 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727112AbfDXNi5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2019 09:38:57 -0400
Received: by mail-io1-f65.google.com with SMTP id e8so3557937ioe.12;
        Wed, 24 Apr 2019 06:38:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=WHZ+h/q/YGUHYxMZ5j/Bf+5zZq+eqcPhO1i86doUWqA=;
        b=YOWs/vqlAw6X3olLSdzuUm+sUbHurTFSShj/9EF6L8HZA3c6CowAUEEW+dabWAEILQ
         fL+vUk06HvJxfTp7BFB10K/5IuRjlcHAYiNmAJSgAhvpcFWQ8pZg3Cp3Yb+w2RkaDN8r
         nt0ji6GWIoi1hBIZlB6OH0CwfKCXRBguB3mo20fuHcQvqclLdm4rcXYvfZucC5l4J9My
         s6uz3GUIH43MHZCPbPpQw1B950yQD9e204c2KPo06jSFeuncwDyaOTobe5zyFkZcwwMg
         TuavGZwSsagZb/imiosdT1tJ3SrVV6py4gyAgJlLEjhKtk2H00RSgwsd1NIhxcHOx6Km
         W/1w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=WHZ+h/q/YGUHYxMZ5j/Bf+5zZq+eqcPhO1i86doUWqA=;
        b=Apn3RVI4Tno7q47/uUpudXqxc8xXJywLUejTEDaHe/dOsbHHh939QLk7t43asgjeyQ
         g/kXuKyFG1PVLN1irpr7AM5AIXFBRZKncyuiblwlnBbYo8232ifBlKbm5F8knpG9zA61
         8h145v+DUDhCynNRt/44abiei4kIjQubMWB3ILwFevM+4EiXDyrFudeg6ZQ4yohRqAvd
         wP/MMaogbc2xwQmQ5H05MMzYzNNPk8wURdnvN9lnaKX1PrdpKPHQOh3KQ4wt1xspFSF0
         37ezq9SmPFo/Ywh8DAfSM31RmM9pWz4vTJhdil3jyy3XIRG3DsYPXFn9mwso6KjjJbKr
         s0+Q==
X-Gm-Message-State: APjAAAXF8uNx4S8ZJ+eAIpFMgJJSXUGKSa8QXRZUlelbiLcqzwvg8i3j
        Pko7a7qrKLEi+JB+R+8Y81E=
X-Google-Smtp-Source: APXvYqwkT1oKX9uV2ZDnE3Kd2dw/SmconE6TrYKTyZlCAX1g2LJqjS3yZPw0XfdseKypc7e1v4bWTw==
X-Received: by 2002:a6b:4102:: with SMTP id n2mr2820837ioa.256.1556113136543;
        Wed, 24 Apr 2019 06:38:56 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id m9sm1566178ioc.73.2019.04.24.06.38.55
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 06:38:55 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3ODcti3011271;
        Wed, 24 Apr 2019 13:38:55 GMT
Subject: [PATCH v3 01/21] SUNRPC: Avoid digging into the ATOMIC pool
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 24 Apr 2019 09:38:55 -0400
Message-ID: <20190424133855.5077.59841.stgit@manet.1015granger.net>
In-Reply-To: <20190424133516.5077.67283.stgit@manet.1015granger.net>
References: <20190424133516.5077.67283.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Page allocation requests made when the SPARSE_PAGES flag is set are
allowed to fail, and are not critical. No need to spend a rare
resource.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/socklib.c           |    2 +-
 net/sunrpc/xprtrdma/rpc_rdma.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index 7e55cfc..9faea12 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -106,7 +106,7 @@ static size_t xdr_skb_read_and_csum_bits(struct xdr_skb_reader *desc, void *to,
 		/* ACL likes to be lazy in allocating pages - ACLs
 		 * are small by default but can get huge. */
 		if ((xdr->flags & XDRBUF_SPARSE_PAGES) && *ppage == NULL) {
-			*ppage = alloc_page(GFP_ATOMIC);
+			*ppage = alloc_page(GFP_NOWAIT | __GFP_NOWARN);
 			if (unlikely(*ppage == NULL)) {
 				if (copied == 0)
 					copied = -ENOMEM;
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 6c1fb27..b759b16 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -238,7 +238,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		 */
 		if (unlikely(xdrbuf->flags & XDRBUF_SPARSE_PAGES)) {
 			if (!*ppages)
-				*ppages = alloc_page(GFP_ATOMIC);
+				*ppages = alloc_page(GFP_NOWAIT | __GFP_NOWARN);
 			if (!*ppages)
 				return -ENOBUFS;
 		}

