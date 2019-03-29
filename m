Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4724AC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1557E2184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="L0WonaDQ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730342AbfC2WCH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:07 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:55522 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730335AbfC2WCH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:07 -0400
Received: by mail-it1-f195.google.com with SMTP id z126so6167134itd.5
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YiggeHe5Ur0/gP4LNTHnltg0CL5XFAPcOjWyE4a6Zn4=;
        b=L0WonaDQVNMkoaybMZo2dPdGw8eArLeoQLLYi9N+zJgrGq0RJ/hkpwrn/gVei1PNO3
         SQq93PVvF9whr+BeAqZ3UdE2EqxLbY+2VJPodHMaM+Cv6sFdnVC5MMEb6Kkc+uXdluYB
         3gywHE4skdwafYX2HPx7lZeL3Ag3pw7I1QYgLy1Mcz1Jr9FBmJEEOeavAS/xoYHL4TGo
         GJLApSUemQmos/4t2NdHmqitAOP68DF+VVMUJTMyQJ83+w5Roleje3s/ky+Bcc3AhKGz
         Dr08vKzDOgwXPkNgURgSpZW7hxUnLD+pNMyOMpqUTg8GMSMA7RMv//3sbN7Du004XeEQ
         QQbw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=YiggeHe5Ur0/gP4LNTHnltg0CL5XFAPcOjWyE4a6Zn4=;
        b=d9dkPC9DcBKtdxdWaLg/V0nJ4OAoKHoaayEED/UcoyYYKQmaB2TExni5+YR+eBmMj1
         qjhkQjyCdxyOlSCgvQoCoIFgsBSu5WtAZPYY5RXwg10pofyyUTZsEmIsrV8nVC5uJgWr
         HnVy9hc1LQbOcM3kr/MTJ5ZxsCKRfpnCIS15z1Z/tG8Usra4I86YGcTUMnb5NpITN/EY
         iPXZvVmR4/WM4nvYVOscn2n7vKIK7pRfevoG7avyJMBkFmlUANAG6pFPBpF9v33/CbAH
         1f4iSYZje0QP5P+RNyiEYSS8l9x/q1cWr1+R6lI5V9d36l2iLKFXROwUyMHrcPNtrmfm
         nKQA==
X-Gm-Message-State: APjAAAVgo6GTskux9jwyFmrsPJ+4V2BIROZBHJzHRuXteF4qrU1kg8Lv
        abTs2SrmqOJW5Q2vVx3ZEmKJPQs=
X-Google-Smtp-Source: APXvYqxknWEFvc9MHqF0HOAHJVwVeBmcMemU079yo2is4OjoLG/xbBfyqWvw21UTUgrUIQMg7gBxhQ==
X-Received: by 2002:a02:3b55:: with SMTP id i21mr24178056jaf.128.1553896926091;
        Fri, 29 Mar 2019 15:02:06 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.05
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:05 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 12/28] SUNRPC: Make "no retrans timeout" soft tasks behave like softconn for timeouts
Date:   Fri, 29 Mar 2019 17:59:32 -0400
Message-Id: <20190329215948.107328-13-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-12-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
 <20190329215948.107328-5-trond.myklebust@hammerspace.com>
 <20190329215948.107328-6-trond.myklebust@hammerspace.com>
 <20190329215948.107328-7-trond.myklebust@hammerspace.com>
 <20190329215948.107328-8-trond.myklebust@hammerspace.com>
 <20190329215948.107328-9-trond.myklebust@hammerspace.com>
 <20190329215948.107328-10-trond.myklebust@hammerspace.com>
 <20190329215948.107328-11-trond.myklebust@hammerspace.com>
 <20190329215948.107328-12-trond.myklebust@hammerspace.com>
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

