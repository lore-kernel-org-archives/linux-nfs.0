Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96B8EC4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 683942184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RHTat0Yj"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730144AbfC2WCE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:04 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:38945 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730303AbfC2WCE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:04 -0400
Received: by mail-it1-f194.google.com with SMTP id 139so6260273ita.4
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=byabvxxmICV7URMFFD2mJ+S6tFfR9tedVIX8kLsaKcA=;
        b=RHTat0YjsHIW9mm+HVbrMn5Cvexzk1aUDokUt81AZHukBh/RiDnuMdy8BQBlRUAnMf
         O9WEJkFI2k7UKPGZ0kDNkaRBZdZi1Ng0w//QvRxDpsM+X3RckJ3UcESmRVX91C5aBERB
         cyMRL7cGlyDezOunNxEBWv6iUfbEciaJiEan4r3Y2vrnvA/uDFN8BCd9WYcz7+KTkvXV
         GyF0vFQGPr6vpN33atRQ24Kny89GzwOdhy5PFUdK5gRn2tu+3fdyxGZmrS7R/CjFIPg7
         yamHLbWjyUqZyGXjfpc2nQ8runUAlzUyG8iacggmngaWcXXiVJ4kpFZ5AzbFgdj4d6gs
         XTQQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=byabvxxmICV7URMFFD2mJ+S6tFfR9tedVIX8kLsaKcA=;
        b=pTmjpis3ZNu7yIMi4Jv2Rm0Qa3b29m0sHzuBVjQ3o2XeMUAAwZqy00aeimtGS3/J3N
         9FgCTCsP0HttumnIfXeqQ9Wf/FGpA0F3qyHNmLY4h7pDfrM0fF+NhLPPS/a+a+Pkgy0j
         hBQlvKJrPvNarqI6L0P7300ptR7lVJ8apWompAM8JDvn4nDTFBzehsHbnGD6BGLjhUk3
         6N5QSzm/vM/bK5GJU/0dNas5rL919NrjGIS6FWwcfcrVrm89AsyIjiEMvL1GErFWjEMh
         kFXQ+c6DMgIzQv0o78PIzn9UI1jcL63sZHq+qkzpl4nLlv8s/CwZRLcog0t1FZ0oASQ3
         krHA==
X-Gm-Message-State: APjAAAUwGkX2+4a3NIsgPMaMqezNaeRBq04926RN4DNmJir4ZAlbC/1K
        AdM7RXHZMPhX5TjrSF7FOiPGovc=
X-Google-Smtp-Source: APXvYqxOOYuvUScZ8cGa4ptvJIZ8cQy27FZ4ObhSJDPmIoZ+QZD4N3XJj49L3CXPZq+RCaQue7cwvQ==
X-Received: by 2002:a05:6638:61a:: with SMTP id g26mr3905730jar.83.1553896922886;
        Fri, 29 Mar 2019 15:02:02 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.02
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:02 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 08/28] SUNRPC: Simplify queue timeouts using timer_reduce()
Date:   Fri, 29 Mar 2019 17:59:28 -0400
Message-Id: <20190329215948.107328-9-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-8-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
 <20190329215948.107328-5-trond.myklebust@hammerspace.com>
 <20190329215948.107328-6-trond.myklebust@hammerspace.com>
 <20190329215948.107328-7-trond.myklebust@hammerspace.com>
 <20190329215948.107328-8-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Simplify the setting of queue timeouts by using the timer_reduce()
function.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 include/linux/sunrpc/sched.h | 1 -
 net/sunrpc/sched.c           | 6 ++----
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
index 0b7d333f624e..c41f5f498b3b 100644
--- a/include/linux/sunrpc/sched.h
+++ b/include/linux/sunrpc/sched.h
@@ -183,7 +183,6 @@ struct rpc_task_setup {
 struct rpc_timer {
 	struct timer_list timer;
 	struct list_head list;
-	unsigned long expires;
 };
 
 /*
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index 40944c34a9e4..301e0f7f1dc9 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -92,8 +92,7 @@ __rpc_disable_timer(struct rpc_wait_queue *queue, struct rpc_task *task)
 static void
 rpc_set_queue_timer(struct rpc_wait_queue *queue, unsigned long expires)
 {
-	queue->timer_list.expires = expires;
-	mod_timer(&queue->timer_list.timer, expires);
+	timer_reduce(&queue->timer_list.timer, expires);
 }
 
 /*
@@ -107,8 +106,7 @@ __rpc_add_timer(struct rpc_wait_queue *queue, struct rpc_task *task,
 		task->tk_pid, jiffies_to_msecs(timeout - jiffies));
 
 	task->tk_timeout = timeout;
-	if (list_empty(&queue->timer_list.list) || time_before(timeout, queue->timer_list.expires))
-		rpc_set_queue_timer(queue, timeout);
+	rpc_set_queue_timer(queue, timeout);
 	list_add(&task->u.tk_wait.timer_list, &queue->timer_list.list);
 }
 
-- 
2.20.1

