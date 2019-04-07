Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC34AC282DE
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8345120896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FKlxIiQm"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726438AbfDGSBe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:34 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:38899 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726415AbfDGSBd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:33 -0400
Received: by mail-it1-f194.google.com with SMTP id f22so17364063ita.3
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=YiggeHe5Ur0/gP4LNTHnltg0CL5XFAPcOjWyE4a6Zn4=;
        b=FKlxIiQmhc+4TsRbit3oqEk/cImfhG7E1rC0bmZdCisHMMSFitAXe8rxBCwEr5fa19
         hXSakTQkUaFFaFqbe35S30HG5i7oRhWx9RklEMmEUjVeJvD1J7d8mQPgstGxiL8CEDtO
         NHaMNuT1cRY6uJbk0kOC/nmJQyr87OICbDEt9Sj7qPoSgmtwi76Y+G0K6gmgV6wH/mTh
         JE+mq7ynNCRPcyPeYoHLaQjOIMHQUNq8qYs30n7fAvHV3IxdaG9XaA5wvzY1vXB/wHmZ
         ENYrHk2DhdHsuiBAjIrU/fE3Pf/XqrSdkpTMhGUjJMsLb1Z7YsFuZ5FOzszU4+cdeoCh
         9QyA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=YiggeHe5Ur0/gP4LNTHnltg0CL5XFAPcOjWyE4a6Zn4=;
        b=PwIRWh9chNKdRLeSMjL7LZvcqSIKYh4DlaPVAmSE1NqVuw97g0xwNEFmdJw56puQz7
         3VG1Y3bbrfQBYCHOy2cqMfk/kGIEIWdQL7FreEFmHvu8O3ye6fS3MGEz/oGLUp78wCty
         5y2yCgJtml7qb7WkHpWkA+5WzzYPwtQInqv0mfGNZUBs07Y0zt4rZZoGiWRl624IwbOq
         TscNpbvPK/uNOC3lauLRPK2J4/Wyem3nSo0erVHhQyID5q2dYZtylywiNwkIsBLKbN/j
         pyG3BxvKbwqPJBTUHD9UbrUshyrtt+s1vMA2ppBEKiBPmEZtknGKf7n+heAQS/ogJrA3
         9pbw==
X-Gm-Message-State: APjAAAUksFLUwkvrlUWS6MES10cpw/E2t2+0S3CUcGqxnOjP+GqNxiXq
        zEjUqbuaiq0ONoVPp7ALVg==
X-Google-Smtp-Source: APXvYqwlviSHxauAq8iWlqRjsMFwaDtAiqDcsaqEOLS5X1CQl19T3+PBTVm/12a2oog0jnO9Y8zhig==
X-Received: by 2002:a24:ac56:: with SMTP id m22mr14332671iti.25.1554660092518;
        Sun, 07 Apr 2019 11:01:32 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:31 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 12/29] SUNRPC: Make "no retrans timeout" soft tasks behave like softconn for timeouts
Date:   Sun,  7 Apr 2019 13:58:55 -0400
Message-Id: <20190407175912.23528-13-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-12-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
 <20190407175912.23528-2-trond.myklebust@hammerspace.com>
 <20190407175912.23528-3-trond.myklebust@hammerspace.com>
 <20190407175912.23528-4-trond.myklebust@hammerspace.com>
 <20190407175912.23528-5-trond.myklebust@hammerspace.com>
 <20190407175912.23528-6-trond.myklebust@hammerspace.com>
 <20190407175912.23528-7-trond.myklebust@hammerspace.com>
 <20190407175912.23528-8-trond.myklebust@hammerspace.com>
 <20190407175912.23528-9-trond.myklebust@hammerspace.com>
 <20190407175912.23528-10-trond.myklebust@hammerspace.com>
 <20190407175912.23528-11-trond.myklebust@hammerspace.com>
 <20190407175912.23528-12-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If a soft NFSv4 request is sent, then we don't need it to time out unless
the connection breaks. The reason is that as long as the connection is
unbroken, the protocol states that the server is not allowed to drop the
request.  IOW: as long as the connection remains unbroken, the client may
assume that all transmitted RPC requests are being processed by the server,
and that retransmissions and timeouts of those requests are unwarranted.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a9e5e81c67be..c921a5aff790 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2344,6 +2344,15 @@ rpc_check_timeout(struct rpc_task *task)
 	}
 
 	if (RPC_IS_SOFT(task)) {
+		/*
+		 * Once a "no retrans timeout" soft tasks (a.k.a NFSv4) has
+		 * been sent, it should time out only if the transport
+		 * connection gets terminally broken.
+		 */
+		if ((task->tk_flags & RPC_TASK_NO_RETRANS_TIMEOUT) &&
+		    rpc_check_connected(task->tk_rqstp))
+			return;
+
 		if (clnt->cl_chatty) {
 			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
 				clnt->cl_program->name,
-- 
2.20.1

