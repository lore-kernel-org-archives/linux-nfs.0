Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4EF3FC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:23:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1E6E32147A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:23:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H46O0eTg"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726342AbfBSQXN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 11:23:13 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:54450 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728216AbfBSQXN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 11:23:13 -0500
Received: by mail-it1-f194.google.com with SMTP id f10so7373192ita.4
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 08:23:12 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jT74WFfrDl/+VabIgj0qfMzVGMbohB+BWe9aCCdqkGw=;
        b=H46O0eTg1r26hB/ZZesRqfRx4kcri6r2pamAKrc82lma3EXS1fsW9VdK4a1EibQ2kt
         lCAbJ1N0GUu5iFTSoIghnfAgkeGXR3f7Tv9oGgupvB2oUg8Fsv9eF8e6VVSA9ldkcoEs
         NMxhIbStZ+zMb9POJ7Z461oqYFZrmDMGAtCZxh7M6XLZYzbiJx99hSHwuEYAXZ/OBY/k
         jf4K9RjO1AzHQnZiQ0Mu9YusmjRKsHP4VVJt1Fx5JwfgPjHuJpFG3m8TC/equ1jxrAXR
         ATixfULH25TCINXyqTsTRwCxc6ohivAj3DyqqS4TErmqHCY/22C0h2yN45xtvSwEdWEQ
         GadA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=jT74WFfrDl/+VabIgj0qfMzVGMbohB+BWe9aCCdqkGw=;
        b=F6T28H+0BgWtksIWNhAfvrsZ5dDQi5vQ46RO022OChnJjl8RdLTVqKub+70yhYXd6H
         S7sZPXSREPZKdIbnpB4Jzut3HS/TTbm3qA3OIkaeid9fDKFiTZRphDXJGOl4Utm33Meq
         iDQIfcne8YoNiNMELFWsb/epSb+7qQI3fXmUBRv82cxpj3r9OQpo7FuunnX+AZ1TI0vJ
         8iuY7RAmGF+V30uNlb2uVbiW6FmtPaMb9ChZScAfHDvhgYtc7hXa8ErplecdtQumbHc6
         m/vCDnDJgbYEhoGupqPFqAd7l7qvxK93rUJjDC1Kf5eiqzO6hrH/s1TGCzu8UWrqcF7m
         FpTA==
X-Gm-Message-State: AHQUAua+9EJl4KCMrIUA2khvHSZx/DGzyCiSSAeCLbr9KNDOHCsdrZhh
        XFHif/oVyyh+z/xS/GiHx56D7ZE=
X-Google-Smtp-Source: AHgI3IYACqAY8MAve28SmEIU4aRYj01BxmKjoel/h0b5oQKnLMKsjCxoGmU4WpZ+PbuoKMevqA6vSg==
X-Received: by 2002:a02:c60b:: with SMTP id i11mr16091337jan.118.1550593392048;
        Tue, 19 Feb 2019 08:23:12 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id o9sm882683itb.23.2019.02.19.08.23.11
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 08:23:11 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] SUNRPC: Initiate a connection close on an ESHUTDOWN error in stream receive
Date:   Tue, 19 Feb 2019 11:22:02 -0500
Message-Id: <20190219162202.68013-3-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190219162202.68013-2-trond.myklebust@hammerspace.com>
References: <20190219162202.68013-1-trond.myklebust@hammerspace.com>
 <20190219162202.68013-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the client stream receive code receives an ESHUTDOWN error either
because the server closed the connection, or because it sent a
callback which cannot be processed, then we should shut down
the connection.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtsock.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 89bcab53848a..618e9c255a9f 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -694,7 +694,10 @@ static void xs_stream_data_receive(struct sock_xprt *transport)
 		read += ret;
 		cond_resched();
 	}
-	xs_poll_check_readable(transport);
+	if (ret == -ESHUTDOWN)
+		kernel_sock_shutdown(transport->sock, SHUT_RDWR);
+	else
+		xs_poll_check_readable(transport);
 out:
 	mutex_unlock(&transport->recv_mutex);
 	trace_xs_stream_read_data(&transport->xprt, ret, read);
-- 
2.20.1

