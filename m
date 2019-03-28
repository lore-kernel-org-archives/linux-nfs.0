Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9081EC4360F
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5FF3121850
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RYeSRdl3"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726248AbfC1U4V (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:21 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:40012 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726410AbfC1U4V (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:21 -0400
Received: by mail-it1-f193.google.com with SMTP id y63so461120itb.5
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=b6G+C8SO9TL5MeUKf+3KSVuLgQ+ThPmE5k1NYTZSeVo=;
        b=RYeSRdl3tU1kuyCQaXjuZ90P8Uu9uKG8v/O7Lo5UiOCXJjibTR2n6aJyGm5WMpzhNK
         DrYe3VP151IUAJ/sWlGv1sjX+jEL3CvF4iWks95XWbkVE2DVcdohZa/lXbGxdQgmMZA3
         3jG0VNwjH7f1zgs1maLJIjbRveAg21EUMPbEQZfnhOlmmtUuAR1hxYUCy+bYsmEWAonA
         to86HPffv17e/R8cODwtSbYlBEliSqCpMtymEg1WT+991CfBEY/tQB7d40WebK17SWDU
         ZbkaimJzxXTEmJGM70hrJttru75QiRmJK98zmrsjy58LTjv6hKrMALA7BYVEvaqJCdCr
         ct3g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=b6G+C8SO9TL5MeUKf+3KSVuLgQ+ThPmE5k1NYTZSeVo=;
        b=EF2OZAyzrjyKBpYzFqb1zRpwCBVbVSf7Jc/NPRTDxmne9qoIiHd549Dy03a1kwEVez
         ZUmWCKODtcZDRja2VaLqLXaRPRHDwCZj3LwodF3XGvA3TfCjbVTCOurpSff5CB9AInwJ
         yWBpkL8v1YF8RgqkJsSEoxZHWlgsIGh4l1X4m7IN8kGJC6bOSu5aV6hezBSqD1CdsUH4
         7ZaWKRgsxz0nVFu1ucCKF9m23I8oMIer41omhaeWftYFAdXV5CF/ogakuxGBdr0rN9vf
         r5GcB9/x6VxHQ1dSTZ/vR5tXM2MI+lbZiVyfx7lVJt9ucxREjTwl1ujahueAoPMCXGvm
         /fRQ==
X-Gm-Message-State: APjAAAVHyHsbpfQzl9IrNvRwYBWEG63vy4KHsGTL8eywGhTDFyRmrOrg
        3wNVHmPfjxevHmKiF+dxqAMih+I=
X-Google-Smtp-Source: APXvYqyei6KAxwwblhDYUPZrMWeLOG1ol44iLNg9rPeAc1Dbumjzhcr6hwhO2mqD/FIVrGp7OPD0jw==
X-Received: by 2002:a24:35d4:: with SMTP id k203mr1755628ita.89.1553806580149;
        Thu, 28 Mar 2019 13:56:20 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.19
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:19 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 13/25] NFS: Consider ETIMEDOUT to be a fatal error
Date:   Thu, 28 Mar 2019 16:52:27 -0400
Message-Id: <20190328205239.29674-14-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-13-trond.myklebust@hammerspace.com>
References: <20190328205239.29674-1-trond.myklebust@hammerspace.com>
 <20190328205239.29674-2-trond.myklebust@hammerspace.com>
 <20190328205239.29674-3-trond.myklebust@hammerspace.com>
 <20190328205239.29674-4-trond.myklebust@hammerspace.com>
 <20190328205239.29674-5-trond.myklebust@hammerspace.com>
 <20190328205239.29674-6-trond.myklebust@hammerspace.com>
 <20190328205239.29674-7-trond.myklebust@hammerspace.com>
 <20190328205239.29674-8-trond.myklebust@hammerspace.com>
 <20190328205239.29674-9-trond.myklebust@hammerspace.com>
 <20190328205239.29674-10-trond.myklebust@hammerspace.com>
 <20190328205239.29674-11-trond.myklebust@hammerspace.com>
 <20190328205239.29674-12-trond.myklebust@hammerspace.com>
 <20190328205239.29674-13-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When we introduce the 'softerr' mount option, we will see the RPC
layer returning ETIMEDOUT errors if the server is unresponsive. We
want to consider those errors to be fatal on par with the EIO errors
that are returned by ordinary 'soft' timeouts..

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/internal.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c7cf23ae6597..3cefd0ed01be 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -766,6 +766,7 @@ static inline bool nfs_error_is_fatal(int err)
 	case -ESTALE:
 	case -E2BIG:
 	case -ENOMEM:
+	case -ETIMEDOUT:
 		return true;
 	default:
 		return false;
-- 
2.20.1

