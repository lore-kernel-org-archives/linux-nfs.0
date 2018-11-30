Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7127C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:50:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9AE6A2082F
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:50:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="i8XG9PZk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AE6A2082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726512AbeLAKBP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 05:01:15 -0500
Received: from mail-io1-f66.google.com ([209.85.166.66]:43492 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726474AbeLAKBP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 05:01:15 -0500
Received: by mail-io1-f66.google.com with SMTP id f10so40414iop.10
        for <linux-nfs@vger.kernel.org>; Fri, 30 Nov 2018 14:50:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=JnxyFvxY5NN6SQ0hgqhztaoWxo1cZSXYFICA/458MKw=;
        b=i8XG9PZk+dqSclzSW7pVRlySakEAypvIeRbwOLY0FVZP9ThLzSlZ3tHR2e9I+z7ce6
         cR7oWb8u3VU+Qvm1t/MX8neXdU6ON6bDm2rhhr9eRSdSTE1REaC0TohBUS6PFBxLwXh8
         KBMQZYgG1LeGxF/cQ51rhaVHbsvZG4I+l4U7QGh4Gfk58jl1eMuXmQfzpG4YK62rvuKd
         dG8uQ1HTRkqFq6X1A7ffdPL+3A+BGj8tTzkoKRnU8NXoCB+ChQLBU/jbX1vphuF30vvx
         Xgrrei4bAH9zZX1YJ34oBqRpLrHkmh1B3SyEzMjnEojI+PCvykH7FD1YQoLT9aq8P6OP
         coxg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=JnxyFvxY5NN6SQ0hgqhztaoWxo1cZSXYFICA/458MKw=;
        b=swhSCF2ghhivOYT/vIvAsAoYzb4XNewZG19DV5mI1jOgL3tg7LqBnVtPr8RJjAgUfo
         nAq1J7nZjnla8YCqsrvw1d2YETcS5GUOH+xcSuawZyiNnFISK4PH0UWORRuT2XOlYXva
         PzcTbpe53pm1oZcGerZwT5sGZwF+qfqERDB5OOBKG0xLl23NBO5N92OeSc2WX3UQiYPp
         6WIOb2WRmEH6k12avZOSmmk4N9MSViYT8MEoOwSYUpFM4e822qZJnB7Kdy3R0rVWiw0R
         JN9Gvjd3FpBL8XHOAziY0cGaCEvteAzjvyLeEKwmoLAStTgll7Dn/KwySvdGqFDWJ6um
         Zm0w==
X-Gm-Message-State: AA+aEWYeU4Ra6RXvMd3eA9syWY9Av++OIgius2CizrGNFH+qBEvJ7fM9
        yCMYHi8Z05II5+EudMqhOpq4wBI=
X-Google-Smtp-Source: AFSGD/XkyrBywPHpBjme9ZEcSUJrEIq1cheJr9aQ7EIuTC8sgfwhoIVwXdyNfIUQZDopmh1wI0ZWUA==
X-Received: by 2002:a6b:650e:: with SMTP id z14mr832406iob.285.1543618223702;
        Fri, 30 Nov 2018 14:50:23 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id m8sm39391ioj.73.2018.11.30.14.50.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 30 Nov 2018 14:50:22 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v4 1/3] SUNRPC: call_connect_status() must handle tasks that got transmitted
Date:   Fri, 30 Nov 2018 17:49:14 -0500
Message-Id: <20181130224916.22751-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If a task failed to get the write lock in the call to xprt_connect(), then
it will be queued on xprt->sending. In that case, it is possible for it
to get transmitted before the call to call_connect_status(), in which
case it needs to be handled by call_transmit_status() instead.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index ae3b8145da35..e35d642558e7 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1915,6 +1915,13 @@ call_connect_status(struct rpc_task *task)
 	struct rpc_clnt *clnt = task->tk_client;
 	int status = task->tk_status;
 
+	/* Check if the task was already transmitted */
+	if (!test_bit(RPC_TASK_NEED_XMIT, &task->tk_runstate)) {
+		xprt_end_transmit(task);
+		task->tk_action = call_transmit_status;
+		return;
+	}
+
 	dprint_status(task);
 
 	trace_rpc_connect_status(task);
-- 
2.19.2

