Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7D599432E9C
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 15:06:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.198
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784559984; cv=none; b=tSHC1sJZc5NrUX+w3/shtyOXO/xBVXtTS/PmudPt3IxxixJaxIXnsAYkyZ71gFHoHPcHNWd87QTQjfwLB4GNBLkqo4co82w9SEcoAa0P7eMhJe6l/mUTHlV76auYKIdjW8hVhy3KDPWkLphrGv86UE2ExgnpIN1LEvQcF54bZKU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784559984; c=relaxed/simple;
	bh=rN8ZeAOD3iV4q2ZsscdmQWM+P3gd+DLW6a5Z9hGR9ZY=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=LZ9bO/7Nc38qNOb8IAV0xQLzuKUIEU0EVv85xL/oKyqt5tvEB65XEFLkFlxpkH64ynfLecBe7c9uN7pfe/5KQsmArwEQNjICwoFiCNRcAQrq0eVNQBXs1IrL4LbEMvjaqxCbeKX1/Ba/ffHNjxFy07d0eVDHTWiUohEjUQ/3+H8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=ZauAqCrm; arc=none smtp.client-ip=209.85.215.198
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ZauAqCrm"
Received: by mail-pg1-f198.google.com with SMTP id 41be03b00d2f7-c85798977dcso12085019a12.0
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 08:06:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1784559980; x=1785164780; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=SElWhs1HXhhTA/0qZRPqck5kLRpflzqDz4YDN+8eL6I=;
        b=ZauAqCrm4JQR1uOI7HQgMbvS7Ck6ydj5ApEYqAl68kkIIIDxFXhNti4APKdLxcel9c
         GbU1JiSw5qYyo5k1xrMDVLrBVJD7ICq19OxS11xUFOjKFGMwQwOi+AH6VMHJ/6kfanMR
         B77nak+x4tX5pAdg8u7fvFsIDEQNqRsbAAc8/vhsMw+tp4MITVbLx7UvMpf5HgQUDIMK
         3zKTSJMrBTwCDTU76jnh0llNFrctBm5pG1uSYtcRzXbogBJ3o2vk4PE+U10WZEXlONDL
         btxjJfMxzN2G6oHZXc/GEbRWgWjVEiCux/+5QzKKkJmTaQHmKFtsiVAWscug2wGK295M
         gO4g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784559980; x=1785164780;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=SElWhs1HXhhTA/0qZRPqck5kLRpflzqDz4YDN+8eL6I=;
        b=lS2b0PsHuxf7N8jtDpMhev4t+wXDMof6PNipwVnfYSfxMBWnRx1pviXpS/Vp7jJDsm
         4r3YrEDcNoB6yHkp0luPT3X/HoKm2mdHWtNCREzkPyVVjWv8cwlV/q0RJngdOCe3+ncl
         Iicoy7Alinat8wZjAA8nb6M0zqdyHVb2KAQMNBJjNgiMIA2tDW7bsqFU2H3L0YZE6lr6
         fRkrCmgX8FUy4/LNWp1pY4RxuIcWznkaH8PiIHgp0quhgcCxTUz48+rz7Hy/pKQUt318
         bubM2nkOT5ujdAN61TXo+baaSlPPeO6wpovsNWwNCH3p7ZsU8pnrlupCMOxsQCtkSKCO
         ZBLQ==
X-Gm-Message-State: AOJu0YzfBiYd2ApTjyusqPvkhkHb/5fG4ABWwj+P50lLS0UfQWVnz6r+
	YIt7lnMYGiREF2AaTnsXHJ6kyxXSCPT8EDSAL/CuvfX8FeaFmUK1eUEAorE41YkMth10PgWPf/T
	2O0MeZliW7/SlHWXZgZX8XFn1HVEjxlTSLuabrwm+QKahRGbwgC1NRyztq724uc/EzFsQevCgpk
	BsMRUQlsFQAjgsDF74x9U4KdHYjwZKiJNDh8o=
X-Received: from pgax10.prod.google.com ([2002:a05:6a02:2e4a:b0:c9e:3c0b:5818])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6a21:6110:b0:3c3:a140:938a
 with SMTP id adf61e73a8af0-3c3ad947db0mr16533384637.45.1784559980051; Mon, 20
 Jul 2026 08:06:20 -0700 (PDT)
Date: Mon, 20 Jul 2026 15:05:57 +0000
In-Reply-To: <20260720150601.2702700-1-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20260720150601.2702700-1-praan@google.com>
X-Mailer: git-send-email 2.55.0.229.g6434b31f56-goog
Message-ID: <20260720150601.2702700-2-praan@google.com>
Subject: [PATCH v4 1/5] nfs: make nfs_page pin-aware
From: Pranjal Shrivastava <praan@google.com>
To: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org, 
	Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	linux-pci@vger.kernel.org, linux-rdma@vger.kernel.org, 
	Shivaji Kant <shivajikant@google.com>, Pranjal Shrivastava <praan@google.com>
Content-Type: text/plain; charset="UTF-8"

Modernizing the NFS Direct I/O path to use iov_iter_extract_pages()
introduces page pinning (GUP) instead of standard page referencing.
To handle this correctly, nfs_page must track whether it holds a
pin or a standard reference.

Introduce a new flag, PG_PINNED, to struct nfs_page. Update the creation
path (nfs_page_create_from_page and nfs_page_create_from_folio) to
accept a pinned bool and set the flag accordingly. If the page is pinned,
we skip the existing reference increment (get_page/folio_get) as the pin
itself acts as a reference.

Update nfs_clear_request() & nfs_direct_release_pages() to use
unpin_user_page() or unpin_user_folio() instead of only refcount
decrement (put_page) when PG_PINNED flag is set. Finally, ensure
subrequests inherit the pinning status from their parent request.

Signed-off-by: Pranjal Shrivastava <praan@google.com>
---
 fs/nfs/direct.c          | 22 +++++++++++++++-------
 fs/nfs/pagelist.c        | 40 ++++++++++++++++++++++++++++++----------
 fs/nfs/read.c            |  2 +-
 fs/nfs/write.c           |  2 +-
 include/linux/nfs_page.h |  3 +++
 5 files changed, 50 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e626c72495e6..19792a38c924 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -165,11 +165,17 @@ int nfs_swap_rw(struct kiocb *iocb, struct iov_iter *iter)
 	return 0;
 }
 
-static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
+static void nfs_direct_release_pages(struct page **pages, unsigned int npages,
+				     bool pinned)
 {
 	unsigned int i;
-	for (i = 0; i < npages; i++)
-		put_page(pages[i]);
+
+	if (pinned) {
+		unpin_user_pages(pages, npages);
+	} else {
+		for (i = 0; i < npages; i++)
+			put_page(pages[i]);
+	}
 }
 
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
@@ -371,7 +377,8 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
 			/* XXX do we need to do the eof zeroing found in async_filler? */
 			req = nfs_page_create_from_page(dreq->ctx, pagevec[i],
-							pgbase, pos, req_len);
+							false, pgbase, pos,
+							req_len);
 			if (IS_ERR(req)) {
 				result = PTR_ERR(req);
 				break;
@@ -386,7 +393,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			requested_bytes += req_len;
 			pos += req_len;
 		}
-		nfs_direct_release_pages(pagevec, npages);
+		nfs_direct_release_pages(pagevec, npages, false);
 		kvfree(pagevec);
 		if (result < 0)
 			break;
@@ -907,7 +914,8 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
 
 			req = nfs_page_create_from_page(dreq->ctx, pagevec[i],
-							pgbase, pos, req_len);
+							false, pgbase, pos,
+							req_len);
 			if (IS_ERR(req)) {
 				result = PTR_ERR(req);
 				break;
@@ -950,7 +958,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			desc.pg_error = 0;
 			defer = true;
 		}
-		nfs_direct_release_pages(pagevec, npages);
+		nfs_direct_release_pages(pagevec, npages, false);
 		kvfree(pagevec);
 		if (result < 0)
 			break;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 7dd478ffc2fa..606b518fa204 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -404,20 +404,28 @@ static struct nfs_page *nfs_page_create(struct nfs_lock_context *l_ctx,
 	return req;
 }
 
-static void nfs_page_assign_folio(struct nfs_page *req, struct folio *folio)
+static void nfs_page_assign_folio(struct nfs_page *req, struct folio *folio,
+				  bool pinned)
 {
 	if (folio != NULL) {
 		req->wb_folio = folio;
-		folio_get(folio);
+		if (pinned)
+			set_bit(PG_PINNED, &req->wb_flags);
+		else
+			folio_get(folio);
 		set_bit(PG_FOLIO, &req->wb_flags);
 	}
 }
 
-static void nfs_page_assign_page(struct nfs_page *req, struct page *page)
+static void nfs_page_assign_page(struct nfs_page *req, struct page *page,
+				 bool pinned)
 {
 	if (page != NULL) {
 		req->wb_page = page;
-		get_page(page);
+		if (pinned)
+			set_bit(PG_PINNED, &req->wb_flags);
+		else
+			get_page(page);
 	}
 }
 
@@ -425,6 +433,7 @@ static void nfs_page_assign_page(struct nfs_page *req, struct page *page)
  * nfs_page_create_from_page - Create an NFS read/write request.
  * @ctx: open context to use
  * @page: page to write
+ * @pinned: true if page is pinned
  * @pgbase: starting offset within the page for the write
  * @offset: file offset for the write
  * @count: number of bytes to read/write
@@ -435,6 +444,7 @@ static void nfs_page_assign_page(struct nfs_page *req, struct page *page)
  */
 struct nfs_page *nfs_page_create_from_page(struct nfs_open_context *ctx,
 					   struct page *page,
+					   bool pinned,
 					   unsigned int pgbase, loff_t offset,
 					   unsigned int count)
 {
@@ -446,7 +456,7 @@ struct nfs_page *nfs_page_create_from_page(struct nfs_open_context *ctx,
 	ret = nfs_page_create(l_ctx, pgbase, offset >> PAGE_SHIFT,
 			      offset_in_page(offset), count);
 	if (!IS_ERR(ret)) {
-		nfs_page_assign_page(ret, page);
+		nfs_page_assign_page(ret, page, pinned);
 		nfs_page_group_init(ret, NULL);
 	}
 	nfs_put_lock_context(l_ctx);
@@ -457,6 +467,7 @@ struct nfs_page *nfs_page_create_from_page(struct nfs_open_context *ctx,
  * nfs_page_create_from_folio - Create an NFS read/write request.
  * @ctx: open context to use
  * @folio: folio to write
+ * @pinned: true if folio is pinned
  * @offset: starting offset within the folio for the write
  * @count: number of bytes to read/write
  *
@@ -466,6 +477,7 @@ struct nfs_page *nfs_page_create_from_page(struct nfs_open_context *ctx,
  */
 struct nfs_page *nfs_page_create_from_folio(struct nfs_open_context *ctx,
 					    struct folio *folio,
+					    bool pinned,
 					    unsigned int offset,
 					    unsigned int count)
 {
@@ -476,7 +488,7 @@ struct nfs_page *nfs_page_create_from_folio(struct nfs_open_context *ctx,
 		return ERR_CAST(l_ctx);
 	ret = nfs_page_create(l_ctx, offset, folio->index, offset, count);
 	if (!IS_ERR(ret)) {
-		nfs_page_assign_folio(ret, folio);
+		nfs_page_assign_folio(ret, folio, pinned);
 		nfs_page_group_init(ret, NULL);
 	}
 	nfs_put_lock_context(l_ctx);
@@ -498,9 +510,11 @@ nfs_create_subreq(struct nfs_page *req,
 			      offset, count);
 	if (!IS_ERR(ret)) {
 		if (folio)
-			nfs_page_assign_folio(ret, folio);
+			nfs_page_assign_folio(ret, folio,
+					      test_bit(PG_PINNED, &req->wb_flags));
 		else
-			nfs_page_assign_page(ret, page);
+			nfs_page_assign_page(ret, page,
+					     test_bit(PG_PINNED, &req->wb_flags));
 		/* find the last request */
 		for (last = req->wb_head;
 		     last->wb_this_page != req->wb_head;
@@ -552,11 +566,17 @@ static void nfs_clear_request(struct nfs_page *req)
 	struct nfs_open_context *ctx;
 
 	if (folio != NULL) {
-		folio_put(folio);
+		if (test_and_clear_bit(PG_PINNED, &req->wb_flags))
+			unpin_user_folio(folio, 1);
+		else
+			folio_put(folio);
 		req->wb_folio = NULL;
 		clear_bit(PG_FOLIO, &req->wb_flags);
 	} else if (page != NULL) {
-		put_page(page);
+		if (test_and_clear_bit(PG_PINNED, &req->wb_flags))
+			unpin_user_page(page);
+		else
+			put_page(page);
 		req->wb_page = NULL;
 	}
 	if (l_ctx != NULL) {
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 2b70bd2b934b..e7497b029d6c 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -324,7 +324,7 @@ int nfs_read_add_folio(struct nfs_pageio_descriptor *pgio,
 
 	aligned_len = min_t(unsigned int, ALIGN(len, rsize), fsize);
 
-	new = nfs_page_create_from_folio(ctx, folio, 0, aligned_len);
+	new = nfs_page_create_from_folio(ctx, folio, false, 0, aligned_len);
 	if (IS_ERR(new)) {
 		error = PTR_ERR(new);
 		if (nfs_netfs_folio_unlock(folio))
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d2b03ceaeb4f..e565b811d8b7 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1088,7 +1088,7 @@ static struct nfs_page *nfs_setup_write_request(struct nfs_open_context *ctx,
 	req = nfs_try_to_update_request(folio, offset, bytes);
 	if (req != NULL)
 		goto out;
-	req = nfs_page_create_from_folio(ctx, folio, offset, bytes);
+	req = nfs_page_create_from_folio(ctx, folio, false, offset, bytes);
 	if (IS_ERR(req))
 		goto out;
 	nfs_inode_add_request(req);
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 4b9a35dbc062..fd7aafe7cb54 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -38,6 +38,7 @@ enum {
 	PG_REMOVE,		/* page group sync bit in write path */
 	PG_CONTENDED1,		/* Is someone waiting for a lock? */
 	PG_CONTENDED2,		/* Is someone waiting for a lock? */
+	PG_PINNED,		/* page is pinned by GUP */
 };
 
 struct nfs_inode;
@@ -125,11 +126,13 @@ struct nfs_pageio_descriptor {
 
 extern struct nfs_page *nfs_page_create_from_page(struct nfs_open_context *ctx,
 						  struct page *page,
+						  bool pinned,
 						  unsigned int pgbase,
 						  loff_t offset,
 						  unsigned int count);
 extern struct nfs_page *nfs_page_create_from_folio(struct nfs_open_context *ctx,
 						   struct folio *folio,
+						   bool pinned,
 						   unsigned int offset,
 						   unsigned int count);
 extern	void nfs_release_request(struct nfs_page *);
-- 
2.55.0.229.g6434b31f56-goog

