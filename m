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
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAAB7C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A76D72184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="C2zaM40q"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730330AbfC2WCF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:05 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:53676 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730316AbfC2WCF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:05 -0400
Received: by mail-it1-f196.google.com with SMTP id y204so6194560itf.3
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=S8Onab4jgnKym3AwxLtKfsy6Qv+7ShLULekC3tNO+mQ=;
        b=C2zaM40qKQsrmEvJ0zEIbhVcHgcvvKhO5NNCtXapDAXkUYcFBlAK+04VbDVjXk2y2y
         8OYeyvmaGc0Gt1XRfgIzwSEXzljBLMZwzCbz+yAmNFvIPdKFU1uvOiV2BWcVDjP3jHPb
         D19lWGFdPRGPVKHr/dbRUUXH7qlOP5Qf6+QjAJ4vIxuIJfUsYmtt2uF+Y9v3XCEjOzmN
         qrbPj15iN6fZp2aNwC4VuCVPQGniCKdoFWE+3L6iPbKEa5volFiAE+IfhBaKNBHc6d6w
         ECllYVVGFB4SJJdg0Kii/tCBGqUx6FffIDnYeMYuah5CzsSL60Bo9h71Vmsehq90kXKn
         jmDA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=S8Onab4jgnKym3AwxLtKfsy6Qv+7ShLULekC3tNO+mQ=;
        b=T301jDM/t1SqX1ur3GFTUpfQnJnRz8XsW9quDMB35ISY4pisOWRsaeSFa3YRBHPzji
         toVzlH5toXxH2YInN/eJGYYFUGJodaFsdyaIikUeFak+AGBaWdYA+lhC0eAW5nFK/kWD
         Ya1t7EeUrJnFejh1rAGQkWKYNySWyUtOg+WpBKU/712urwZCBUbD76xck+fg2Cv6/cKD
         7JjyFQ/7KM97/0x05d0xNIkMKEIVTmeuLJeJ4jYWm5lXiuNKE5F8rDxWN1/Fz88//Y0p
         xUwGEduzryE9KpXAcrT6/XmltiQ6elAuyMvKABaDVntjwT3ZM3FOufHweSsKNxf6M6AY
         1Vog==
X-Gm-Message-State: APjAAAUezQU/cf59Q034hWQuE094ojdf/zr6fGoUxFef4xYpkHZP0bTf
        QSl9Q8Calo3cSIXBDvnHAJTiWdQ=
X-Google-Smtp-Source: APXvYqwGqNGJ2DUJC341jug2sWx+MZumNe9s0nqIzt3jlTETlGSp04G23DrF2/pxxg+xry/FBgz6jA==
X-Received: by 2002:a02:bb04:: with SMTP id y4mr37486716jan.67.1553896923664;
        Fri, 29 Mar 2019 15:02:03 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.02
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:03 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 09/28] SUNRPC: Declare RPC timers as TIMER_DEFERRABLE
Date:   Fri, 29 Mar 2019 17:59:29 -0400
Message-Id: <20190329215948.107328-10-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-9-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
 <20190329215948.107328-5-trond.myklebust@hammerspace.com>
 <20190329215948.107328-6-trond.myklebust@hammerspace.com>
 <20190329215948.107328-7-trond.myklebust@hammerspace.com>
 <20190329215948.107328-8-trond.myklebust@hammerspace.com>
 <20190329215948.107328-9-trond.myklebust@hammerspace.com>
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

