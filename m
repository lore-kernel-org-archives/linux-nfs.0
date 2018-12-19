Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45967C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 164CB217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 15:59:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cDtZjQHZ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728002AbeLSP7U (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 10:59:20 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:52834 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727829AbeLSP7U (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 10:59:20 -0500
Received: by mail-it1-f195.google.com with SMTP id g76so10381892itg.2;
        Wed, 19 Dec 2018 07:59:19 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=2kgtkyFhKXfzrghxvQsBnyUA+KcQv3ItXO8NKS1hJvg=;
        b=cDtZjQHZVINMuzPdIBxMGWl/aSWf8EfwBydRbW5IE7/qCQ1hO21/LTFq+J2plprgOt
         l6bpinAIQzF2Xh18YojqtZtUXfBprQZaYvNRvbPHyIHOdx8zp/XQbOJZ6+SPi2Iw3PFv
         J372n0d1ppXvOia/ilByArmthiYJfVLzNlRj+v2RX+mr7v9kSwEHwWEwmPwEUilzTu2C
         MrJCxpvYkub9pY420lIz0B9uRynKaDUwLToRf6w9NX4rTobTh6KJJLNp9K2axjplSAFH
         OVL/w3sepFsCRsHrA9hFw8LN+A6InIfwWq7CmeaYNmFWx9VHQfXq582imPE3yuydamyy
         7aVw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=2kgtkyFhKXfzrghxvQsBnyUA+KcQv3ItXO8NKS1hJvg=;
        b=d8nkqQvIWfqk3jnVrHv7fRwBFlieaQtQV2CW1b98l0BGC3g8LEHr34A0AqZhy/CkCA
         lEb9NxX1NDJ4GCduiokeGOiKTYqqu7Y0alc4i9tg382p9IpXtJbGKKGBE3iascIur9aC
         6lJleY+HuwFmlCCyA948Dpc6a0QeI977JxBBvtJ4/3fMcwOyEzgzOEuS63sz/6W76lQu
         JYuxRQy8HMZCVd3kgZNof4Wsudyb2BBj4TZzFHl4QjCQ5th4EmFMbxHUGvcFOtVB2mz9
         fdZ1g6BsX2tQSwC8SUcMaNGVxvPdjtyZEEgqxjL6b2CydSSE6FKruoqHt9wkz1zpnRYY
         xXeQ==
X-Gm-Message-State: AA+aEWZ4c4q/64XPT90YLlh3LRt7JuNfuojMUt6QU0sctYenSMkjj6Yy
        mkBJeONLKpt5rfuja2oo8wo=
X-Google-Smtp-Source: AFSGD/V7meSFOA0INxG4BARwIRAT+nkpWvcFGQjbsYG5SoSa/MArUkQPeaLuRYOITqEw4kPzxkfTBg==
X-Received: by 2002:a02:c81a:: with SMTP id p26mr8868869jao.59.1545235159301;
        Wed, 19 Dec 2018 07:59:19 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id c3sm8493574ioi.2.2018.12.19.07.59.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 07:59:18 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBJFxHZx025795;
        Wed, 19 Dec 2018 15:59:17 GMT
Subject: [PATCH v5 13/30] xprtrdma: Recognize XDRBUF_SPARSE_PAGES
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 19 Dec 2018 10:59:17 -0500
Message-ID: <20181219155917.11602.66631.stgit@manet.1015granger.net>
In-Reply-To: <20181219155152.11602.18605.stgit@manet.1015granger.net>
References: <20181219155152.11602.18605.stgit@manet.1015granger.net>
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

