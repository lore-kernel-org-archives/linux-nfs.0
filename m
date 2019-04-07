Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63FC1C10F0E
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3306E20896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MOnkn+Mw"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726477AbfDGSBq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:46 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:37942 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726487AbfDGSBq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:46 -0400
Received: by mail-io1-f66.google.com with SMTP id v4so9093781ioj.5
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=mwg6hp4myI005EFK+i5nFA7Xe+v+wzhhNh0tp3xbGf8=;
        b=MOnkn+MwcbMHCRzFRR+xqKh3sMtonSodJ22EDG0zPvPNPbSzL6ao1oZuNPsZ9+Ds3/
         akp0hb/HZc2dcGNxtxZXWygw1SsnIS79L8M2X+jBk0SplsGmv4Lf2UttlkUWaKwk+xEk
         MgsmcUihv3QuI7Z6I0SnvvDFlUHGXxUIFnMubkjVdEVyG7MJTX0rC2hR/FTiZFCOy+LG
         lH/NouHMdrEWSCa9yoN1GMIN0x9eh1HdzUvoB/9tK6mcrccetUICO4gGlenXnfaTlfv2
         +79nGxvBm9r5VvEqeIPtIrKnNcDj0MFjs/z50La1S4bgEG4U9YVNepFHKmEig8pRzXUl
         0bjQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=mwg6hp4myI005EFK+i5nFA7Xe+v+wzhhNh0tp3xbGf8=;
        b=idBBi0loGTnN646jJwfFOJPgmHZFyCaYafXii2MDDOm7mTCg+4x8B6bH8YOkP+mr+F
         C4jkMHPPz0yQBjXtI6p3sRv5VQF0eNiqrUcIeimI95qeNYuZWmAeEbkm0NUeHRgN6PFA
         FsgVH0yxpuYjkx/pN2I5wIfAimQ1twsoKJkj1lSP/xe1oAzaOaOm3MMBtQePzCC5MFu6
         sBo2ThH4/bIUIiAjB45kSs7C4agkINhaA3XPHdPHRJBS5r2M4zSmjkITP6aWXv58o12q
         kWpWILoD/buJKrTEpl8++GK76LN5swOLZgGRtLmBOP7It5VQQ95E+Ug9R/ZaWWmqqlTM
         tGVA==
X-Gm-Message-State: APjAAAXasJwZOpe1iY9Da0VeAoe2ktT9+TUfcr4W06P3WTb52iPDaU++
        TsdaG+IQZ9eeG8B7GkVmhw==
X-Google-Smtp-Source: APXvYqwsV8aFIET60biL8VQBEwBAIgoiV856AJSpMgC8UJIC0vojCmrqX4S/rA7xK4M2RYf4ZfUS5w==
X-Received: by 2002:a6b:f702:: with SMTP id k2mr16587150iog.31.1554660104931;
        Sun, 07 Apr 2019 11:01:44 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:44 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 24/29] NFS: Remove unused argument from nfs_create_request()
Date:   Sun,  7 Apr 2019 13:59:07 -0400
Message-Id: <20190407175912.23528-25-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-24-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

All the callers of nfs_create_request() are now creating page group
heads, so we can remove the redundant 'last' page argument.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/direct.c          |  4 ++--
 fs/nfs/pagelist.c        | 16 ++++++++--------
 fs/nfs/read.c            |  4 ++--
 fs/nfs/write.c           |  2 +-
 include/linux/nfs_page.h |  1 -
 5 files changed, 13 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 0fd811ac08b5..2d301a1a73e2 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -492,7 +492,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			struct nfs_page *req;
 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
 			/* XXX do we need to do the eof zeroing found in async_filler? */
-			req = nfs_create_request(dreq->ctx, pagevec[i], NULL,
+			req = nfs_create_request(dreq->ctx, pagevec[i],
 						 pgbase, req_len);
 			if (IS_ERR(req)) {
 				result = PTR_ERR(req);
@@ -899,7 +899,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			struct nfs_page *req;
 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
 
-			req = nfs_create_request(dreq->ctx, pagevec[i], NULL,
+			req = nfs_create_request(dreq->ctx, pagevec[i],
 						 pgbase, req_len);
 			if (IS_ERR(req)) {
 				result = PTR_ERR(req);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 66a5c5d4a777..b8301c40dd78 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -297,8 +297,8 @@ nfs_page_group_destroy(struct kref *kref)
 
 static struct nfs_page *
 __nfs_create_request(struct nfs_lock_context *l_ctx, struct page *page,
-		   struct nfs_page *last, unsigned int pgbase,
-		   unsigned int offset, unsigned int count)
+		   unsigned int pgbase, unsigned int offset,
+		   unsigned int count)
 {
 	struct nfs_page		*req;
 	struct nfs_open_context *ctx = l_ctx->open_context;
@@ -327,7 +327,6 @@ __nfs_create_request(struct nfs_lock_context *l_ctx, struct page *page,
 	req->wb_bytes   = count;
 	req->wb_context = get_nfs_open_context(ctx);
 	kref_init(&req->wb_kref);
-	nfs_page_group_init(req, last);
 	return req;
 }
 
@@ -335,7 +334,6 @@ __nfs_create_request(struct nfs_lock_context *l_ctx, struct page *page,
  * nfs_create_request - Create an NFS read/write request.
  * @ctx: open context to use
  * @page: page to write
- * @last: last nfs request created for this page group or NULL if head
  * @offset: starting offset within the page for the write
  * @count: number of bytes to read/write
  *
@@ -345,15 +343,16 @@ __nfs_create_request(struct nfs_lock_context *l_ctx, struct page *page,
  */
 struct nfs_page *
 nfs_create_request(struct nfs_open_context *ctx, struct page *page,
-		   struct nfs_page *last, unsigned int offset,
-		   unsigned int count)
+		   unsigned int offset, unsigned int count)
 {
 	struct nfs_lock_context *l_ctx = nfs_get_lock_context(ctx);
 	struct nfs_page *ret;
 
 	if (IS_ERR(l_ctx))
 		return ERR_CAST(l_ctx);
-	ret = __nfs_create_request(l_ctx, page, last, offset, offset, count);
+	ret = __nfs_create_request(l_ctx, page, offset, offset, count);
+	if (!IS_ERR(ret))
+		nfs_page_group_init(ret, NULL);
 	nfs_put_lock_context(l_ctx);
 	return ret;
 }
@@ -365,11 +364,12 @@ nfs_create_subreq(struct nfs_page *req, struct nfs_page *last,
 {
 	struct nfs_page *ret;
 
-	ret = __nfs_create_request(req->wb_lock_context, req->wb_page, last,
+	ret = __nfs_create_request(req->wb_lock_context, req->wb_page,
 			pgbase, offset, count);
 	if (!IS_ERR(ret)) {
 		nfs_lock_request(ret);
 		ret->wb_index = req->wb_index;
+		nfs_page_group_init(ret, last);
 	}
 	return ret;
 }
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 1d95a60b2586..fad1333dbf71 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -118,7 +118,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	len = nfs_page_length(page);
 	if (len == 0)
 		return nfs_return_empty_page(page);
-	new = nfs_create_request(ctx, page, NULL, 0, len);
+	new = nfs_create_request(ctx, page, 0, len);
 	if (IS_ERR(new)) {
 		unlock_page(page);
 		return PTR_ERR(new);
@@ -363,7 +363,7 @@ readpage_async_filler(void *data, struct page *page)
 	if (len == 0)
 		return nfs_return_empty_page(page);
 
-	new = nfs_create_request(desc->ctx, page, NULL, 0, len);
+	new = nfs_create_request(desc->ctx, page, 0, len);
 	if (IS_ERR(new))
 		goto out_error;
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 03cde38ecd31..b9bcbd06a628 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1171,7 +1171,7 @@ static struct nfs_page * nfs_setup_write_request(struct nfs_open_context* ctx,
 	req = nfs_try_to_update_request(inode, page, offset, bytes);
 	if (req != NULL)
 		goto out;
-	req = nfs_create_request(ctx, page, NULL, offset, bytes);
+	req = nfs_create_request(ctx, page, offset, bytes);
 	if (IS_ERR(req))
 		goto out;
 	nfs_inode_add_request(inode, req);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index ad69430fd0eb..b7d0f15615c2 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -114,7 +114,6 @@ struct nfs_pageio_descriptor {
 
 extern	struct nfs_page *nfs_create_request(struct nfs_open_context *ctx,
 					    struct page *page,
-					    struct nfs_page *last,
 					    unsigned int offset,
 					    unsigned int count);
 extern	void nfs_release_request(struct nfs_page *);
-- 
2.20.1

