Return-Path: <SRS0=azWf=RW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A810C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 17:15:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6AB2D20863
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 17:15:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jxDuxXmy"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727079AbfCSRPj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Mar 2019 13:15:39 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:46204 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726860AbfCSRPi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2019 13:15:38 -0400
Received: by mail-io1-f66.google.com with SMTP id b9so11833178iot.13
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2019 10:15:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=eOqzmisCZduk2q6lqwzXXWvuof4zc7lk98TpYsn4SNE=;
        b=jxDuxXmyMOkEkH/BgYioIZYcdwc87MMg/WG6vrCJ/RFD6F4fTZGIofP1TYfZ00CqDz
         LbtksdeywkQdP1EnkPwmONPq9k/ZckuKxpQp9m29TRyzS3wrWgUihPyr3ym3ozzfQMup
         KwKDXw8UpmnR3oS5FZhbsQ+ZhK/fT2LxHRsPFXsTuroU/DPv/zLxxChg84Pr2pOzf8/O
         iJv/pzA3bPBxrAqx1BGqs4H1CyCgJxSHLVdO8vfmgC9cVTXOJuGPJCqq5Zq30UUmBYHD
         MpEOT+ceRe1A6gF0zEIsuT9uWGZ1+sAYdpP1M6IAZNbIAmVOXFXOUUqlUS9VkEmDyueX
         u9Kw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=eOqzmisCZduk2q6lqwzXXWvuof4zc7lk98TpYsn4SNE=;
        b=Rztb5gzZiDmsMf+ATjzttkV9qnFIICzVLRWkIbkzA23ibDbRnHVuUWC4MtPZcYPlWX
         fl/PSGNQpq553M2IteBqCmT7W30xD1vYvmUwuXm7fciwcZwV/Aryd1Pi3IPCjVTZqgtV
         jgojLU0A3ovQdk8J3W1y1peek8wfRF+60veujYlIyjBkJwD2RQl/LJRpxUoD4RdxUYan
         zgwZfk3JaSAoPJKfJOC8qE4H32REX4bcnuQnrV2OINKKC1K+hX0ChUJ6/KtVBvpJNpo/
         kyYYr187jrJ8ilp2lvFCADA5T2uu+K69QpZ3n64A9MF1Rcje0XkrmRuPxC6iQ9AO0G13
         QS9g==
X-Gm-Message-State: APjAAAWRCTLA3Ozs/bxN0i++QKwGzBINtRlSbzbO1hEUlt3FOgo2NQYG
        b27WGXRXeoMOILtMPDIqJjYRNW0=
X-Google-Smtp-Source: APXvYqzs3nljtgb3WFJjfxl5FTsEOAwwnELJIW7xTZwbdpffis00wCNglIJCtpBwV2EwQPMYJSwlmQ==
X-Received: by 2002:a5d:980c:: with SMTP id a12mr2451937iol.58.1553015737678;
        Tue, 19 Mar 2019 10:15:37 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id y19sm1789405itb.2.2019.03.19.10.15.36
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Mar 2019 10:15:37 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Don't let RPC_SOFTCONN tasks time out if the transport is connected
Date:   Tue, 19 Mar 2019 13:14:29 -0400
Message-Id: <20190319171429.109726-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the transport is still connected, then we do want to allow
RPC_SOFTCONN tasks to retry. They should time out if and only if
the connection is broken.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 228970e6e52b..98f6e27feba5 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2315,6 +2315,7 @@ static void
 rpc_check_timeout(struct rpc_task *task)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
+	struct rpc_xprt *xprt = NULL;
 
 	if (xprt_adjust_timeout(task->tk_rqstp) == 0)
 		return;
@@ -2322,10 +2323,14 @@ rpc_check_timeout(struct rpc_task *task)
 	dprintk("RPC: %5u call_timeout (major)\n", task->tk_pid);
 	task->tk_timeouts++;
 
-	if (RPC_IS_SOFTCONN(task)) {
+	if (task->tk_rqstp)
+		xprt = task->tk_rqstp->rq_xprt;
+
+	if (RPC_IS_SOFTCONN(task) && xprt && !xprt_connected(xprt)) {
 		rpc_exit(task, -ETIMEDOUT);
 		return;
 	}
+
 	if (RPC_IS_SOFT(task)) {
 		if (clnt->cl_chatty) {
 			printk(KERN_NOTICE "%s: server %s not responding, timed out\n",
-- 
2.20.1

