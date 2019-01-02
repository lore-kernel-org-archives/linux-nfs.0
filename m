Return-Path: <SRS0=5e7g=PK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44014C43387
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 22:54:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1009720879
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 22:54:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jph52i6h"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729991AbfABWyZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 17:54:25 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:40563 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729990AbfABWyY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jan 2019 17:54:24 -0500
Received: by mail-it1-f196.google.com with SMTP id h193so40634985ita.5
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jan 2019 14:54:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Qt0q9Hn+zH64pXxPLhc0X06mrmxhIcYsC/4IHHsTpUo=;
        b=jph52i6hBvEo1nbaxjuUQD+iaNtRG36AkZVpeo8+wKFVT62/iZciz/dfa0bMF8zonk
         XiQIu/YF6KEJISrTUHbJvemTX8WxXDj7XDogItsgf6hdiy8+jfMLLCqHpKlWhfwcACcX
         UgUOOynNbkwnC4UEL+VaaJonvpq2PURZPV4iuhLqHsR2xIpMgAwq1TpSvIBP+6IDu90r
         /LpRzCo3NwD9XgCIq89Pe3bEauBdxSA1S8wq0EsCi4F0N0K4RBA5ORNuBPx2zhCwdbV4
         987QXSfWaJa6Q3c65gsgqH2v+cRoSFDeWBVxIX8Y/1A4ITyWe6HdnCmgDGShP1ViwQan
         a1kw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Qt0q9Hn+zH64pXxPLhc0X06mrmxhIcYsC/4IHHsTpUo=;
        b=BLp/ENF1a95Tm0HQ51Mg1b/F+bHjHYq9mo9cWD1sJa6yhmpCoVjbxBOm7+ueBAEWwB
         BRn0U56D0kR2Y6vOirJHjOVuH7UiKYUK+69xbXDY2+fFObjQJBrHNMItAI2LpqsHMiAj
         dIj+1VvVTWHWmN2RoQD73zOvVfMXTQOvujRHK1tZgjgVH+r108FrMe2nhDwCAa6ENDY9
         eITSfjZVc0eWkKljyRV/PGa0yVaIwiUb6mcLvTFTU3bW2/oCbL+vOTLAX64eiqia15XJ
         cl9MapsQXl01EcwFe9LPqxsUdQOJVKkIT2lvZ726pIdL5Sh4JO6CU5tk3ziHTKZmaddf
         eo7g==
X-Gm-Message-State: AJcUukfdIgaltkhdcoJTM4QhrTpDRofMVvLOKwYHMEKjmf7XUhsDub2C
        7RMnNQPgqRmu+8sk4ZCXsWOlYQ3SGg==
X-Google-Smtp-Source: AFSGD/VTNSJLgYU4UWpVZME7b+DSE8Z4x0vEoPmRm4cqbhBbYK1l+znbvyCeVs2qjleNABK4OufMkQ==
X-Received: by 2002:a24:2c50:: with SMTP id i77mr26056332iti.131.1546469663470;
        Wed, 02 Jan 2019 14:54:23 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id d3sm23036154itc.40.2019.01.02.14.54.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 Jan 2019 14:54:22 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 3/4] SUNRPC: Allow for some re-ordering of RPCSEC_GSS requests on the server
Date:   Wed,  2 Jan 2019 17:53:12 -0500
Message-Id: <20190102225313.2097-4-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190102225313.2097-3-trond.myklebust@hammerspace.com>
References: <20190102225313.2097-1-trond.myklebust@hammerspace.com>
 <20190102225313.2097-2-trond.myklebust@hammerspace.com>
 <20190102225313.2097-3-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Strictly speaking, the client is probably not supposed to transmit more
requests than are allowed for in the RPCSEC_GSS window. However since
we do, try to ensure that we allow for some re-ordering by the server.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index ba765473d1f0..dc7124d45c8a 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -2029,9 +2029,6 @@ gss_xmit_need_reencode(struct rpc_task *task)
 	if (!ctx)
 		return true;
 
-	if (gss_seq_is_newer(req->rq_seqno, READ_ONCE(ctx->gc_seq)))
-		goto out;
-
 	seq_xmit = READ_ONCE(ctx->gc_seq_xmit);
 	while (gss_seq_is_newer(req->rq_seqno, seq_xmit)) {
 		u32 tmp = seq_xmit;
@@ -2043,7 +2040,12 @@ gss_xmit_need_reencode(struct rpc_task *task)
 		}
 	}
 
-	win = ctx->gc_win;
+	/*
+	 * Ensure the request is within 3/4 of the RPCSEC_GSS sequence
+	 * window so that we allow for some re-ordering of the requests
+	 * by the server.
+	 */
+	win = 3 * ((ctx->gc_win + 3) >> 2);
 	if (win > 0)
 		ret = !gss_seq_is_newer(req->rq_seqno, seq_xmit - win);
 out:
-- 
2.20.1

