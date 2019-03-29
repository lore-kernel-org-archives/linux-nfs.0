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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 134DBC10F05
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CF58D2184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ki5NMMTE"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730372AbfC2WCV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:21 -0400
Received: from mail-io1-f65.google.com ([209.85.166.65]:37328 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730374AbfC2WCU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:20 -0400
Received: by mail-io1-f65.google.com with SMTP id x7so3012176ioh.4
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AbEMLia4utK6mPwIGrGFCMFUy10D6UYWZy3EdSHjtO8=;
        b=ki5NMMTE5qsX/WJSiYtp/pu5W6nPE0j/hWoNbf6mpfQoZSBmTn9euKWH0iPg8skms4
         PVfdlTN3nx7BUzeaw6DFxeGn1oIokQZJUW/OVvUDy0h2ad+ty4IOGzLKDaCNBba/vMlU
         qFzqYqg6N0nJOP1V5sUWxe0ldnE2UyRxUrXQzGHk32UXJneHVlEH/Gm/DL1DlC4rNiem
         1SW5jIGzyfjUkjpE3NsTy2u8jmQNqWU/UW8TvO13LnEiDrLYon+wKh0kQj61YfaxH+nX
         M263dXMouUzTLQ9rL9EcZEBVKSZibKeytKHswnoBb9Wv5cmUv5mULbLHQMUbZQEdIpEH
         k++w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=AbEMLia4utK6mPwIGrGFCMFUy10D6UYWZy3EdSHjtO8=;
        b=GXjwtfgZhYU6ttwiNkvtkh6DQDkMLkyU3RaKvLSSgR7jmxG6nhdbL0WgzIOrpmLHu/
         4/fx5WUWzc5EbDa4m5dxoGi/jO2Mg8iyGchR6AHmBBADn0vnQmyfgeZXqB8D5PojO0B1
         L9NPJXY66bC/e0SInXIXK6xbmqaXQiHUjL+S686HsXsCFGIY49AzyEUzak8yjbDKDSeA
         1dOwA790qIbdZuZH1kuuMjJJsz367ju3rSXYKu9t3t2Jd82wc/VktEQjc8NKm9s0I104
         7LykR7Tp+MQoTNi+4rw45AncoGYPzaTbfKM8qoxLEFEHs1VZeJKNRabFmM1lgJuKMvKU
         0mNg==
X-Gm-Message-State: APjAAAU5jiDFl0Qo7+5kjPeOOrgpbA6T0mZNP7lBsah67IVpQhs+QV5Y
        aOb8rwlBlmYEa/wec4AQONiY16I=
X-Google-Smtp-Source: APXvYqxfTdaJVZkQsOEzyQS4rLhCbffMdK5c3ufYj+JA2l4zPlFMHQOjaDyyW0miELyRzqmTn47ABw==
X-Received: by 2002:a6b:7f49:: with SMTP id m9mr16739563ioq.288.1553896939636;
        Fri, 29 Mar 2019 15:02:19 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.18
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:18 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 28/28] NFS: Remove redundant open context from nfs_page
Date:   Fri, 29 Mar 2019 17:59:48 -0400
Message-Id: <20190329215948.107328-29-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-28-trond.myklebust@hammerspace.com>
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
 <20190329215948.107328-13-trond.myklebust@hammerspace.com>
 <20190329215948.107328-14-trond.myklebust@hammerspace.com>
 <20190329215948.107328-15-trond.myklebust@hammerspace.com>
 <20190329215948.107328-16-trond.myklebust@hammerspace.com>
 <20190329215948.107328-17-trond.myklebust@hammerspace.com>
 <20190329215948.107328-18-trond.myklebust@hammerspace.com>
 <20190329215948.107328-19-trond.myklebust@hammerspace.com>
 <20190329215948.107328-20-trond.myklebust@hammerspace.com>
 <20190329215948.107328-21-trond.myklebust@hammerspace.com>
 <20190329215948.107328-22-trond.myklebust@hammerspace.com>
 <20190329215948.107328-23-trond.myklebust@hammerspace.com>
 <20190329215948.107328-24-trond.myklebust@hammerspace.com>
 <20190329215948.107328-25-trond.myklebust@hammerspace.com>
 <20190329215948.107328-26-trond.myklebust@hammerspace.com>
 <20190329215948.107328-27-trond.myklebust@hammerspace.com>
 <20190329215948.107328-28-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The lock context already references and tracks the open context, so
take the opportunity to save some space in struct nfs_page.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pagelist.c        | 7 +------
 include/linux/nfs_page.h | 3 +--
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index ce6440b79328..5d5ac5df93e2 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -325,7 +325,6 @@ __nfs_create_request(struct nfs_lock_context *l_ctx, struct page *page,
 	req->wb_offset  = offset;
 	req->wb_pgbase	= pgbase;
 	req->wb_bytes   = count;
-	req->wb_context = get_nfs_open_context(ctx);
 	kref_init(&req->wb_kref);
 	req->wb_nio = 0;
 	return req;
@@ -414,8 +413,8 @@ void nfs_unlock_and_release_request(struct nfs_page *req)
 static void nfs_clear_request(struct nfs_page *req)
 {
 	struct page *page = req->wb_page;
-	struct nfs_open_context *ctx = req->wb_context;
 	struct nfs_lock_context *l_ctx = req->wb_lock_context;
+	struct nfs_open_context *ctx = l_ctx->open_context;
 
 	if (page != NULL) {
 		put_page(page);
@@ -430,10 +429,6 @@ static void nfs_clear_request(struct nfs_page *req)
 		nfs_put_lock_context(l_ctx);
 		req->wb_lock_context = NULL;
 	}
-	if (ctx != NULL) {
-		put_nfs_open_context(ctx);
-		req->wb_context = NULL;
-	}
 }
 
 /**
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 1ea13e94feb7..0bbd587fac6a 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -42,7 +42,6 @@ struct nfs_inode;
 struct nfs_page {
 	struct list_head	wb_list;	/* Defines state of page: */
 	struct page		*wb_page;	/* page to read in/write out */
-	struct nfs_open_context	*wb_context;	/* File state context info */
 	struct nfs_lock_context	*wb_lock_context;	/* lock context info */
 	pgoff_t			wb_index;	/* Offset >> PAGE_SHIFT */
 	unsigned int		wb_offset,	/* Offset & ~PAGE_MASK */
@@ -203,7 +202,7 @@ loff_t req_offset(struct nfs_page *req)
 static inline struct nfs_open_context *
 nfs_req_openctx(struct nfs_page *req)
 {
-	return req->wb_context;
+	return req->wb_lock_context->open_context;
 }
 
 #endif /* _LINUX_NFS_PAGE_H */
-- 
2.20.1

