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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30D0AC4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E6DDE2184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RhLP3CKu"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730369AbfC2WCS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:18 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:38975 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730108AbfC2WCR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:17 -0400
Received: by mail-it1-f196.google.com with SMTP id 139so6261039ita.4
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=A0pqpnca7neEiVllfRIXwjV3so8zdwWFSbpHOdCP0xI=;
        b=RhLP3CKuthVXob0v4DRYUXqHouEfMsRHnCd8iHL6mQ3+wNyzoUJg1zzyjEo9k0SIVY
         Wz2HbfHMrju+k9ACz42NTvac2RLdj8Ibhur0MXtHOsIIOwiDakBOZxxYEpds3sbh6c5J
         qrMoJrE2qZaMVkjNHsP6hTE6OcV+0wLd9LElyqx/dIp8QaK+WES2XjmStGaAYaoLSgVY
         orUHRe5CeriaAdjkC46fx+nLG7VJ71JVGL+hJGDjp2hRAbTeX7Wu/RDi2QDcbhqy9v3a
         Gop7QUIpv9Ke35QSYGav7qWPKr73BNw7GePFSdefQ2jy7x66d4Adc09E1p2H53lHelgn
         xjLA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=A0pqpnca7neEiVllfRIXwjV3so8zdwWFSbpHOdCP0xI=;
        b=hywvB0U4GWmFYW+yuZNps3h8M3ji9bOL3XPZrfCLn5ZMxzraugNfaYUe3KG8Q0h4ZF
         5RMy4g3iVmqpsAfiYv+qzfvbJ5tZG0DU6e/JeF53EG3GJPXmlFibAh5kcX7R4/PeCn9n
         ljrw4SYLJnrMostUvIGGNv4/KUBaFCglFhMz37SJcMi6ZpkywLKnRIljFQUBv7/ImMpx
         a4n80+DSpATMYFBzCQ9d9izFVOw7YlHbYXgqYwUlYZ8DqOeA/JGuiLvyHFWDU090FDkg
         iTGlq5R3Ejdnd+vd2XQ7qG4ExqO1Xy37Yfgk1QzgzwoLoJ3dVc9JZhUB1AHy183+vfXz
         vS/Q==
X-Gm-Message-State: APjAAAUC+HglqDT922/IMVarSoMgr3+1UdtNQZ6MSME10i4ZWMeamN5t
        RLCZyN40dhw92ou6jG1i0XkeVP0=
X-Google-Smtp-Source: APXvYqxAYdHNryCxDnC/ffdT6ozXdX/ZBbVDbwwr0tVf7xaRiLbKfAOXsRacL8mh5+Lh6kkW+V3R0A==
X-Received: by 2002:a24:2b8c:: with SMTP id h134mr6413725ita.15.1553896936369;
        Fri, 29 Mar 2019 15:02:16 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.15
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:15 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 24/28] NFS: Remove unused argument from nfs_create_request()
Date:   Fri, 29 Mar 2019 17:59:44 -0400
Message-Id: <20190329215948.107328-25-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-24-trond.myklebust@hammerspace.com>
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
index 627a2b6ed1fe..0712d886ff08 100644
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

