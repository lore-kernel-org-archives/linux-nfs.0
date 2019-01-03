Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C638FC43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 14:18:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8D02820815
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 14:18:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="L5xO1kq4"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730780AbfACOSW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 09:18:22 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:51170 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727650AbfACOSW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 09:18:22 -0500
Received: by mail-it1-f194.google.com with SMTP id z7so45396322iti.0
        for <linux-nfs@vger.kernel.org>; Thu, 03 Jan 2019 06:18:22 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=p+jVw7m1VkU55Z+h4vl73u59DzM+akbkAL24Sfw8S3w=;
        b=L5xO1kq4T/nMKepbB02U3sVRnVdRIO/ECLd/mPXPnktVzn9jS1Lpj6Xq2p/g6cKKXr
         d0EXpUEMx3eWSNpzDs6EcCQ15Be5ANXCMoRBR+SOPxN1SCmCnJJvodfRiJ30OuQSo7ye
         4TyWZnedDKSr/EWsyVht12SVqXYmh/+veTOmvvwmnL7mF6UkJiPUbsNlZr4mdRDrFKa+
         d80f1SyLiZezK7Z/nrerVPI989v3ol6+bN6zQ4kbZak6x9ch21yAPtnvgsOZroA9oLOU
         JjZVpj4Kaqjd0rPFAGUyTcc39hs/566UNdJkaEBtCFnwHZraLnIkx3b09yGpXsvlekug
         grFw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=p+jVw7m1VkU55Z+h4vl73u59DzM+akbkAL24Sfw8S3w=;
        b=Kf3DB3tOYDIynqnuoagXah54hP88aPsAuaXLlLoaMByf3SWPCrf/DN4+BNCcnq+Gma
         5s79cqQF7cKZshHC3feSCbTGeohWOcMDa8V9SyVIba5+2Elau6bVY/UaHQC4POgtINB8
         qQ8Nvp2CvfdNpNBo8mWUuMzTh1xDgPwFQcBHeXqWKaCOii5DYKE/ZDAf+EbVqC0y2H+K
         hOmaN3gU9OBW+BVuCcbEmss4nd/Lq6kuzS/ZcYrOv2OdoAJrzP3x5U4GD+ATTAJWfYSy
         eDtFogJeQRva9rY+3FyOy9/XlaFb9FCopSg0v0wul7qj+WJ15fywB9zocjXjtqoDQzOZ
         67Gg==
X-Gm-Message-State: AA+aEWaPZl57zr+t32pRINoaNi1XmCFlRFbN4mEXU8RFC47/DsgXXP0/
        u7lnM84cvmKwlqZZgSDC2h2R9gU0tg==
X-Google-Smtp-Source: AFSGD/VXoI224Db8NldVtvrDS6JDF/Sps5OqLv5SSRGqR8+hVU+zh9hSrsI0mFJzN+ok7PgAFGGg4g==
X-Received: by 2002:a02:1217:: with SMTP id i23mr32642395jad.53.1546525101594;
        Thu, 03 Jan 2019 06:18:21 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id h64sm24472886itb.14.2019.01.03.06.18.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 03 Jan 2019 06:18:21 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     J Bruce Fields <bfields@fieldses.org>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Don't allow compiler optimisation of svc_xprt_release_slot()
Date:   Thu,  3 Jan 2019 09:17:12 -0500
Message-Id: <20190103141712.24381-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Use READ_ONCE() to tell the compiler to not optimse away the read of
xprt->xpt_flags in svc_xprt_release_slot().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/svc_xprt.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 51d36230b6e3..94d344325e22 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -363,9 +363,11 @@ static void svc_xprt_release_slot(struct svc_rqst *rqstp)
 
 static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
 {
-	if (xprt->xpt_flags & ((1<<XPT_CONN)|(1<<XPT_CLOSE)))
+	unsigned long xpt_flags = READ_ONCE(xprt->xpt_flags);
+
+	if (xpt_flags & (BIT(XPT_CONN) | BIT(XPT_CLOSE)))
 		return true;
-	if (xprt->xpt_flags & ((1<<XPT_DATA)|(1<<XPT_DEFERRED))) {
+	if (xpt_flags & (BIT(XPT_DATA) | BIT(XPT_DEFERRED))) {
 		if (xprt->xpt_ops->xpo_has_wspace(xprt) &&
 		    svc_xprt_slots_in_range(xprt))
 			return true;
-- 
2.20.1

