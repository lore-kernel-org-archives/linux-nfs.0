Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FFE9C10F0E
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6300A20896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WWuil+UT"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726366AbfDGSBa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:30 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:55251 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726415AbfDGSBa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:30 -0400
Received: by mail-it1-f194.google.com with SMTP id a190so17229586ite.4
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=S8Onab4jgnKym3AwxLtKfsy6Qv+7ShLULekC3tNO+mQ=;
        b=WWuil+UTdodfC+qzvmPYzv7SRtojU57EmqHBeyXQYUQ2pkD0NmWw0Ktk7NQG113voD
         ODlG2gY9/kkHoINsy4sLPrpoGWttrl3S4OhYkaLNslYec4nXZXNxb7QmH1raeDOU8PEw
         NgEySa/JTcCli0dTFWsxuspqqnx8OGc1OFU8MMUBYT7eXdFR+cMTANjujfeLiBRoiGF9
         qfOeZf8whobOEMUw9iqbSeFxEK8+JYWu80EwbUiY9wi5VIH8TIcV3giAnClAYkwD+Pqi
         KX6xHuU57uZY+76J4wAZlThBA0rg29X3J8OT5FEnrC4jGcbrUunuNGnn5hImzjqrwtbA
         eobw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=S8Onab4jgnKym3AwxLtKfsy6Qv+7ShLULekC3tNO+mQ=;
        b=CnJE7ME8O+1xI1MGoDNBT8aA5On/O4kCTm5ewI1GMN+OoogUantgKDkLe9ABmAq0S3
         dBDsyyWSNO/o9C5gFxMaLPujLbNgTlIbfZOJonylaFyjte5xTeL+qAkN7FfdJE2F61PS
         XVm+0zXZgFiP7+v4VdSbos+QwRrYdrymLfkwp5Rp+oRe21RWVT0koeGKBHvqMOsT8LK6
         rrnUmmise4KJC66X/WmUIFhQQXz/KsXOmuUql+CfIpsTDUwgkwni59BW2hyErh7yi1c/
         S4RPW9iNSH7aUQOGCPFNIoEXag+FIU1xsCvMWL61lwHai1YcI/tEuKqOKuh0UXs4kNAh
         14Jg==
X-Gm-Message-State: APjAAAU1upCE3mzY3l7uR5DYLB32q4baS7q2UZbcFevsGfGuQvXPl+S6
        5arP5vsy1dDo/rWXODsDpQqS0J4=
X-Google-Smtp-Source: APXvYqz+hyhMHzvDWywrkDuuDw9Thx3ws6J5RNiFjho3MRh5IOw2uTmp+IqIhvJ5omqJK7sPXFRhzA==
X-Received: by 2002:a24:e85:: with SMTP id 127mr18030241ite.4.1554660089345;
        Sun, 07 Apr 2019 11:01:29 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:28 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 09/29] SUNRPC: Declare RPC timers as TIMER_DEFERRABLE
Date:   Sun,  7 Apr 2019 13:58:52 -0400
Message-Id: <20190407175912.23528-10-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-9-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
 <20190407175912.23528-2-trond.myklebust@hammerspace.com>
 <20190407175912.23528-3-trond.myklebust@hammerspace.com>
 <20190407175912.23528-4-trond.myklebust@hammerspace.com>
 <20190407175912.23528-5-trond.myklebust@hammerspace.com>
 <20190407175912.23528-6-trond.myklebust@hammerspace.com>
 <20190407175912.23528-7-trond.myklebust@hammerspace.com>
 <20190407175912.23528-8-trond.myklebust@hammerspace.com>
 <20190407175912.23528-9-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Don't wake idle CPUs only for the purpose of servicing an RPC
queue timeout.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/sched.c | 4 +++-
 net/sunrpc/xprt.c  | 4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 301e0f7f1dc9..1a12fb03e611 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -249,7 +249,9 @@ static void __rpc_init_priority_wait_queue(struct rpc_wait_queue *queue, const c
 	queue->maxpriority = nr_queues - 1;
 	rpc_reset_waitqueue_priority(queue);
 	queue->qlen = 0;
-	timer_setup(&queue->timer_list.timer, __rpc_queue_timer_fn, 0);
+	timer_setup(&queue->timer_list.timer,
+			__rpc_queue_timer_fn,
+			TIMER_DEFERRABLE);
 	INIT_LIST_HEAD(&queue->timer_list.list);
 	rpc_assign_waitqueue_name(queue, qname);
 }
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 7c3623b17493..36af1a1929af 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1842,7 +1842,9 @@ struct rpc_xprt *xprt_create_transport(struct xprt_create *args)
 		xprt->idle_timeout = 0;
 	INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
 	if (xprt_has_timer(xprt))
-		timer_setup(&xprt->timer, xprt_init_autodisconnect, 0);
+		timer_setup(&xprt->timer,
+				xprt_init_autodisconnect,
+				TIMER_DEFERRABLE);
 	else
 		timer_setup(&xprt->timer, NULL, 0);
 
-- 
2.20.1

