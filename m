Return-Path: <SRS0=wtRa=SM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD8D9C10F11
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:06:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8C60B2075B
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Apr 2019 20:06:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MzIegQga"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726548AbfDJUGo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Apr 2019 16:06:44 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:38103 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726014AbfDJUGo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2019 16:06:44 -0400
Received: by mail-it1-f195.google.com with SMTP id f22so5626482ita.3;
        Wed, 10 Apr 2019 13:06:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=JKd9iNK2TVT0ttMrh4M0Vr+V0PaJkHGg3Qk02sk8z34=;
        b=MzIegQgapTWEzPIH1FTc6MrB2ozxM75F+1l1HK2daHsaMD2oj8fHSUBAXsDUJu8SSD
         ubC2MlcxS1j3pb76pGVeueLp7DfAmGzQDVeYtDbccnmMi/jOwfo2RpMVFmtucesU8U7l
         2PehMU9ViR/MVLot9bYI8qTBFTKa7pecGT9TbyADsxzuFWulz6C/YBNfye8kvq6hE+7l
         1Bk+dsTEhYoaHDkPIo1sEe62pA6uHcXpBMqqRlkD9kVyzLowtO7CR6wvb50fNsfa2ru2
         SFA2yVrQGki9qra0L9FCB14AtR6yr9X2w53hTPybNnbBkrSVsJdTkK9KwvLdC2NXNSkp
         w5xw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=JKd9iNK2TVT0ttMrh4M0Vr+V0PaJkHGg3Qk02sk8z34=;
        b=D9mE9V+la2Hqwk+nmctZa9SqukXC2wm8lGUlIfRL5EFurbCoqjOS1PAGwcwy+yCNSA
         YnhagKNF20f1YHvidw0xkaIx0d9AM/k2FJbhSQQBqoFYUV6nUN1KSVQBd6Bn5SixjRfZ
         ovTXS/uDkIVS9J4TqzcG6CHxgeOLI7+0TrGQboy29YaKDXtSr8U7N3xBL7bnlo/LEkE/
         Vqd+4hqkwnpCOEGUwK+Lnn4LmNU1gYd293E9tD2Oz3H60n3r2sCzvKeG5V278OJ5k8Oy
         CwawNbx/oP0BZQoErx/x6giG85qB/wfbl0QdYGBfgdyXGj94Ycqt0FEwePf+ssUDaDlw
         cyFg==
X-Gm-Message-State: APjAAAWIqyQxnW9sOoCYNXmogx1NoKmvYB6sEG8pdq7x1e/W2gwoqDGG
        oDa9oEudMlX2b+qjY7LoKUKHnRLB
X-Google-Smtp-Source: APXvYqxCE/fXE7spYLTvsiwONgHmMPlc9PK0ICMK8ku0fyywldc6JY93ITng/eGg+TEPKv/B62vahw==
X-Received: by 2002:a24:438e:: with SMTP id s136mr4929017itb.110.1554926803595;
        Wed, 10 Apr 2019 13:06:43 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id t2sm1565250itb.37.2019.04.10.13.06.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 13:06:43 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3AK6gYa004509;
        Wed, 10 Apr 2019 20:06:42 GMT
Subject: [PATCH v1 02/19] xprtrdma: Fix an frwr_map recovery nit
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 10 Apr 2019 16:06:42 -0400
Message-ID: <20190410200642.11522.3821.stgit@manet.1015granger.net>
In-Reply-To: <20190410200446.11522.21145.stgit@manet.1015granger.net>
References: <20190410200446.11522.21145.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

After a DMA map failure in frwr_map, mark the MR so that recycling
won't attempt to DMA unmap it.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Fixes: e2f34e26710b ("xprtrdma: Yet another double DMA-unmap")
---
 net/sunrpc/xprtrdma/frwr_ops.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/frwr_ops.c b/net/sunrpc/xprtrdma/frwr_ops.c
index 52cb6c1..a2a2e01 100644
--- a/net/sunrpc/xprtrdma/frwr_ops.c
+++ b/net/sunrpc/xprtrdma/frwr_ops.c
@@ -466,7 +466,7 @@ struct rpcrdma_mr_seg *frwr_map(struct rpcrdma_xprt *r_xprt,
 	return seg;
 
 out_dmamap_err:
-	frwr->fr_state = FRWR_IS_INVALID;
+	mr->mr_dir = DMA_NONE;
 	trace_xprtrdma_frwr_sgerr(mr, i);
 	rpcrdma_mr_put(mr);
 	return ERR_PTR(-EIO);

