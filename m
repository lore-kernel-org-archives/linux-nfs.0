Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69AC9C282DE
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3287820896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="m7SFQnLc"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726466AbfDGSBp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:45 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:33484 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726477AbfDGSBp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:45 -0400
Received: by mail-it1-f193.google.com with SMTP id v8so15236663itf.0
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=DCXLhS5/3tUUdZhpeepOV5pEwBq2CK21UuGwNrJC8co=;
        b=m7SFQnLc3jfs0AhycbDmErWpeBQpDvMBO4sMpNVINEx+k/gWDf25GyX/2729/m9YP8
         WGlnekjymCLY2FgFegyz0HpG7PmPKeRZ94UIV5DiWuYBeR7GSdihT1fWami4MgUtiKpP
         cNWaaJo/geJ4VzNBuJg3C2kjz1/0QNfk0/bkFWx3hABlT0yV+SmdlCdg+vSLC6hN5nbZ
         D8sJkl6oRkKO1HBwez/WJPd8FuQXLKBc//fPJnvnXN69DvvKC12oNp97tjY9tHrFjize
         rGl4I/U7GH9Ng7eqk/BRLDzuXVr9EN1TRTH4bnAVZT80WJgMWrG3S2AMSSEhq9Qw//Rt
         DzUA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=DCXLhS5/3tUUdZhpeepOV5pEwBq2CK21UuGwNrJC8co=;
        b=WXH75mj6XX2uLqsOwoNzq2AIbCfDzJDpqYzoIwxU/R557KQcd4Oe1ysws0l3IKvoq5
         CkZxGmSKTRUi2pdwYZYIQlazqQ6Bz/OFbYzYojFLh/uwILGf8SZS3JBDI3H5gyUm7CS8
         E+dzpidL7hQ3zxCctoSwwZ0rQisL5JA/Lcm2wNL5RZ9h/ix1SziQ+FU3XEjyyik13UTA
         DlPEn/qMBG9bPBqRYXME8vHO99CvvDAu5O/kg2adZTSbdgqXE7V893RsyNpbnwO6AsI4
         PhNBVGKeHSYNOi+SiCCeNVx7QRWYog2b/Y+mMEtknwLZ/KhzsOwhkC4+eFIUMZp6Wlxs
         3Htg==
X-Gm-Message-State: APjAAAUMcKhk80v3Oqv9nvzXg9685vGR1xY0M5OI7hdXnHy7HsJloc8j
        DoY3Oj9CC7ZY24DHQd0wfw==
X-Google-Smtp-Source: APXvYqwARdGDmcRV9hPCytCOvB/5fXc4txjr0Yz9O3d9S9zn2vRko9FqoP/HppSwxXHqx9ziRN4MBg==
X-Received: by 2002:a05:660c:fcc:: with SMTP id m12mr18842783itn.58.1554660104064;
        Sun, 07 Apr 2019 11:01:44 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.43
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:43 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 23/29] NFS: Fix up NFS I/O subrequest creation
Date:   Sun,  7 Apr 2019 13:59:06 -0400
Message-Id: <20190407175912.23528-24-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-23-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

We require all NFS I/O subrequests to duplicate the lock context as well
as the open context.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pagelist.c | 93 ++++++++++++++++++++++++++++-------------------
 1 file changed, 55 insertions(+), 38 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index e9f39fa5964b..66a5c5d4a777 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -295,25 +295,13 @@ nfs_page_group_destroy(struct kref *kref)
 		nfs_release_request(head);
 }
 
-/**
- * nfs_create_request - Create an NFS read/write request.
- * @ctx: open context to use
- * @page: page to write
- * @last: last nfs request created for this page group or NULL if head
- * @offset: starting offset within the page for the write
- * @count: number of bytes to read/write
- *
- * The page must be locked by the caller. This makes sure we never
- * create two different requests for the same page.
- * User should ensure it is safe to sleep in this function.
- */
-struct nfs_page *
-nfs_create_request(struct nfs_open_context *ctx, struct page *page,
-		   struct nfs_page *last, unsigned int offset,
-		   unsigned int count)
+static struct nfs_page *
+__nfs_create_request(struct nfs_lock_context *l_ctx, struct page *page,
+		   struct nfs_page *last, unsigned int pgbase,
+		   unsigned int offset, unsigned int count)
 {
 	struct nfs_page		*req;
-	struct nfs_lock_context *l_ctx;
+	struct nfs_open_context *ctx = l_ctx->open_context;
 
 	if (test_bit(NFS_CONTEXT_BAD, &ctx->flags))
 		return ERR_PTR(-EBADF);
@@ -322,13 +310,8 @@ nfs_create_request(struct nfs_open_context *ctx, struct page *page,
 	if (req == NULL)
 		return ERR_PTR(-ENOMEM);
 
-	/* get lock context early so we can deal with alloc failures */
-	l_ctx = nfs_get_lock_context(ctx);
-	if (IS_ERR(l_ctx)) {
-		nfs_page_free(req);
-		return ERR_CAST(l_ctx);
-	}
 	req->wb_lock_context = l_ctx;
+	refcount_inc(&l_ctx->count);
 	atomic_inc(&l_ctx->io_count);
 
 	/* Initialize the request struct. Initially, we assume a
@@ -340,7 +323,7 @@ nfs_create_request(struct nfs_open_context *ctx, struct page *page,
 		get_page(page);
 	}
 	req->wb_offset  = offset;
-	req->wb_pgbase	= offset;
+	req->wb_pgbase	= pgbase;
 	req->wb_bytes   = count;
 	req->wb_context = get_nfs_open_context(ctx);
 	kref_init(&req->wb_kref);
@@ -348,6 +331,49 @@ nfs_create_request(struct nfs_open_context *ctx, struct page *page,
 	return req;
 }
 
+/**
+ * nfs_create_request - Create an NFS read/write request.
+ * @ctx: open context to use
+ * @page: page to write
+ * @last: last nfs request created for this page group or NULL if head
+ * @offset: starting offset within the page for the write
+ * @count: number of bytes to read/write
+ *
+ * The page must be locked by the caller. This makes sure we never
+ * create two different requests for the same page.
+ * User should ensure it is safe to sleep in this function.
+ */
+struct nfs_page *
+nfs_create_request(struct nfs_open_context *ctx, struct page *page,
+		   struct nfs_page *last, unsigned int offset,
+		   unsigned int count)
+{
+	struct nfs_lock_context *l_ctx = nfs_get_lock_context(ctx);
+	struct nfs_page *ret;
+
+	if (IS_ERR(l_ctx))
+		return ERR_CAST(l_ctx);
+	ret = __nfs_create_request(l_ctx, page, last, offset, offset, count);
+	nfs_put_lock_context(l_ctx);
+	return ret;
+}
+
+static struct nfs_page *
+nfs_create_subreq(struct nfs_page *req, struct nfs_page *last,
+		  unsigned int pgbase, unsigned int offset,
+		  unsigned int count)
+{
+	struct nfs_page *ret;
+
+	ret = __nfs_create_request(req->wb_lock_context, req->wb_page, last,
+			pgbase, offset, count);
+	if (!IS_ERR(ret)) {
+		nfs_lock_request(ret);
+		ret->wb_index = req->wb_index;
+	}
+	return ret;
+}
+
 /**
  * nfs_unlock_request - Unlock request and wake up sleepers.
  * @req: pointer to request
@@ -1049,14 +1075,10 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 		pgbase += subreq->wb_bytes;
 
 		if (bytes_left) {
-			subreq = nfs_create_request(req->wb_context,
-					req->wb_page,
-					subreq, pgbase, bytes_left);
+			subreq = nfs_create_subreq(req, subreq, pgbase,
+					offset, bytes_left);
 			if (IS_ERR(subreq))
 				goto err_ptr;
-			nfs_lock_request(subreq);
-			subreq->wb_offset  = offset;
-			subreq->wb_index = req->wb_index;
 		}
 	} while (bytes_left > 0);
 
@@ -1158,19 +1180,14 @@ int nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			     lastreq = lastreq->wb_this_page)
 				;
 
-			dupreq = nfs_create_request(req->wb_context,
-					req->wb_page, lastreq, pgbase, bytes);
+			dupreq = nfs_create_subreq(req, lastreq,
+					pgbase, offset, bytes);
 
+			nfs_page_group_unlock(req);
 			if (IS_ERR(dupreq)) {
-				nfs_page_group_unlock(req);
 				desc->pg_error = PTR_ERR(dupreq);
 				goto out_failed;
 			}
-
-			nfs_lock_request(dupreq);
-			nfs_page_group_unlock(req);
-			dupreq->wb_offset = offset;
-			dupreq->wb_index = req->wb_index;
 		} else
 			dupreq = req;
 
-- 
2.20.1

