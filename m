Return-Path: <SRS0=5wB/=TD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32DA2C43219
	for <linux-nfs@archiver.kernel.org>; Fri,  3 May 2019 11:22:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 041AE2081C
	for <linux-nfs@archiver.kernel.org>; Fri,  3 May 2019 11:22:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bC/EQjyw"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726901AbfECLWt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 3 May 2019 07:22:49 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:51280 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726372AbfECLWt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 May 2019 07:22:49 -0400
Received: by mail-it1-f195.google.com with SMTP id s3so8513775itk.1
        for <linux-nfs@vger.kernel.org>; Fri, 03 May 2019 04:22:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=DHLknTlY+PguemNFgNc/OzCfTW9tQ+mNfJOlb0yy1So=;
        b=bC/EQjywTVz26giGyowq5ZPoejLHxrA/2iC1tB68SW9KrdbtdFa0xX6kjAn5X5csGX
         D4WdXZdMdyrv1b25+6l5uTvA6+Ke4ffzVkoryEOlCEXwQglxi7UI8/iKXQlR8k8JTdUV
         qa7DqNcNmkxv5wOIEYekXncbGsKhl+p+QVRvCqd1N/vNY5myz9PC32UY1tDAjOsfiP+v
         yqEY/hjo6N75abAp7Huw6kpkPKENQYwrvWo4LN98/CGQWvhS1mAVx4BKael0WwHTRvDf
         YXCI1fxISoT1SaFFQZlgE6xjxyfUt8f6MHtwXKIoia64igh0wafaTOeLU/za2VW3VxBS
         76QA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=DHLknTlY+PguemNFgNc/OzCfTW9tQ+mNfJOlb0yy1So=;
        b=dLeODTz+OyhXmVLX/s5vgwur3FHWRJSf422htDRREWYD+iYl81jnEj/u5s1fWrejzE
         RwpcdRxvR7piAIXfKgEirlbT0tWIhVxKZ3roO7pRYD5kKL8zi0NEgfI93A/8AzH3iTzD
         dO5Lx9tkeENLFT5BHfuPiMP58c040SCKa9IWgOUbrm2De80d7oODWHTBdyeWY4RYUXZB
         o6XwHeSdl4z3ui1zLq5Zbffmd94s5qUpp0zbFQ4jEXXpooL3TuF0rnMtRh5Q+hF2mCdV
         IqpceBvqbAwUuBrqdj1+R3ycAol6Fl+WxTtYYBQioFw0/Mp5Hvcw3sEPyfe+1Lc9ZpYs
         +KUg==
X-Gm-Message-State: APjAAAUEAI+erF3en0z/7GHwsdjEv7SrKwFGCjQeh5ddJYjUhAD8Ohoj
        OMRHiAGG3E7zUhcqvVdxVTXqotCpuw==
X-Google-Smtp-Source: APXvYqwBr3bySW/UdFp4iROXeLDrru9uTqwtvQeeO0bXZEEStFSq8jq35sX9FYxDeX7Th0O2CiI61w==
X-Received: by 2002:a02:8243:: with SMTP id q3mr5806606jag.37.1556882568391;
        Fri, 03 May 2019 04:22:48 -0700 (PDT)
Received: from localhost.localdomain ([8.46.76.65])
        by smtp.gmail.com with ESMTPSA id d193sm737325iog.34.2019.05.03.04.22.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 03 May 2019 04:22:47 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [RFC PATCH 5/5] SUNRPC: Reduce the priority of the xprtiod queue
Date:   Fri,  3 May 2019 06:18:41 -0500
Message-Id: <20190503111841.4391-6-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190503111841.4391-5-trond.myklebust@hammerspace.com>
References: <20190503111841.4391-1-trond.myklebust@hammerspace.com>
 <20190503111841.4391-2-trond.myklebust@hammerspace.com>
 <20190503111841.4391-3-trond.myklebust@hammerspace.com>
 <20190503111841.4391-4-trond.myklebust@hammerspace.com>
 <20190503111841.4391-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Allow more time for softirqd

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/sched.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index c7e81336620c..6b37c9a4b48f 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -1253,7 +1253,7 @@ static int rpciod_start(void)
 		goto out_failed;
 	rpciod_workqueue = wq;
 	/* Note: highpri because network receive is latency sensitive */
-	wq = alloc_workqueue("xprtiod", WQ_UNBOUND|WQ_MEM_RECLAIM|WQ_HIGHPRI, 0);
+	wq = alloc_workqueue("xprtiod", WQ_MEM_RECLAIM | WQ_UNBOUND, 0);
 	if (!wq)
 		goto free_rpciod;
 	xprtiod_workqueue = wq;
-- 
2.21.0

