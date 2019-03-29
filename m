Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69961C10F05
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2BC052184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pNPspRDe"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730367AbfC2WCR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:17 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:55546 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730357AbfC2WCR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:17 -0400
Received: by mail-it1-f196.google.com with SMTP id z126so6167715itd.5
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DCXLhS5/3tUUdZhpeepOV5pEwBq2CK21UuGwNrJC8co=;
        b=pNPspRDe8MTS4pVaT1exUmjrDADspB2Y5KCH/txCwUrQt+03aT64BhOK9y5zN1WlYe
         O99/+IIx6S0fIS7V6OnQXMuxkkDK6DytVLLMXBuaeJUQ2LRGH8O39gpTesg+049seAYx
         HZFu7ls8WsOzLAjJsj+jkRf99FfdjNekdXUymiBDiysebS46adRIma74sX/hpEXvT4ID
         aSQWDwgw3FakAMGP5Pn8TjsRAyjmWzrZ/dlfwREJz/sLLYcNeg2tAS7v+RFnZ2G/kK1T
         eFW1R6lmjhqq6jFfpXFATcLZyb7Jc6ej5ZLAF/ekOT4cAfYZgyN6hGU44LkLcTeFLZHO
         UDoA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=DCXLhS5/3tUUdZhpeepOV5pEwBq2CK21UuGwNrJC8co=;
        b=SnNKRbmm6Ww20tctIdr1WI9qlx2hJoX+0F3uOPU/sO0ixVTCb4XBwr9yjQTNuoY7Fd
         cytztQzrmpUMbNYwMasJC7UWVEKctsBnT0BAOhQ6/0Tu1iJNqdFc9bD8Wo2xGTyEI5SC
         OORdi6I1VNaeVrW1Z3FoTA+GOMCNQW/FbnBtZCRVHyjhiXuItEy4J1o23fVb4JN2VTCh
         WOPuBGT9X/Txrw+8fTFrDVxB5r5q43VFoAh2Z21ssgKH0EzyrXqPFtGPeID3yXwoSKaS
         90mGHu7zJX25zVyqx1AFqxhwyV7s0v1zZnYvOgcvEZwp9oPtfQUWRKWaHGiHlvYKugcw
         o/kw==
X-Gm-Message-State: APjAAAWITu0MC+5ka9vw7e0XCemoMTuUu761ygqvBkxDqzyCutSPEf2m
        OHGs47Or6AHX9wUkgjeCUG0ionE=
X-Google-Smtp-Source: APXvYqySoDgA83EC1Bu9BPFtculpVYjOi8UyxioUF7P+etA4rtANe5cwH0iQtGPaG5goKli5s6WXgQ==
X-Received: by 2002:a24:69c4:: with SMTP id e187mr6131948itc.12.1553896935555;
        Fri, 29 Mar 2019 15:02:15 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.14
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:14 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 23/28] NFS: Fix up NFS I/O subrequest creation
Date:   Fri, 29 Mar 2019 17:59:43 -0400
Message-Id: <20190329215948.107328-24-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-23-trond.myklebust@hammerspace.com>
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

