Return-Path: <SRS0=F8lJ=ZS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 749F0C432C0
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Nov 2019 22:29:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2F9EB2071E
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Nov 2019 22:29:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="CVIhaKl0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726299AbfKZW35 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Nov 2019 17:29:57 -0500
Received: from mail-wm1-f68.google.com ([209.85.128.68]:37910 "EHLO
        mail-wm1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726077AbfKZW35 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Nov 2019 17:29:57 -0500
Received: by mail-wm1-f68.google.com with SMTP id z19so5224324wmk.3;
        Tue, 26 Nov 2019 14:29:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=X7czqVkoEYLu9jchLgLJsSf45+1ymW0TAtTYsnS8aYU=;
        b=CVIhaKl0iHduS/t0BNo95kQzNUtwxq+/gkJLbDkmY+pwSmXs1NikyN77bwlxkk8TZk
         3bdQUk+xGrOio7HmRmjVrYyEjkqubfsYYOJwLM8C7lGwGptP8Jjn9jXIm7t1OZJT0szq
         Qk2neAbTpXRc5vyOHbKKyn2OOwMADpkLcgrkEffaUTm2dMmjsls4B6M/VSvAlmx1/smL
         VTD2aDz4jjCFN48lqDlGr38Yylyj/p/o9IKK965vQOg7VX3JIvR5dBltSkn1X4rToYSd
         pAFqDW0uM/6EfixBEBAwpvis6SRNAw3Z4tNhDy5I4Ys/cgdnrLf0RT9X0iESjcluWlnB
         IgFw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=X7czqVkoEYLu9jchLgLJsSf45+1ymW0TAtTYsnS8aYU=;
        b=uYwiDVEf6QaSIEFa07lj7ItEj+/NtWimiaBVdDKSibvm0yOrNJ1p9ye2hgZj/VsxEe
         OKW9+Q7A8iJWl5yD6qL5Ma7c6w5YC5K6FLu94nux93GCngDYxY/uU01F86Tv2K5vYcbR
         smLhX/lePAPXUAmV+sHZJtRGweOa5CVdmOTor3oVFrzRMf0zSB7E9h6m2kAAe+prn6Tm
         CrlSBs6nUTdMnTeS6XJ5UtFE0XfjKGfhV3iPbt4z20r7X2QSG24Wko1NZEtPovXO3NfJ
         MJcegjPxLgtpcC8kHcDKQZNfRlkpLS7QnpdYhtiOvaMHaAZckETh1aDxuGPPZoUPys/l
         mFeg==
X-Gm-Message-State: APjAAAUfgQXPUWRDkS/Nfcl/Q5QugD/+II4MxMh5GcRrrlP/d6E7Deai
        RyrHKR8BIlOFguk7B/GpwA==
X-Google-Smtp-Source: APXvYqxxBSlaqlxnBi8WEE6JSO6okLXpB6pWy9shLPWdKPb5FRBeMabeozGolJ5MG6tpKcIG0G2Jtw==
X-Received: by 2002:a7b:c44c:: with SMTP id l12mr1113151wmi.71.1574807394912;
        Tue, 26 Nov 2019 14:29:54 -0800 (PST)
Received: from ninjahub.lan (host-2-102-12-67.as13285.net. [2.102.12.67])
        by smtp.googlemail.com with ESMTPSA id d14sm3491148wru.9.2019.11.26.14.29.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 26 Nov 2019 14:29:54 -0800 (PST)
From:   Jules Irenge <jbi.octave@gmail.com>
To:     bfields@fieldses.org
Cc:     joe@perches.com, chuck.lever@oracle.com,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        davem@davemloft.net, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jules Irenge <jbi.octave@gmail.com>
Subject: [PATCH] net: sunrpc: remove 0
Date:   Tue, 26 Nov 2019 22:29:36 +0000
Message-Id: <20191126222936.172873-1-jbi.octave@gmail.com>
X-Mailer: git-send-email 2.23.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Remove 0 to fix warning detected  by sparse tool.
Using plain integer as NULL pointer.

Signed-off-by: Jules Irenge <jbi.octave@gmail.com>
---
 net/sunrpc/xprtsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 70e52f567b2a..f90323dfc548 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -614,7 +614,7 @@ xs_read_stream_reply(struct sock_xprt *transport, struct msghdr *msg, int flags)
 static ssize_t
 xs_read_stream(struct sock_xprt *transport, int flags)
 {
-	struct msghdr msg = { 0 };
+	struct msghdr msg = {};
 	size_t want, read = 0;
 	ssize_t ret = 0;
 
-- 
2.23.0

