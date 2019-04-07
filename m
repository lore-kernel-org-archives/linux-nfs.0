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
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9599C282DD
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 69DE020896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UPH4n4GY"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726479AbfDGSBo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:44 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:46246 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726466AbfDGSBo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:44 -0400
Received: by mail-io1-f67.google.com with SMTP id p23so8460764iol.13
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Oyyg6m+TIvf4ff6b8vFxYywF/LAG45bAFsUzHF2TVXs=;
        b=UPH4n4GYNVd2KFZWM/yWR1tUnmb/6afHA1I35yByHW/fS60cnbgvLc1+zexA+Qy1c+
         d3H78ZochjXHuLI407owTK0Lyuq3aUCr4X5DP1YCSoEfIsx3dNcJfVEs+Vf3It2XN9k8
         IBIh2ophs8+yCM15DaWK5NOE4Ztr7kH9CPvFPY3SqpTr4eFgcXcRZFnTti6+QwciGhD6
         7ceONSaA+HlOJp/X5wJ9VnWAgPxq5baB1tQVErSOTGIadl0yfEtLYC0GvZg0MXcNzjnn
         WPYn9R30yGWt0rNoKUbMJDtrv3tp6tQF1kjtLIsL59p2d71pIa+uFyoIcxbm1NZ0r1gr
         iZ7g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Oyyg6m+TIvf4ff6b8vFxYywF/LAG45bAFsUzHF2TVXs=;
        b=Y7WkGeV+7sUEIcnBzkLKaC/AzQTXau17T3MYrO6N77GCeQsEhtGznjq7KON+lsvM7G
         06Vw5WGp1upuF9zBlYDfPLm9otUqPdCPKTA7dh+Z3z2k44a+o9nyFY/PQ1opOX6eFufE
         4vCmG6Kj+1xw9P3LfBdyy3kTMOsbSSW0cNrJGWG6KEYiINEJZL0C3vfbk2ib5CLrcFSL
         B8buDVGbPGojSln6mj21m+MwUxvrWysvhZBoxCpjA4FNI06fubDN+C89qwLb24FqbQ3y
         paYxkkiCh5vLJ36c8UcR0iBF7Ge/wF5Wn1/9QAhMxGG9/8UHclVDgg9qhNYI/jx3CNm6
         xY/A==
X-Gm-Message-State: APjAAAW/MwrxZMutYFxZp/EZpdm8kqBVc4/KSQl1sBCVG5ek68520GNt
        gSQJHMVbp++99qFhqKUSXA==
X-Google-Smtp-Source: APXvYqy776tMRIbKggePS7txZX57lgV4/Ip5VW7fkXIv9/ORsk408DiZUoI/dnDzuIGZ3c1Hutpmag==
X-Received: by 2002:a5d:87d3:: with SMTP id q19mr16234886ios.29.1554660103186;
        Sun, 07 Apr 2019 11:01:43 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.42
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:42 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 22/29] NFS: Replace custom error reporting mechanism with generic one
Date:   Sun,  7 Apr 2019 13:59:05 -0400
Message-Id: <20190407175912.23528-23-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-22-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Replace the NFS custom error reporting mechanism with the generic
mapping_set_error().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/file.c          | 25 ++++---------------------
 fs/nfs/internal.h      |  6 ------
 fs/nfs/write.c         | 40 ++++++++++++++++++++++------------------
 include/linux/nfs_fs.h |  1 -
 4 files changed, 26 insertions(+), 46 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index f807e8643ae6..144e183250c3 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -199,13 +199,6 @@ EXPORT_SYMBOL_GPL(nfs_file_mmap);
  * Flush any dirty pages for this process, and check for write errors.
  * The return status from this call provides a reliable indication of
  * whether any write errors occurred for this process.
- *
- * Notice that it clears the NFS_CONTEXT_ERROR_WRITE before synching to
- * disk, but it retrieves and clears ctx->error after synching, despite
- * the two being set at the same time in nfs_context_set_write_error().
- * This is because the former is used to notify the _next_ call to
- * nfs_file_write() that a write error occurred, and hence cause it to
- * fall back to doing a synchronous write.
  */
 static int
 nfs_file_fsync_commit(struct file *file, int datasync)
@@ -220,11 +213,8 @@ nfs_file_fsync_commit(struct file *file, int datasync)
 	nfs_inc_stats(inode, NFSIOS_VFSFSYNC);
 	do_resend = test_and_clear_bit(NFS_CONTEXT_RESEND_WRITES, &ctx->flags);
 	status = nfs_commit_inode(inode, FLUSH_SYNC);
-	if (test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags)) {
-		ret = xchg(&ctx->error, 0);
-		if (ret)
-			goto out;
-	}
+	if (status == 0)
+		status = file_check_and_advance_wb_err(file);
 	if (status < 0) {
 		ret = status;
 		goto out;
@@ -245,13 +235,7 @@ nfs_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	trace_nfs_fsync_enter(inode);
 
 	do {
-		struct nfs_open_context *ctx = nfs_file_open_context(file);
-		ret = filemap_write_and_wait_range(inode->i_mapping, start, end);
-		if (test_and_clear_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags)) {
-			int ret2 = xchg(&ctx->error, 0);
-			if (ret2)
-				ret = ret2;
-		}
+		ret = file_write_and_wait_range(file, start, end);
 		if (ret != 0)
 			break;
 		ret = nfs_file_fsync_commit(file, datasync);
@@ -600,8 +584,7 @@ static int nfs_need_check_write(struct file *filp, struct inode *inode)
 	struct nfs_open_context *ctx;
 
 	ctx = nfs_file_open_context(filp);
-	if (test_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags) ||
-	    nfs_ctx_key_to_expire(ctx, inode))
+	if (nfs_ctx_key_to_expire(ctx, inode))
 		return 1;
 	return 0;
 }
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 3cefd0ed01be..196534634c3a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -773,9 +773,3 @@ static inline bool nfs_error_is_fatal(int err)
 	}
 }
 
-static inline void nfs_context_set_write_error(struct nfs_open_context *ctx, int error)
-{
-	ctx->error = error;
-	smp_wmb();
-	set_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
-}
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 64cf6a340ba6..03cde38ecd31 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -244,6 +244,12 @@ static void nfs_set_pageerror(struct address_space *mapping)
 	nfs_zap_mapping(mapping->host, mapping);
 }
 
+static void nfs_mapping_set_error(struct page *page, int error)
+{
+	SetPageError(page);
+	mapping_set_error(page_file_mapping(page), error);
+}
+
 /*
  * nfs_page_group_search_locked
  * @head - head request of page group
@@ -582,9 +588,9 @@ nfs_lock_and_join_requests(struct page *page)
 	return ERR_PTR(ret);
 }
 
-static void nfs_write_error_remove_page(struct nfs_page *req)
+static void nfs_write_error(struct nfs_page *req, int error)
 {
-	SetPageError(req->wb_page);
+	nfs_mapping_set_error(req->wb_page, error);
 	nfs_end_page_writeback(req);
 	nfs_release_request(req);
 }
@@ -608,6 +614,7 @@ nfs_error_is_fatal_on_server(int err)
 static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 				struct page *page)
 {
+	struct address_space *mapping;
 	struct nfs_page *req;
 	int ret = 0;
 
@@ -621,19 +628,19 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 	nfs_set_page_writeback(page);
 	WARN_ON_ONCE(test_bit(PG_CLEAN, &req->wb_flags));
 
-	ret = req->wb_context->error;
 	/* If there is a fatal error that covers this write, just exit */
-	if (nfs_error_is_fatal_on_server(ret))
+	ret = 0;
+	mapping = page_file_mapping(page);
+	if (test_bit(AS_ENOSPC, &mapping->flags) ||
+	    test_bit(AS_EIO, &mapping->flags))
 		goto out_launder;
 
-	ret = 0;
 	if (!nfs_pageio_add_request(pgio, req)) {
 		ret = pgio->pg_error;
 		/*
 		 * Remove the problematic req upon fatal errors on the server
 		 */
 		if (nfs_error_is_fatal(ret)) {
-			nfs_context_set_write_error(req->wb_context, ret);
 			if (nfs_error_is_fatal_on_server(ret))
 				goto out_launder;
 		} else
@@ -645,7 +652,7 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 out:
 	return ret;
 out_launder:
-	nfs_write_error_remove_page(req);
+	nfs_write_error(req, ret);
 	return 0;
 }
 
@@ -998,7 +1005,7 @@ static void nfs_write_completion(struct nfs_pgio_header *hdr)
 		if (test_bit(NFS_IOHDR_ERROR, &hdr->flags) &&
 		    (hdr->good_bytes < bytes)) {
 			nfs_set_pageerror(page_file_mapping(req->wb_page));
-			nfs_context_set_write_error(req->wb_context, hdr->error);
+			nfs_mapping_set_error(req->wb_page, hdr->error);
 			goto remove_req;
 		}
 		if (nfs_write_need_commit(hdr)) {
@@ -1422,14 +1429,10 @@ static void nfs_async_write_error(struct list_head *head, int error)
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
-		if (nfs_error_is_fatal(error)) {
-			nfs_context_set_write_error(req->wb_context, error);
-			if (nfs_error_is_fatal_on_server(error)) {
-				nfs_write_error_remove_page(req);
-				continue;
-			}
-		}
-		nfs_redirty_request(req);
+		if (nfs_error_is_fatal(error))
+			nfs_write_error(req, error);
+		else
+			nfs_redirty_request(req);
 	}
 }
 
@@ -1843,9 +1846,10 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 			req->wb_bytes,
 			(long long)req_offset(req));
 		if (status < 0) {
-			nfs_context_set_write_error(req->wb_context, status);
-			if (req->wb_page)
+			if (req->wb_page) {
+				nfs_mapping_set_error(req->wb_page, status);
 				nfs_inode_remove_request(req);
+			}
 			dprintk_cont(", error = %d\n", status);
 			goto next;
 		}
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 40e30376130b..d363d5765cdf 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -76,7 +76,6 @@ struct nfs_open_context {
 	fmode_t mode;
 
 	unsigned long flags;
-#define NFS_CONTEXT_ERROR_WRITE		(0)
 #define NFS_CONTEXT_RESEND_WRITES	(1)
 #define NFS_CONTEXT_BAD			(2)
 #define NFS_CONTEXT_UNLOCK	(3)
-- 
2.20.1

