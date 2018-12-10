Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E376C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:31:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1449B20821
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:31:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZwY3HuhH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1449B20821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727597AbeLJQbT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:31:19 -0500
Received: from mail-io1-f65.google.com ([209.85.166.65]:34795 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727534AbeLJQbT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:31:19 -0500
Received: by mail-io1-f65.google.com with SMTP id r9so9273148ioa.1;
        Mon, 10 Dec 2018 08:31:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=Jg4/K7eJWompRXnQb6daXSzp+cKAasi3aw+RC5lHyoA=;
        b=ZwY3HuhHa7YeEsNa35LrtoWUELS96WoSV8q2SuaY/pay1dFfDL5fGUNcIJ5oHy4xNm
         h9k9Nus4N6Zxm7Pe0rdsPG/y5ISehAncW7ULNO0iC5kB7rjwZiVPZfo9IVETPpPO8F3Z
         L4yaiRXAFWeLaKuvmHGEtoVvuPy3w+rFE4B18gaRfwg+wM+1mNKAUr5ZuY3RUHN3akLh
         REKu/lm+QSX9YD/2RhgeCflN8QHeaFsOXaHC22eYazKNtuBKzC7uj1XKQaXqdGrmw682
         nAqJailICHYu+4nPhjVUIDsXNXaApclIwccR8JIvLfbP5c0W1GQpjp+UqHXL7NqnyiOn
         wW3w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=Jg4/K7eJWompRXnQb6daXSzp+cKAasi3aw+RC5lHyoA=;
        b=h9e9sm2u2y3e0T8qiIB1ezHLfXXX/BSdLMRnOxfdKq6XxfsGnZYbA+bdK0jcwTL4Ar
         zxX+74jhNCnaD5U08CMpyJ7hYuYIG8aduJjjcFY9+B+4XafdLstzCxkYvu+jwoJdJvVP
         3JCbx9Z8SUVE0R7rPa3XOvOQqWQDeqZmuVQgECGRy6InF8luagTOZo4lFNvdnD7cAUff
         HnazFSwbuSAk+b2Rx+iCRcTJnOuY4jDO+g00f55xk3qIW3+MD4xEK7vrqW9Puyh7QSpQ
         ugIJiubwywJBf4s2c/ekJI3a1CCl27iSxqHTTzF2jEDGdJbYQ7Rd1a4Wnk5kMWnytuP9
         wtAA==
X-Gm-Message-State: AA+aEWZ+EOnDbo+SfRH6LK/PDjkwfeAN4WbSfCq9EbRoatsysyll13HG
        tj3qQfeV6CmSufs/wc1Lrzw=
X-Google-Smtp-Source: AFSGD/XmraU7o/QsPfl/Fr+NLVTdpQK1oCLiuEyP4X7bjjELf4at+gRyp96WAW2qpE+DFp6UuSH+OA==
X-Received: by 2002:a5d:9813:: with SMTP id a19mr9363425iol.181.1544459477835;
        Mon, 10 Dec 2018 08:31:17 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id q10sm4325207ios.72.2018.12.10.08.31.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:31:17 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGVGfr031089;
        Mon, 10 Dec 2018 16:31:16 GMT
Subject: [PATCH v3 22/24] xprtrdma: Replace outdated comment for
 rpcrdma_ep_post
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:31:16 -0500
Message-ID: <20181210163116.4198.84287.stgit@manet.1015granger.net>
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

Since commit 7c8d9e7c8863 ("xprtrdma: Move Receive posting to
Receive handler"), rpcrdma_ep_post is no longer responsible for
posting Receive buffers. Update the documenting comment to reflect
this change.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 1ee55d1..f403afc 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1454,10 +1454,14 @@ struct rpcrdma_regbuf *
 	kfree(rb);
 }
 
-/*
- * Prepost any receive buffer, then post send.
+/**
+ * rpcrdma_ep_post - Post WRs to a transport's Send Queue
+ * @ia: transport's device information
+ * @ep: transport's RDMA endpoint information
+ * @req: rpcrdma_req containing the Send WR to post
  *
- * Receive buffer is donated to hardware, reclaimed upon recv completion.
+ * Returns 0 if the post was successful, otherwise -ENOTCONN
+ * is returned.
  */
 int
 rpcrdma_ep_post(struct rpcrdma_ia *ia,

