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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60F25C282DE
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2216820896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="a05ns/hQ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726495AbfDGSBu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:50 -0400
Received: from mail-io1-f65.google.com ([209.85.166.65]:42062 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726489AbfDGSBu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:50 -0400
Received: by mail-io1-f65.google.com with SMTP id c4so9065348ioh.9
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=JgZE32NOgaT2yq68BP7si39vU96kDdtyBeHD888N6Po=;
        b=a05ns/hQZfoCuqZSB9M5rC0EmHa82+EpwgEV+YPj3DtBKoGEqQ9MOFC4ooTWu4qpqu
         fo/6eH50izfvhl90Up8+YYBykwH0vh4wS8e8dF2CKH0C0d5FYjCp+4O4b6uaHEK9zguq
         o6/yqJlUJ5JVNn882tDIQZp778ALJqvYsi7599qbRq4GGqFgvXO+zhpmMG13OaO9sIoH
         UQso1tjZS9ZF8Qz5596rTe9r/pNhRofxSdnmui5mR3ELik6MN/2zRKlHE5dZ8B22n5tL
         +ZqAA89/+slLY79Y1m1H6NCrfdhAywF37JX/I21cXpg61vuSbB8UWJvs+CbWKo/ATJ/W
         wmWA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=JgZE32NOgaT2yq68BP7si39vU96kDdtyBeHD888N6Po=;
        b=HxYmxom2ez1uYDKUdMghtpUP5GZPMn5r3CTTkkFc3B6A63Q6WferirHCWc0eQICdFs
         WcUuuV2sqj9k0CWf94XKGdkETo2q582PerGLns9LFpUQYUFyRq64be0w/Ftl4Zpl8VKc
         LSAICEweAw8Iscv1tj/9DjJMe37K/TqRi4/FKGZdpVqd/Ws6FWAoqRDSh/8adeLCQQaP
         Fcv3JSt9SZ8VMfKVjdpj1jK/LpW1qczYklJxXQJuUc0mBSwFDBq2BODTBfEY4tbyks5/
         iTXGU/4TXLvLx4uEnGe6mERTpi9ZlGxWC7I6XHRNwvg/BWtEMHF3AufOlBUV/ZAqbHej
         4tww==
X-Gm-Message-State: APjAAAXjtPJdF0wEhKNljl4bHLO89zJ9TvRvctu3jNNHvaDWdCSrzMcl
        PqnEUO3NK1Ae4ly8I76nrQ==
X-Google-Smtp-Source: APXvYqwiew621zwpanCQUZgAScqo0hBwCJX3AEBdB+luScFHW2YLS+hTvbp/qLIHn1FeoQW8G3IJcQ==
X-Received: by 2002:a6b:4111:: with SMTP id n17mr5589619ioa.239.1554660108435;
        Sun, 07 Apr 2019 11:01:48 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.47
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:47 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 28/29] NFS: Add a helper to return a pointer to the open context of a struct nfs_page
Date:   Sun,  7 Apr 2019 13:59:11 -0400
Message-Id: <20190407175912.23528-29-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-28-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Add a helper for when we remove the explicit pointer to the open
context.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/filelayout/filelayout.c         |  4 ++--
 fs/nfs/flexfilelayout/flexfilelayout.c |  6 +++---
 fs/nfs/pagelist.c                      |  8 ++++----
 fs/nfs/pnfs.c                          |  4 ++--
 fs/nfs/pnfs.h                          |  4 ++--
 fs/nfs/read.c                          |  2 +-
 fs/nfs/write.c                         | 20 +++++++++++---------
 include/linux/nfs_page.h               |  6 ++++++
 8 files changed, 31 insertions(+), 23 deletions(-)

diff --git a/fs/nfs/filelayout/filelayout.c b/fs/nfs/filelayout/filelayout.c
index 61f46facb39c..21d9f3bfbc81 100644
--- a/fs/nfs/filelayout/filelayout.c
+++ b/fs/nfs/filelayout/filelayout.c
@@ -917,7 +917,7 @@ filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
 	pnfs_generic_pg_check_layout(pgio);
 	if (!pgio->pg_lseg) {
 		pgio->pg_lseg = fl_pnfs_update_layout(pgio->pg_inode,
-						      req->wb_context,
+						      nfs_req_openctx(req),
 						      0,
 						      NFS4_MAX_UINT64,
 						      IOMODE_READ,
@@ -944,7 +944,7 @@ filelayout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	pnfs_generic_pg_check_layout(pgio);
 	if (!pgio->pg_lseg) {
 		pgio->pg_lseg = fl_pnfs_update_layout(pgio->pg_inode,
-						      req->wb_context,
+						      nfs_req_openctx(req),
 						      0,
 						      NFS4_MAX_UINT64,
 						      IOMODE_RW,
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 9fdbcfd3e39d..9920c52bd0cd 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -873,7 +873,7 @@ ff_layout_pg_get_read(struct nfs_pageio_descriptor *pgio,
 {
 	pnfs_put_lseg(pgio->pg_lseg);
 	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
-					   req->wb_context,
+					   nfs_req_openctx(req),
 					   0,
 					   NFS4_MAX_UINT64,
 					   IOMODE_READ,
@@ -953,7 +953,7 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	pnfs_generic_pg_check_layout(pgio);
 	if (!pgio->pg_lseg) {
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
-						   req->wb_context,
+						   nfs_req_openctx(req),
 						   0,
 						   NFS4_MAX_UINT64,
 						   IOMODE_RW,
@@ -1010,7 +1010,7 @@ ff_layout_pg_get_mirror_count_write(struct nfs_pageio_descriptor *pgio,
 {
 	if (!pgio->pg_lseg) {
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
-						   req->wb_context,
+						   nfs_req_openctx(req),
 						   0,
 						   NFS4_MAX_UINT64,
 						   IOMODE_RW,
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 4a31284f411e..ce6440b79328 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -47,7 +47,7 @@ void nfs_pgheader_init(struct nfs_pageio_descriptor *desc,
 
 	hdr->req = nfs_list_entry(mirror->pg_list.next);
 	hdr->inode = desc->pg_inode;
-	hdr->cred = hdr->req->wb_context->cred;
+	hdr->cred = nfs_req_openctx(hdr->req)->cred;
 	hdr->io_start = req_offset(hdr->req);
 	hdr->good_bytes = mirror->pg_count;
 	hdr->io_completion = desc->pg_io_completion;
@@ -578,7 +578,7 @@ static void nfs_pgio_rpcsetup(struct nfs_pgio_header *hdr,
 	hdr->args.pgbase = req->wb_pgbase;
 	hdr->args.pages  = hdr->page_array.pagevec;
 	hdr->args.count  = count;
-	hdr->args.context = get_nfs_open_context(req->wb_context);
+	hdr->args.context = get_nfs_open_context(nfs_req_openctx(req));
 	hdr->args.lock_context = req->wb_lock_context;
 	hdr->args.stable  = NFS_UNSTABLE;
 	switch (how & (FLUSH_STABLE | FLUSH_COND_STABLE)) {
@@ -935,9 +935,9 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 	struct file_lock_context *flctx;
 
 	if (prev) {
-		if (!nfs_match_open_context(req->wb_context, prev->wb_context))
+		if (!nfs_match_open_context(nfs_req_openctx(req), nfs_req_openctx(prev)))
 			return false;
-		flctx = d_inode(req->wb_context->dentry)->i_flctx;
+		flctx = d_inode(nfs_req_openctx(req)->dentry)->i_flctx;
 		if (flctx != NULL &&
 		    !(list_empty_careful(&flctx->flc_posix) &&
 		      list_empty_careful(&flctx->flc_flock)) &&
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 7066cd7c7aff..83722e936b4a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2436,7 +2436,7 @@ pnfs_generic_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *r
 			rd_size = nfs_dreq_bytes_left(pgio->pg_dreq);
 
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
-						   req->wb_context,
+						   nfs_req_openctx(req),
 						   req_offset(req),
 						   rd_size,
 						   IOMODE_READ,
@@ -2463,7 +2463,7 @@ pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio,
 	pnfs_generic_pg_check_range(pgio, req);
 	if (pgio->pg_lseg == NULL) {
 		pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
-						   req->wb_context,
+						   nfs_req_openctx(req),
 						   req_offset(req),
 						   wb_size,
 						   IOMODE_RW,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index c0420b979d88..f15609c003d8 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -459,7 +459,7 @@ static inline bool
 pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
 			 struct nfs_commit_info *cinfo, u32 ds_commit_idx)
 {
-	struct inode *inode = d_inode(req->wb_context->dentry);
+	struct inode *inode = d_inode(nfs_req_openctx(req)->dentry);
 	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
 
 	if (lseg == NULL || ld->mark_request_commit == NULL)
@@ -471,7 +471,7 @@ pnfs_mark_request_commit(struct nfs_page *req, struct pnfs_layout_segment *lseg,
 static inline bool
 pnfs_clear_request_commit(struct nfs_page *req, struct nfs_commit_info *cinfo)
 {
-	struct inode *inode = d_inode(req->wb_context->dentry);
+	struct inode *inode = d_inode(nfs_req_openctx(req)->dentry);
 	struct pnfs_layoutdriver_type *ld = NFS_SERVER(inode)->pnfs_curr_ld;
 
 	if (ld == NULL || ld->clear_request_commit == NULL)
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index fad1333dbf71..c799e540ed1e 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -92,7 +92,7 @@ EXPORT_SYMBOL_GPL(nfs_pageio_reset_read_mds);
 
 static void nfs_readpage_release(struct nfs_page *req)
 {
-	struct inode *inode = d_inode(req->wb_context->dentry);
+	struct inode *inode = d_inode(nfs_req_openctx(req)->dentry);
 
 	dprintk("NFS: read done (%s/%llu %d@%lld)\n", inode->i_sb->s_id,
 		(unsigned long long)NFS_FILEID(inode), req->wb_bytes,
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 294604784f70..bc5bb9323412 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -964,7 +964,8 @@ static void
 nfs_clear_request_commit(struct nfs_page *req)
 {
 	if (test_bit(PG_CLEAN, &req->wb_flags)) {
-		struct inode *inode = d_inode(req->wb_context->dentry);
+		struct nfs_open_context *ctx = nfs_req_openctx(req);
+		struct inode *inode = d_inode(ctx->dentry);
 		struct nfs_commit_info cinfo;
 
 		nfs_init_cinfo_from_inode(&cinfo, inode);
@@ -1219,7 +1220,7 @@ int nfs_flush_incompatible(struct file *file, struct page *page)
 			return 0;
 		l_ctx = req->wb_lock_context;
 		do_flush = req->wb_page != page ||
-			!nfs_match_open_context(req->wb_context, ctx);
+			!nfs_match_open_context(nfs_req_openctx(req), ctx);
 		if (l_ctx && flctx &&
 		    !(list_empty_careful(&flctx->flc_posix) &&
 		      list_empty_careful(&flctx->flc_flock))) {
@@ -1422,7 +1423,7 @@ static void nfs_redirty_request(struct nfs_page *req)
 	/* Bump the transmission count */
 	req->wb_nio++;
 	nfs_mark_request_dirty(req);
-	set_bit(NFS_CONTEXT_RESEND_WRITES, &req->wb_context->flags);
+	set_bit(NFS_CONTEXT_RESEND_WRITES, &nfs_req_openctx(req)->flags);
 	nfs_end_page_writeback(req);
 	nfs_release_request(req);
 }
@@ -1742,7 +1743,8 @@ void nfs_init_commit(struct nfs_commit_data *data,
 		     struct nfs_commit_info *cinfo)
 {
 	struct nfs_page *first = nfs_list_entry(head->next);
-	struct inode *inode = d_inode(first->wb_context->dentry);
+	struct nfs_open_context *ctx = nfs_req_openctx(first);
+	struct inode *inode = d_inode(ctx->dentry);
 
 	/* Set up the RPC argument and reply structs
 	 * NB: take care not to mess about with data->commit et al. */
@@ -1750,7 +1752,7 @@ void nfs_init_commit(struct nfs_commit_data *data,
 	list_splice_init(head, &data->pages);
 
 	data->inode	  = inode;
-	data->cred	  = first->wb_context->cred;
+	data->cred	  = ctx->cred;
 	data->lseg	  = lseg; /* reference transferred */
 	/* only set lwb for pnfs commit */
 	if (lseg)
@@ -1763,7 +1765,7 @@ void nfs_init_commit(struct nfs_commit_data *data,
 	/* Note: we always request a commit of the entire inode */
 	data->args.offset = 0;
 	data->args.count  = 0;
-	data->context     = get_nfs_open_context(first->wb_context);
+	data->context     = get_nfs_open_context(ctx);
 	data->res.fattr   = &data->fattr;
 	data->res.verf    = &data->verf;
 	nfs_fattr_init(&data->fattr);
@@ -1846,8 +1848,8 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 			nfs_clear_page_commit(req->wb_page);
 
 		dprintk("NFS:       commit (%s/%llu %d@%lld)",
-			req->wb_context->dentry->d_sb->s_id,
-			(unsigned long long)NFS_FILEID(d_inode(req->wb_context->dentry)),
+			nfs_req_openctx(req)->dentry->d_sb->s_id,
+			(unsigned long long)NFS_FILEID(d_inode(nfs_req_openctx(req)->dentry)),
 			req->wb_bytes,
 			(long long)req_offset(req));
 		if (status < 0) {
@@ -1871,7 +1873,7 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 		/* We have a mismatch. Write the page again */
 		dprintk_cont(" mismatch\n");
 		nfs_mark_request_dirty(req);
-		set_bit(NFS_CONTEXT_RESEND_WRITES, &req->wb_context->flags);
+		set_bit(NFS_CONTEXT_RESEND_WRITES, &nfs_req_openctx(req)->flags);
 	next:
 		nfs_unlock_and_release_request(req);
 		/* Latency breaker */
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 8b36800d342d..1ea13e94feb7 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -200,4 +200,10 @@ loff_t req_offset(struct nfs_page *req)
 	return (((loff_t)req->wb_index) << PAGE_SHIFT) + req->wb_offset;
 }
 
+static inline struct nfs_open_context *
+nfs_req_openctx(struct nfs_page *req)
+{
+	return req->wb_context;
+}
+
 #endif /* _LINUX_NFS_PAGE_H */
-- 
2.20.1

