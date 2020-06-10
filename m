Return-Path: <SRS0=S27I=7X=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09F31C433E0
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Jun 2020 16:04:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C3E0D206F4
	for <linux-nfs@archiver.kernel.org>; Wed, 10 Jun 2020 16:04:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Fx/ie+rj"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727792AbgFJQEj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 10 Jun 2020 12:04:39 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50186 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726219AbgFJQEj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Jun 2020 12:04:39 -0400
Received: from mail-wr1-x443.google.com (mail-wr1-x443.google.com [IPv6:2a00:1450:4864:20::443])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5B5D8C03E96B
        for <linux-nfs@vger.kernel.org>; Wed, 10 Jun 2020 09:04:38 -0700 (PDT)
Received: by mail-wr1-x443.google.com with SMTP id c3so2869537wru.12
        for <linux-nfs@vger.kernel.org>; Wed, 10 Jun 2020 09:04:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding:thread-index:content-language;
        bh=U3gilqkSSg9/GruhlyooX35HbX1bGO2bAhpjE1WjnFM=;
        b=Fx/ie+rjMGzQkaJdkIe+DPMYdkGpDHYMLNxXcUoxhCn7RkytqjXPy9U5u1Wr3qJTm2
         WnekBwvkxOhMc02ucnx3XMxpSudZH34u3gf0Vk78Zin2tMCsw7iXU4wyxmiSPqn9NTns
         JUlkIzXXGhMNKSeA380iwqBcQkLSPKXRIgBYw4kwqA0eBaiB8EMPGyVLiud+mCyFqdrh
         erFm1N4IUy18eSdXQIV1VUc9efuvEaegurPHbm7+X0yYsNgxTb4PEKsrmqbo5iGKTZmF
         acCl557i3+LyCWBU2haqIAJGqg6YrXtsos8Z/qpoLrluV4XVDDf7DCZ7dFYlSSuCexGT
         mI5Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding:thread-index:content-language;
        bh=U3gilqkSSg9/GruhlyooX35HbX1bGO2bAhpjE1WjnFM=;
        b=LiCVkLZyz4pEyQLogMu2FwYAKtFchv6k6Ud+oS68I1Yeg2/PnnamX+myKjrp6SXqMu
         xfOr6l27QuUMtR+NnokDoA11uapRgVvlhnYrt508eK60+hTPOJEG4+M9W3Nt5kXXbid3
         lmGUbuURugssoAq82B2b2H576ysTx4wrb9klZwixSm3MJxkLe0kK5IPOBptgvkUaG8zU
         htEmCurrA6BqWDc7kBnIG0vptYe8uvq9Aj4dL5C9lqO5tfnCwDrpVRpT37FDrr87lICA
         N0JWbq4F9HKNOEXi7xkuzlOJ3JzMW4Gcig82midtkZqLato5FpfENp0SqjZtSyxXzkw8
         r1Hg==
X-Gm-Message-State: AOAM531Xc3cJ6w/0uH4MzBmTpW3dr4R4xnFyhJIz4IxKkmaTwhes4/ew
        DqxawnwhTMcESObhPCz+BG5QryioW2w=
X-Google-Smtp-Source: ABdhPJyQddUAcq3s9pceXL7z2GB4FJ5xm8jKnP0fcVUhchVjm6rMPR/nrqJYg9hV4raDWJ3W0sQ2xg==
X-Received: by 2002:a5d:6305:: with SMTP id i5mr4436783wru.268.1591805076578;
        Wed, 10 Jun 2020 09:04:36 -0700 (PDT)
Received: from WINDOWSSS5SP16 (cpc96954-walt26-2-0-cust383.13-2.cable.virginm.net. [82.31.89.128])
        by smtp.gmail.com with ESMTPSA id h29sm350245wrc.78.2020.06.10.09.04.35
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2020 09:04:35 -0700 (PDT)
From:   "Robert Milkowski" <rmilkowski@gmail.com>
To:     <linux-nfs@vger.kernel.org>
Subject: [PATCH] man: Correct rpc.gssd(8) description of rpc-timeout and context-timeout
Date:   Wed, 10 Jun 2020 17:04:33 +0100
Message-ID: <118701d63f40$d538e1e0$7faaa5a0$@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Mailer: Microsoft Outlook 16.0
Thread-Index: AdY/QIjZzX4gsNo4StSKyM6pCZ1Vrw==
Content-Language: en-gb
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Robert Milkowski <rmilkowski@gmail.com>

The rpc-timeout is equivalent to -T and context-timeout to -t options,
not vice versa.

Signed-off-by: Robert Milkowski <rmilkowski@gmail.com>
---
 utils/gssd/gssd.man | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 3ec286b..26095a8 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -322,11 +322,11 @@ Equivalent to
 .TP
 .B context-timeout
 Equivalent to
-.BR -T .
+.BR -t .
 .TP
 .B rpc-timeout
 Equivalent to
-.BR -t .
+.BR -T .
 .TP
 .B keytab-file
 Equivalent to
-- 
1.8.3.1


