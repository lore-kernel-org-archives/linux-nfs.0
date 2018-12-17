Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7262BC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 43E342133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:40:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VimDbzV9"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388276AbeLQQkd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:40:33 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:53920 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2387905AbeLQQkd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:40:33 -0500
Received: by mail-it1-f196.google.com with SMTP id g85so19463209ita.3;
        Mon, 17 Dec 2018 08:40:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=2kgtkyFhKXfzrghxvQsBnyUA+KcQv3ItXO8NKS1hJvg=;
        b=VimDbzV9Cp0kOTyzi/o5wWfCqdc6nyj3gE43W7aOYYYevitLiQSEUwCehrVm+BnWqT
         MfAGGo6hg9l5BBP0xQym0DWwrork7tKh5O/bOPNXEyb9C/aJ6wGvCoO9T1ww1/kocVlO
         4BxvlUsAWxm3K241VQhXM8oxzoY9rdak8OIF7iurjreLWsv0ZhM/4GMTOMK0HW5AK608
         xKMH2kS+iqLp/ZyDbWLdMQsQIcnjYp48rOnsNZjCOjDJEBtmFBoQ+d4RY/5esmJ6CRKr
         K0ei6pVtCXgMV1rUOxI4s/b8kHOp7QjemcrRG7PBjbDQAma52OG8eN9HrIqR5rRUBUpM
         GIkg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=2kgtkyFhKXfzrghxvQsBnyUA+KcQv3ItXO8NKS1hJvg=;
        b=sag0fW+YOt1lBy4gf5hB/AcYCtaLR12TYyJc7CA4OIWo5qV7sSUwD2aqOyyg6Dx7+T
         gVwmUsDvgMtEbDVGZSSrfS4uUsjmEAyxoALME6oiXKZPrJnk2e+Hu77f5hxjsLafIxgK
         m0TDAGpj4vZjyOCk6B8jPxgT94qV2t+iaMYMdj+qDLzM2Iidd52oInkMeXZnrRfcG6co
         GGpSnHJZRcLACzRSYKCoBmgTHACiby1+LEunyMPGYEu8Jhz/SwnH/KhKzguSYS+1w1w1
         ZHchT+qtSgChQIFGQDZcPTGJ2TV6HqpNhWa2pMHBXQ9H3q51VNvtOd+pWDgx1eMCxdzc
         RGBw==
X-Gm-Message-State: AA+aEWaN7MCe08g5HaAF8TB722SQzsKIXamFco81dMecQNMxAdcN7ymw
        xBsYbQcCuIHP8BtYPH3WzM3ts55v
X-Google-Smtp-Source: AFSGD/XyZbdwNTq8fwlogtW2rFQQfC9+GFOS4lRwOsvJBrASoA/uVI29W9oz+nY6KUW3y3MrFvmikA==
X-Received: by 2002:a24:3c43:: with SMTP id m64mr12146546ita.22.1545064832166;
        Mon, 17 Dec 2018 08:40:32 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id v21sm5340430ios.42.2018.12.17.08.40.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:40:31 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGeULW018617;
        Mon, 17 Dec 2018 16:40:30 GMT
Subject: [PATCH v4 13/30] xprtrdma: Recognize XDRBUF_SPARSE_PAGES
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:40:30 -0500
Message-ID: <20181217164030.24133.8079.stgit@manet.1015granger.net>
In-Reply-To: <20181217162406.24133.27356.stgit@manet.1015granger.net>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Commit 431f6eb3570f ("SUNRPC: Add a label for RPC calls that require
allocation on receive") didn't update similar logic in rpc_rdma.c.
I don't think this is a bug, per-se; the commit just adds more
careful checking for broken upper layer behavior.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 3804fb3..939f84a 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -218,11 +218,12 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 	ppages = xdrbuf->pages + (xdrbuf->page_base >> PAGE_SHIFT);
 	page_base = offset_in_page(xdrbuf->page_base);
 	while (len) {
-		if (unlikely(!*ppages)) {
-			/* XXX: Certain upper layer operations do
-			 *	not provide receive buffer pages.
-			 */
-			*ppages = alloc_page(GFP_ATOMIC);
+		/* ACL likes to be lazy in allocating pages - ACLs
+		 * are small by default but can get huge.
+		 */
+		if (unlikely(xdrbuf->flags & XDRBUF_SPARSE_PAGES)) {
+			if (!*ppages)
+				*ppages = alloc_page(GFP_ATOMIC);
 			if (!*ppages)
 				return -ENOBUFS;
 		}

