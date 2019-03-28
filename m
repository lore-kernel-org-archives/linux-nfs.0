Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C9B1C10F06
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CCDB821855
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UxZsp5xy"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726472AbfC1U4f (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:35 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:52711 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727227AbfC1U4e (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:34 -0400
Received: by mail-it1-f194.google.com with SMTP id g17so471796ita.2
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AbEMLia4utK6mPwIGrGFCMFUy10D6UYWZy3EdSHjtO8=;
        b=UxZsp5xyqXFFjVOJAAV9pLGYPbPtf62/vEtAztmfb3P+MVDsIXl+TcOcqV7CtIMQc9
         IMxRVQ3OSaKSEPxFfm324XhSyV7wxd5CdsfZgQdhR6SITr31a4HcIVg1+ZL6GAeQ0bqp
         R+QTHd91cd7ITNfMGco6I26cMFDtLRFxyvrW+UtJZJ1d8wpGuehGBYOP8IdnWFAdjBup
         lIPQH6BOWLCmtXCXfJ+Kviya2IYuwxIdUaxZGik8A4VyBhxEu54GWVqwSjeojVR5fV14
         12IhTQTSiYLdawEL24RWwHZzM0xxMrDnfZT7ktvTlLUpPIBZF2Nr0Ijnqw8ALFPK5sj1
         EdWw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=AbEMLia4utK6mPwIGrGFCMFUy10D6UYWZy3EdSHjtO8=;
        b=uhdVhkebJFFNEzRPk80oRFR2+jTH3Eupxgwf/FzypE2z5tqy+kuErwvXjDo9qCIbaW
         y9+7rySxIccid8wbnBqZAuTlpWUit6XVhOSFWYec6+bgQEfIaLFvdw+7CEHKkVnbQY+g
         JSgrg4rF6yUGd2FjFeDzC5cPWqxCfz2wRLQkeakYTkPDFKmb/pXUTfHumrjAJ6Ecx1ou
         9MuxI00E1ZMQTMSJ8K3sdDe/EfUSKwacSpxvVh0RomfKmIhTCD3F0wdEn9xXSdYeMFdv
         vWywzR6GWv2f5cjJEMG1Zkty6OoWdTZtPJA9j+Zw5MGaEAlLVqJ4AyDjK/XDQys+y9HM
         Vh/w==
X-Gm-Message-State: APjAAAWUTnemLehV/Nq2cshUGZHEnv1MVIBxHZa3uOCuGksWAXVCbvDP
        UYcNEQygwkXFCLCsNWsgrLWqxFM=
X-Google-Smtp-Source: APXvYqxtfwn7EaRHHComtdA3/zXUIsp+h8MvvWCim0RZvr1XfBuyt6nGg+WG0hBYH4IYwFo+pEeacg==
X-Received: by 2002:a24:290d:: with SMTP id p13mr1725289itp.178.1553806593092;
        Thu, 28 Mar 2019 13:56:33 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.32
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:32 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 25/25] NFS: Remove redundant open context from nfs_page
Date:   Thu, 28 Mar 2019 16:52:39 -0400
Message-Id: <20190328205239.29674-26-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-25-trond.myklebust@hammerspace.com>
References: <20190328205239.29674-1-trond.myklebust@hammerspace.com>
 <20190328205239.29674-2-trond.myklebust@hammerspace.com>
 <20190328205239.29674-3-trond.myklebust@hammerspace.com>
 <20190328205239.29674-4-trond.myklebust@hammerspace.com>
 <20190328205239.29674-5-trond.myklebust@hammerspace.com>
 <20190328205239.29674-6-trond.myklebust@hammerspace.com>
 <20190328205239.29674-7-trond.myklebust@hammerspace.com>
 <20190328205239.29674-8-trond.myklebust@hammerspace.com>
 <20190328205239.29674-9-trond.myklebust@hammerspace.com>
 <20190328205239.29674-10-trond.myklebust@hammerspace.com>
 <20190328205239.29674-11-trond.myklebust@hammerspace.com>
 <20190328205239.29674-12-trond.myklebust@hammerspace.com>
 <20190328205239.29674-13-trond.myklebust@hammerspace.com>
 <20190328205239.29674-14-trond.myklebust@hammerspace.com>
 <20190328205239.29674-15-trond.myklebust@hammerspace.com>
 <20190328205239.29674-16-trond.myklebust@hammerspace.com>
 <20190328205239.29674-17-trond.myklebust@hammerspace.com>
 <20190328205239.29674-18-trond.myklebust@hammerspace.com>
 <20190328205239.29674-19-trond.myklebust@hammerspace.com>
 <20190328205239.29674-20-trond.myklebust@hammerspace.com>
 <20190328205239.29674-21-trond.myklebust@hammerspace.com>
 <20190328205239.29674-22-trond.myklebust@hammerspace.com>
 <20190328205239.29674-23-trond.myklebust@hammerspace.com>
 <20190328205239.29674-24-trond.myklebust@hammerspace.com>
 <20190328205239.29674-25-trond.myklebust@hammerspace.com>
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

