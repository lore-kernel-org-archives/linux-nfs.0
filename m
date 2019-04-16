Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 616D6C10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 338BD217F9
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:37:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="X1S+++s4"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729362AbfDPNht (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:37:49 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:50917 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728032AbfDPNhq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:37:46 -0400
Received: by mail-it1-f196.google.com with SMTP id q14so17958920itk.0;
        Tue, 16 Apr 2019 06:37:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=/mL6PL08rwV4R3G11E6ax6rMV4qUz+im5sUnzyLJuLo=;
        b=X1S+++s4Oa+FzQk11EUJTuzCq/ThWX0Pr8auGRd9EJK6HatWJ41OhxskF5LdvYUB48
         LiRE4e2iCe8GlXi2bXH6klT6rAhnxeiTiZeqO3R9aD1SDTllq2TO836T3pVKZ323v/b3
         +C5XepmcA5fCtJtYvqu60fA2qS1zu7mgXEMfYxGoIXmlWmS5glm2Z2zjcPO7XDso5zyI
         9WQimznz7DySj7uwzUO+/OEL30Em/cQGmjt0FNKsBwUwAMLoWduPdet7W7HYtw1T0PIq
         b5AZlGYWR0otgLiRjfy8mag81Vvrh3brvR5fKh73FPlyzsOiMdceai8JAum6a+XWGTXI
         nWew==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=/mL6PL08rwV4R3G11E6ax6rMV4qUz+im5sUnzyLJuLo=;
        b=uO/FdmVaNzut8rfn6aKu5LseU4LHvAITxz5s2v859nEi2i0kvn9S0FQqL0864gaIOR
         hs2Xy//LDYHQDwHfCZUQQgCjSqcawYKV3DBl93QtfwWzYJP1dDoORYwrOqeq0Zc/cCAd
         vwI+4Pt4ULFhYf3/0RHKQJZuovyvG/vqVAM1Ggq0WzP3mrQGzDBONafgScqKpokER8Be
         xjkJKNrX5tjWDMlXe21z0oqlQdPtfs+X9NemKI7wZKQ++cpTtr5zOmRA5lnbd2eNPyyu
         ThnfigobAYuXuUBBeQiu5ihumdIWvcXh7UojnPQOzxmyQvrcKU4T5SsyCFgy/p22BLeW
         N0Cw==
X-Gm-Message-State: APjAAAU8540vWdsLUsus5cwdV2QcH2744VNZO8M9t1B1jiIL950l1wnJ
        qfh1YZldi0dwv981CNnuqSdNAQV4
X-Google-Smtp-Source: APXvYqwIBYuBBLChdAUeXRXnf34DjeSeiEYndrdhFXtX4oEZ9Cik/F43Xw1LioKJiCGKbxwlQBFW/w==
X-Received: by 2002:a24:c544:: with SMTP id f65mr29643641itg.90.1555421865545;
        Tue, 16 Apr 2019 06:37:45 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id q22sm19576242ion.15.2019.04.16.06.37.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:37:44 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDbinM021226;
        Tue, 16 Apr 2019 13:37:44 GMT
Subject: [PATCH v2 10/21] xprtrdma: Increase maximum number of backchannel
 request
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:37:44 -0400
Message-ID: <20190416133744.23113.28165.stgit@manet.1015granger.net>
In-Reply-To: <20190416133156.23113.91846.stgit@manet.1015granger.net>
References: <20190416133156.23113.91846.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Reflects the change introduced in commit 067c46967160 ("NFSv4.1:
Bump the default callback session slot count to 16").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/xprt_rdma.h |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index b942c9d..7621e2d 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -103,12 +103,14 @@ struct rpcrdma_ep {
 
 /* Pre-allocate extra Work Requests for handling backward receives
  * and sends. This is a fixed value because the Work Queues are
- * allocated when the forward channel is set up.
+ * allocated when the forward channel is set up, long before the
+ * backchannel is provisioned. This value is two times
+ * NFS4_DEF_CB_SLOT_TABLE_SIZE.
  */
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
-#define RPCRDMA_BACKWARD_WRS		(8)
+#define RPCRDMA_BACKWARD_WRS (32)
 #else
-#define RPCRDMA_BACKWARD_WRS		(0)
+#define RPCRDMA_BACKWARD_WRS (0)
 #endif
 
 /* Registered buffer -- registered kmalloc'd memory for RDMA SEND/RECV

