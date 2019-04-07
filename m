Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 11375C282DD
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DA35020896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IoLuObPd"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726489AbfDGSBv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:51 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:51258 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726487AbfDGSBv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:51 -0400
Received: by mail-it1-f195.google.com with SMTP id s3so17272765itk.1
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=jNGf8/6MKxOCUrFwTyfqFqQk4c8TR/K5TYmwPaWCdHA=;
        b=IoLuObPdl6tW7NluYGQE+eSrSCHU1L7DRUhyUPpjG44ZrIlqMD+/1ddgVn4U5MW+LB
         Ffubo/urfdmR8hn4s74auPB9wPQJu8ZUI/mUZwRGvxxIo085ivI2djNQxYONKAWzXsMS
         MoDES79MgHE6ciFE0Ut8lAwx499RSKdmOYKkisvhQRBXlNnYfPIU3g09S43eC5pqn5HJ
         eIU0Nzl/tW9uUG/uj7cxcBpsm2wiiKlomr47w1UZO6rNri9hAE45jtc/TGRHYxwkZhAo
         RaXPkae1pRK6bQteciBU8QlfhgHaWDbnPPXTQhKotQ2T/SBVb8GMFgLATB/gMuBhHIyJ
         RvYg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=jNGf8/6MKxOCUrFwTyfqFqQk4c8TR/K5TYmwPaWCdHA=;
        b=f5vHqj4/jqd+2LSP0WH9zYvDZJ0OYOyKumSywFPmKzfIvQNmqd0aNd93qr1bXxn1wQ
         eJEjMRWlScZL6JeHz9Lc9Zq4iHdWT6qqAlc/Psp6cm6Lrww5RSq6B4xeaACPZ/d33+tM
         3JSaFk4GyeNcpaLIiGgnt7oJVdz9WHcqCtx7/njPgNmAsi2NE4eH8TyZb07euMAs/LLl
         NlF9SBCBDvJWjLLSOevwsbICzrwDcGyfEapoL5TCaHM2CTFO6bifZbgSd+Gwz/G3uh73
         S6lsQyGnt6s5gvo8/kuJNngDw4+laf7wxqCLXVI321hRG4zwLRlmaMUYyRZSRWDVG7g1
         JbHw==
X-Gm-Message-State: APjAAAVhSya86/zGB0DKtESvXcRi6R8Oz9w30UcutUPqEDcnn0VfMJGz
        pcM1H3Q0gvPSwK0D3To7qXDXa70=
X-Google-Smtp-Source: APXvYqyOdg/YwEQqwTuNG4a/nBIuSN01HCxxF1ZvnI4SDdwKwss+ZalQigqhFGZYFdN5RtZ2eFyitQ==
X-Received: by 2002:a24:ecc5:: with SMTP id g188mr18247945ith.97.1554660109635;
        Sun, 07 Apr 2019 11:01:49 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.48
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:48 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 29/29] NFS: Remove redundant open context from nfs_page
Date:   Sun,  7 Apr 2019 13:59:12 -0400
Message-Id: <20190407175912.23528-30-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-29-trond.myklebust@hammerspace.com>
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
 <20190407175912.23528-28-trond.myklebust@hammerspace.com>
 <20190407175912.23528-29-trond.myklebust@hammerspace.com>
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
 fs/nfs/pagelist.c        | 8 ++------
 include/linux/nfs_page.h | 3 +--
 2 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index ce6440b79328..6ec30014a439 100644
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
+	struct nfs_open_context *ctx;
 
 	if (page != NULL) {
 		put_page(page);
@@ -424,16 +423,13 @@ static void nfs_clear_request(struct nfs_page *req)
 	if (l_ctx != NULL) {
 		if (atomic_dec_and_test(&l_ctx->io_count)) {
 			wake_up_var(&l_ctx->io_count);
+			ctx = l_ctx->open_context;
 			if (test_bit(NFS_CONTEXT_UNLOCK, &ctx->flags))
 				rpc_wake_up(&NFS_SERVER(d_inode(ctx->dentry))->uoc_rpcwaitq);
 		}
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

