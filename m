Return-Path: <SRS0=lZg6=VN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98DF3C7618F
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Jul 2019 20:06:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6C72C2145D
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Jul 2019 20:06:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="U3KWzp9P"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728484AbfGPUGm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Jul 2019 16:06:42 -0400
Received: from mail-io1-f65.google.com ([209.85.166.65]:35845 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728366AbfGPUGm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jul 2019 16:06:42 -0400
Received: by mail-io1-f65.google.com with SMTP id o9so42082266iom.3
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jul 2019 13:06:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=YpPNBtxxgX1u7wA3w0OrLT613m/T+xFEVWs19Z5CKHg=;
        b=U3KWzp9PeA/RDLZ2yZZTDu4dydzGsIijc/hCFJve3SJ7O7T+ih1wNYGIsnvF+08qEg
         cEtwTmdEneH/gyNve9FQXNC5XLPAa0NAIqqv4CLYZXzm0bMYi5yIz9Mtslzx3fYxtV/s
         6fpFAJLjHCZ0BhmiHj88sCnmPvuthm3JGOWPaDNRVUP4zKbQsfJgtGiZ6WNOmQSvCWJV
         2Y8TImA7lRby56JggxpHR+8e1gsILWvGUUIYXtcVUCcrNlRrsD6HNtx5pwdxyFsFGXBH
         rqRApdgDsuqCIRhTMYnqIVJ7aQtHLqcJwz0jb46TpEkoG+eF9gzYrbSExkh41st2P9gw
         nsag==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=YpPNBtxxgX1u7wA3w0OrLT613m/T+xFEVWs19Z5CKHg=;
        b=unib7PI2hk73Y7/T8E0uRB0ram13I5UbHHgFJTMr05otaxDuWzzCp3hhKFLxNbXCHK
         uIISMJXzAkB37Wd8OyaCbVQnNmN2FMpjkRAeHRmwSk0ZmkWkg779c3nMaoHKjPa7QYer
         0myAVhpMSx7Z6dHu21txQ2EJfZrHu5I7O6Fkw3NToXh36sOam+A0Jq9YtH738a/T2BAp
         Y+JfeFgPnPCimiUuCKFoT/b4K+Y0B/p8cda+gFZ67HeKlS+tYcdTE/J9uFBEW3nzAUvE
         9yu6X1OyJejXDVDXhceSbHmOgZA35vmY5ke436r6/rn5EUv2FK1hpkGroIQby3NFrF6P
         gOQQ==
X-Gm-Message-State: APjAAAUQOYGPyIR/QvF/pR0JQStzZGyB756oc+ca8DiKjmMRPJcz37rb
        h2t7pnwcCDDRf5YVdvlYQrZchAI=
X-Google-Smtp-Source: APXvYqzwSZHNbkK0d5g2NTS5U9Yeb6yNuT31NeLsw3qmXMKwrLMm1L7KBHhbqeZK7Q9b0ztvZqurZw==
X-Received: by 2002:a5e:881a:: with SMTP id l26mr8772513ioj.185.1563307601267;
        Tue, 16 Jul 2019 13:06:41 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id i3sm18393763ion.9.2019.07.16.13.06.40
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 16 Jul 2019 13:06:40 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] SUNRPC: Replace division by multiplication in calculation of queue length
Date:   Tue, 16 Jul 2019 16:04:31 -0400
Message-Id: <20190716200433.38758-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When checking whether or not a particular xprt queue length is shorter
than the average queue length for all xprts, prefer to use multiplication
rather than division for performance reasons.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtmultipath.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtmultipath.c b/net/sunrpc/xprtmultipath.c
index 9d66ce53355d..5df4e7adedf0 100644
--- a/net/sunrpc/xprtmultipath.c
+++ b/net/sunrpc/xprtmultipath.c
@@ -322,7 +322,6 @@ struct rpc_xprt *xprt_iter_next_entry_roundrobin(struct rpc_xprt_iter *xpi)
 	struct rpc_xprt *xprt;
 	unsigned long xprt_queuelen;
 	unsigned long xps_queuelen;
-	unsigned long xps_avglen;
 
 	do {
 		xprt = xprt_iter_next_entry_multiple(xpi,
@@ -333,8 +332,8 @@ struct rpc_xprt *xprt_iter_next_entry_roundrobin(struct rpc_xprt_iter *xpi)
 		if (xprt_queuelen <= 2)
 			break;
 		xps_queuelen = atomic_long_read(&xps->xps_queuelen);
-		xps_avglen = DIV_ROUND_UP(xps_queuelen, xps->xps_nactive);
-	} while (xprt_queuelen > xps_avglen);
+		/* Exit loop if xprt_queuelen <= average queue length */
+	} while (xprt_queuelen * READ_ONCE(xps->xps_nactive) > xps_queuelen);
 	return xprt;
 }
 
-- 
2.21.0

