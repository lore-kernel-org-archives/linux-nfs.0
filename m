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
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF4A8C4360F
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9A0B521850
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KtDSM8wM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726311AbfC1U42 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:28 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:56107 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727558AbfC1U42 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:28 -0400
Received: by mail-it1-f193.google.com with SMTP id z126so437157itd.5
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DCXLhS5/3tUUdZhpeepOV5pEwBq2CK21UuGwNrJC8co=;
        b=KtDSM8wM5PeXKMkkaA/rqwpb0hPN6ZveBle3SiY3C0t05B0eThyL9WMjpIRVkre7fL
         ThisHx4erHXj/I63Ck6LiO07MeNcBhFCmT2RWCojms/vtFOXnyN9u0+ztvQxS0MuqDks
         nEivLt0FLrrgz/WHB7yh3AZkoKOLoI3Sedg848FWWSsL5xML8U1odiKoyn6VWKPyza+M
         HcUplrsA0l8hvlfI6ighoos/QVelSdVUUZ4ovISB822xQNNGE9Ap0ZSCC9Ek0tz51wVz
         fGEeq0sVvZNX8zULA7MwIt99arobownes3yV630oI7566jr3E4oxNOxs6rWMsEbBMpY5
         IjrQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=DCXLhS5/3tUUdZhpeepOV5pEwBq2CK21UuGwNrJC8co=;
        b=Hg/GtAZKjuU8ekxwd+/CseJQ6QqaFIGvd2aC/Kf12HH8U4gA/Q5hulVDyWbnGvv1hA
         0skk3ZjGo3aIIxKI1hvDGLEqwBCUsP6NZZlQIrVCp6/YATWNrhHdpleoa3FCXe6vZwXt
         VLpTpEWXjlZhSUJy2rGY9u/zEjdBhwb4QmoAKkkqkfws0SGqiDWVlr5MKDLwL3HXGgXk
         GRhB3RLoTZcAB45wurh7U387Ffh71cSruym9aPs1tDe1BtMRu+qulvUmAoxhSjxCTIUk
         GpcH6cvXhZKjlpLmEMwOOUIUT26h82V0dyZKGwjCDIJqBNYlyA6E66rtX4hATwiMEuTo
         b0zw==
X-Gm-Message-State: APjAAAWHy+l3jafC7bRVmV0+Fr9E/vokZMGYGUjsv+LBXePEg1esvVkj
        J7Gfa/u2pX+A6onRB0hhkJlYBMY=
X-Google-Smtp-Source: APXvYqyT2F9sBWK4rFUTMSnIizgWNnhAtwLDTrT4lrz0fknLQu77lAV5oQ1i2zAAVSQ781x8dBfRcQ==
X-Received: by 2002:a02:9831:: with SMTP id t46mr30649956jaj.140.1553806586408;
        Thu, 28 Mar 2019 13:56:26 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.25
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:25 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 20/25] NFS: Fix up NFS I/O subrequest creation
Date:   Thu, 28 Mar 2019 16:52:34 -0400
Message-Id: <20190328205239.29674-21-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-20-trond.myklebust@hammerspace.com>
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

