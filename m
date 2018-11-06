Return-Path: <SRS0=ZVvz=NR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 928B7C32789
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 07:41:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4D72E20827
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 07:41:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NGAaCm8w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D72E20827
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729021AbeKFRFQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 6 Nov 2018 12:05:16 -0500
Received: from mail-vk1-f194.google.com ([209.85.221.194]:46304 "EHLO
        mail-vk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726863AbeKFRFQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Nov 2018 12:05:16 -0500
Received: by mail-vk1-f194.google.com with SMTP id 185so2639378vkv.13
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2018 23:41:21 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=message-id:date:from:to:subject:mime-version:content-disposition;
        bh=USpk16/hgQY2QW07FjMrjuRp9Xt0It09e1n7CF9yBg0=;
        b=NGAaCm8wSEE72ptPDAdg1sNNT8vSPpgLX0YKURuNvUP7qavNAdKxR28m97qvEijpPA
         veX21k7dFSZmqM/3nBvEVG4Mpinzx1YwGczmUuA8gocCZJZC2VSvZlXrMlpRP9b6PAyQ
         hC4p/LQvJRmVLBbyMh/obBEiLkyt5mtI1JaEfEEsTTQAen+XTUS3umxK8lHf5BFCXQm0
         U47PAMVR+4rEIT2zbkRKURdxsjc69WhLjU6fFfEieEt8L6k/ZKfHrMEGONKu9wEdGo+H
         H5D/ZxSb4CsGEXaqmR4woPCrZkrpYx0p7Q4EXr7TNkyvPGPai877Hk6c4jZ9EVUNajyj
         0tqQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:date:from:to:subject:mime-version
         :content-disposition;
        bh=USpk16/hgQY2QW07FjMrjuRp9Xt0It09e1n7CF9yBg0=;
        b=Dn2e6d9vPswRl1a2EITwdmocr0CgX9srEBhMGUmq1b7qK8FaG/C0lHHI7cwFbpq2oL
         SfBzaNA42u2+tuRX98O6jVKQ6JRvaupG9spsxzAj/xElLMcGLHiUXzV0oFLnOIii0EvR
         r+Jdt1zc0I3HM673CTnRH24g345GB2FUO2KC2fJV1XPR3aXj2My80onh+inX/BT6qxQg
         U7h3c6Nh2Ty02p09vQ7IfbyDifRK8bXfbtvwjDAqer+6Xjf+SafIFs/HWG91nmZMZ60z
         JhNkRcg0CT7TgpeveYerNq95oUPX5eqvfLb43uxeEEFzCaSj8eR8dLbH7nRow5D/smG8
         pXmw==
X-Gm-Message-State: AGRZ1gLucZ3OXf8Ley75L2eMoDmAWLyIbkovwOXlykHXmtZqSedQNIru
        sF/PJK0Xwf2oa8gYTv3YAgTA3Odz
X-Google-Smtp-Source: AJdET5ejahiPRdeTipSAZi4HERCSYoHQOOoLvUdn0we2bBDq6O3yB0f5fzF3KdVYILdJYCkHpGirnA==
X-Received: by 2002:a1f:b406:: with SMTP id d6mr10520853vkf.63.1541490081163;
        Mon, 05 Nov 2018 23:41:21 -0800 (PST)
Received: from localhost ([207.246.116.136])
        by smtp.gmail.com with ESMTPSA id k22-v6sm12679340vkk.29.2018.11.05.23.41.17
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 23:41:20 -0800 (PST)
Message-ID: <5be145a0.1c69fb81.9f722.e02a@mx.google.com>
Date:   Mon, 05 Nov 2018 23:41:20 -0800 (PST)
From:   Yang Bo <phoooyb@gmail.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfs-utils: configure.ac: Fix --with-rpcgen=internal
 nottaking effect.
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Yang Bo <rslovers@yandex.com>
---
 configure.ac | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/configure.ac b/configure.ac
index cf1c4b9..3caeebc 100644
--- a/configure.ac
+++ b/configure.ac
@@ -155,6 +155,8 @@ AC_ARG_WITH(rpcgen,
 	    do if test -f $p ; then RPCGEN_PATH=$p ; break; fi ; done
 	elif test "$rpcgen_path" != "internal"; then
 	    RPCGEN_PATH=$rpcgen_path
+	else
+	    RPCGEN_PATH=internal
 	fi
 	AC_SUBST(RPCGEN_PATH)
 	AM_CONDITIONAL(CONFIG_RPCGEN, [test "$RPCGEN_PATH" = "internal"])
-- 
2.16.3

