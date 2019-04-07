Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B257C10F0E
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7043120896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d3Zyf7l7"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726493AbfDGSBs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:48 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:40284 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726489AbfDGSBs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:48 -0400
Received: by mail-it1-f194.google.com with SMTP id k64so17314997itb.5
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=QVHC9nXN/OYYOsgPjLV9ouq+Ky6WPum+S8eGKpHpCo4=;
        b=d3Zyf7l7sSrOEQABkHtDP6dU4qcYN/vgzfNIHUMePEyo20s34ZFB1TziZ99Ufm6c/4
         fIAd4QExam4WCyynd2OyKQbBTKRoUcVGDjpuPuharA6Os0NHuUAZYfcjWsF+0OKQkMEl
         o5W/DGF8HOv1d3A9nvKCG7WA1zZxrIClOa9OqOSnNIFKn2gYYA2LKYeMLHq2sA+42Ut6
         115qciUIv7uru5ZI6uQBfuKl6tTWR3DCJclLZA2Y+c4v1aergMuqQKKKFbL5FC0GPiP0
         5duT70qmHHPOdPGJoqL0TWsYtT7FUonbqj1J7bSlLS/Ex0MKxRaStLIIPyMqvNa9BwOl
         8bLA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=QVHC9nXN/OYYOsgPjLV9ouq+Ky6WPum+S8eGKpHpCo4=;
        b=h77ugu33sHABj6mAjbaxz4WpXpo8voZZpesCVLCAoAGQdCggg9DFA8R8XUc/+/m04C
         JYLeFkZ0eTVbtxB1/BNlOOFoGV7xYgGH7Mb95sT3bQ1H74ZXAYUyvGELWOE2wZqa3JmE
         ZO1LNLdZ/M1zXDQtet5dzWwphb+BrgrGpr5QrAG2naa8P0o/hIyLGlp1gGLzhiKJZM9Y
         eyaNO2qeg/275qNE52CuwJfoVpqYO+APDAUYaHKwtM7SfwgYR4sUPMxJzwETsRKFWBQv
         Lpr3ZE2ZHrLA8D3Wo/RBDafy1dklOrZ755W7lZjDBD4Ad36uQgfKIqffAOHeI+wDLQG8
         1dhg==
X-Gm-Message-State: APjAAAX65M9LoSP+SxeyuZUjPIhWK8jvWxyaAuhou9RXzCCJk+OXNXz1
        g/kh8uXn6qkB+JXlLJBJww==
X-Google-Smtp-Source: APXvYqyxXgjbyLAyzbPsM3BbNbLSzJ/FEPrk3p8gYXvJyABlNm1PxJUmkpjWB6EoNkL8o2UPgPloWw==
X-Received: by 2002:a24:5f8c:: with SMTP id r134mr18120105itb.110.1554660107577;
        Sun, 07 Apr 2019 11:01:47 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:46 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 27/29] NFS: Ensure that all nfs lock contexts have a valid open context
Date:   Sun,  7 Apr 2019 13:59:10 -0400
Message-Id: <20190407175912.23528-28-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-27-trond.myklebust@hammerspace.com>
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
 <20190407175912.23528-13-trond.myklebust@hammerspace.com>
 <20190407175912.23528-14-trond.myklebust@hammerspace.com>
 <20190407175912.23528-15-trond.myklebust@hammerspace.com>
 <20190407175912.23528-16-trond.myklebust@hammerspace.com>
 <20190407175912.23528-17-trond.myklebust@hammerspace.com>
 <20190407175912.23528-18-trond.myklebust@hammerspace.com>
 <20190407175912.23528-19-trond.myklebust@hammerspace.com>
 <20190407175912.23528-20-trond.myklebust@hammerspace.com>
 <20190407175912.23528-21-trond.myklebust@hammerspace.com>
 <20190407175912.23528-22-trond.myklebust@hammerspace.com>
 <20190407175912.23528-23-trond.myklebust@hammerspace.com>
 <20190407175912.23528-24-trond.myklebust@hammerspace.com>
 <20190407175912.23528-25-trond.myklebust@hammerspace.com>
 <20190407175912.23528-26-trond.myklebust@hammerspace.com>
 <20190407175912.23528-27-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Force the lock context to keep a reference to the parent open
context so that we can guarantee the validity of the latter.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/inode.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 414a90d48493..efc45f22c581 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -885,10 +885,14 @@ struct nfs_lock_context *nfs_get_lock_context(struct nfs_open_context *ctx)
 		spin_lock(&inode->i_lock);
 		res = __nfs_find_lock_context(ctx);
 		if (res == NULL) {
-			list_add_tail_rcu(&new->list, &ctx->lock_context.list);
-			new->open_context = ctx;
-			res = new;
-			new = NULL;
+			new->open_context = get_nfs_open_context(ctx);
+			if (new->open_context) {
+				list_add_tail_rcu(&new->list,
+						&ctx->lock_context.list);
+				res = new;
+				new = NULL;
+			} else
+				res = ERR_PTR(-EBADF);
 		}
 		spin_unlock(&inode->i_lock);
 		kfree(new);
@@ -906,6 +910,7 @@ void nfs_put_lock_context(struct nfs_lock_context *l_ctx)
 		return;
 	list_del_rcu(&l_ctx->list);
 	spin_unlock(&inode->i_lock);
+	put_nfs_open_context(ctx);
 	kfree_rcu(l_ctx, rcu_head);
 }
 EXPORT_SYMBOL_GPL(nfs_put_lock_context);
-- 
2.20.1

