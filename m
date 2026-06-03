Received: from mail-pf1-f201.google.com (mail-pf1-f201.google.com [209.85.210.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F1EC37EFED
	for <linux-nfs@vger.kernel.org>; Wed,  3 Jun 2026 05:30:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780464649; cv=none; b=Zp9D4X+pD/4jXzQondhZWzFbV/cbP6iyJGNaH/jA5cdH8p7tMRzwyImEmeYNAj8dYCGLncP1vYo4+D/0MymI9ezwnvlvz8gcR9oQtTvC3D84bhicJVOJiAploaG/T+mMOKUQX2mzVxXmdo2ZedH2gFroM8oTb8DaSab+ytgUWmg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780464649; c=relaxed/simple;
	bh=F7Z5I+pyKFwDybP/t3Ww4dr8KAfYZlgIyokwfDtnetA=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=TZmWdSaY/PiyWbIg+rWqugiCZHhA1XWWbmhpS5mnXZgUz9tEc3BACMa8AyA3awmwxw+BpEQ7xkxOfasSSp+wr0oEyzoJZHOpFyqMbX8J/RSOg+OwZo6uvnpSXsiaXtisR5K6Cka3xUzLLyuMREGGIoSlfqN4iOS/SGK+EFoUZPw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=of6S7SSD; arc=none smtp.client-ip=209.85.210.201
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="of6S7SSD"
Received: by mail-pf1-f201.google.com with SMTP id d2e1a72fcca58-842446a3851so1718748b3a.0
        for <linux-nfs@vger.kernel.org>; Tue, 02 Jun 2026 22:30:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1780464647; x=1781069447; darn=vger.kernel.org;
        h=cc:to:from:subject:message-id:references:mime-version:in-reply-to
         :date:from:to:cc:subject:date:message-id:reply-to;
        bh=GUQHqwTSDbwIIIprX7FqQUC2KcYc7JrnlEpTv2eo5IY=;
        b=of6S7SSDZJfBv6njSe0sisqVcAKXUILLVBTVo9RXY1KfLLt3JYRnICx/8FimlwFRfa
         XbkdfDxC6Q0DNSqRBRfrdRw6He0TOgJd06kciSKGhmBAtj54GxErv32DWB2jQqrrvVdB
         SF/bJqlEBj4J5gxgvNwLD0Wxm7eabRFB/Ad3zER8xpIIQxdrb8lGj5Y2pYJa/cys4Bg3
         uFhxkK1DJYziVOCbSyEQs30Py4hLq3fwetc9rkbtElY1sIiWleSbx85oICuq9sI2Z/gt
         vxHqZhdJZL5qgn9G75kCwctqh2p5PnhTYxNbLYZWbqYDlvGQOopKb5gR0J1QhyioOwn8
         iBFQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1780464647; x=1781069447;
        h=cc:to:from:subject:message-id:references:mime-version:in-reply-to
         :date:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=GUQHqwTSDbwIIIprX7FqQUC2KcYc7JrnlEpTv2eo5IY=;
        b=BBPhId4esjL7iW445nVLbJjrIWkBjdX5EcAdiKb2E78X1w6zjWRLjnjEqryGvKo6BR
         yRnMOukHDU21DjqSdtOXw8KIZsBFhgeURma9zEL/13RNGSel6OU9v1KGEr9IYhD73Jl0
         dWog9FQJCkYBYTp9VxWUH8DXzUo3zASwE5N0YzVTxH7rCEg60kGpjCkvrNQKIvC0OLx2
         ln4NkzCov1g/r4E0Vul98hFK4sUNZxQoFhlZkybETa5BrA5yrxxEZPnntBbDHx/NM+bX
         UpiVTHQBdZVsBjuZGhbJZWkxgHuL1qrhRSpvbHkaANbUTmmgfm+M4geqcK+Je+rCuZQs
         2ZKQ==
X-Gm-Message-State: AOJu0Yxx7G3wM/bA0ZEM7Xbs8XuTvlmB7nlCL9OgCjLacFVqMRWHkbIr
	kAmJ8yVTzdTZo6qYEpjtjjNcsWESROPgA7lSB5a1um81zrMP4Zi3bv8v85rMXl6zuUi1H/17y3y
	kuLWnbJ/P5eG9FxMnFR8PPWGqWYshxMmhx21cq4dAWFyxW3HAOPOdlbvAMV6j+CFO5bfyXV1Fbl
	NSRzgQaWQTe76u2HHFx7HDgrvUSQKFBQUwQA4=
X-Received: from pfbfj21.prod.google.com ([2002:a05:6a00:3a15:b0:842:2abf:9656])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6a00:887:b0:842:3d8d:bab5
 with SMTP id d2e1a72fcca58-84284fbd413mr1961332b3a.37.1780464646850; Tue, 02
 Jun 2026 22:30:46 -0700 (PDT)
Date: Wed,  3 Jun 2026 05:30:31 +0000
In-Reply-To: <20260603053033.3300318-1-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20260603053033.3300318-1-praan@google.com>
X-Mailer: git-send-email 2.54.0.1013.g208068f2d8-goog
Message-ID: <20260603053033.3300318-6-praan@google.com>
Subject: [PATCH v1 5/7] nfs: introduce nfs_direct_extract_pages helper
From: Pranjal Shrivastava <praan@google.com>
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, Christoph Hellwig <hch@lst.de>, 
	Christoph Hellwig <hch@infradead.org>, Shivaji Kant <shivajikant@google.com>, 
	Pranjal Shrivastava <praan@google.com>
Content-Type: text/plain; charset="UTF-8"

Introduce nfs_direct_extract_pages() in direct.c to centralize page
extraction and request creation for the Direct I/O path. The helper
manages extraction from the iters and builds a list of nfs_page requests

Refactor nfs_direct_read_schedule_iovec() and
nfs_direct_write_schedule_iovec() to utilize the new helper, unifying
the extraction logic on both paths.

Signed-off-by: Pranjal Shrivastava <praan@google.com>
---
 fs/nfs/direct.c | 122 +++++++++++++++++++++++-------------------------
 1 file changed, 59 insertions(+), 63 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index b6aaa5f80241..59002c150f23 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -178,6 +178,50 @@ static void nfs_direct_release_pages(struct page **pages, unsigned int npages,
 	}
 }
 
+static ssize_t nfs_direct_extract_pages(struct nfs_direct_req *dreq,
+					 struct iov_iter *iter,
+					 size_t size, loff_t *pos,
+					 struct list_head *list)
+{
+	bool pinned = iov_iter_extract_will_pin(iter);
+	struct page **pagevec = NULL;
+	ssize_t result, bytes = 0;
+	unsigned int npages, i;
+	size_t pgbase;
+
+	result = iov_iter_extract_pages(iter, &pagevec, size, ~0U, 0, &pgbase);
+	if (result <= 0)
+		return result;
+
+	npages = (result + pgbase + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	for (i = 0; i < npages; i++) {
+		struct nfs_page *req;
+		unsigned int req_len = min_t(size_t, result - bytes, PAGE_SIZE - pgbase);
+
+		req = nfs_page_create_from_page(dreq->ctx, pagevec[i],
+						pinned, pgbase, *pos,
+						req_len);
+		if (IS_ERR(req)) {
+			if (!bytes)
+				bytes = PTR_ERR(req);
+			break;
+		}
+
+		list_add_tail(&req->wb_list, list);
+		pgbase = 0;
+		bytes += req_len;
+		*pos += req_len;
+	}
+
+	if (i < npages) {
+		iov_iter_revert(iter, result - bytes);
+		nfs_direct_release_pages(pagevec + i, npages - i, pinned);
+	}
+
+	kvfree(pagevec);
+	return bytes;
+}
+
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
 			      struct nfs_direct_req *dreq)
 {
@@ -346,6 +390,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	ssize_t result = -EINVAL;
 	size_t requested_bytes = 0;
 	size_t rsize = max_t(size_t, NFS_SERVER(inode)->rsize, PAGE_SIZE);
+	LIST_HEAD(nfs_page_list);
 
 	nfs_pageio_init_read(&desc, dreq->inode, false,
 			     &nfs_direct_read_completion_ops);
@@ -354,43 +399,22 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	inode_dio_begin(inode);
 
 	while (iov_iter_count(iter)) {
-		struct page **pagevec = NULL;
-		size_t bytes;
-		size_t pgbase;
-		unsigned npages, i;
-		bool pinned = iov_iter_extract_will_pin(iter);
-
-		result = iov_iter_extract_pages(iter, &pagevec,
-						rsize, ~0U, 0, &pgbase);
+		result = nfs_direct_extract_pages(dreq, iter, rsize, &pos, &nfs_page_list);
 		if (result < 0)
 			break;
 
-		bytes = result;
-		npages = (result + pgbase + PAGE_SIZE - 1) / PAGE_SIZE;
-		for (i = 0; i < npages; i++) {
-			struct nfs_page *req;
-			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
-			/* XXX do we need to do the eof zeroing found in async_filler? */
-			req = nfs_page_create_from_page(dreq->ctx, pagevec[i],
-							pinned, pgbase, pos,
-							req_len);
-			if (IS_ERR(req)) {
-				result = PTR_ERR(req);
-				break;
-			}
+		requested_bytes += result;
+		while (!list_empty(&nfs_page_list)) {
+			struct nfs_page *req = nfs_list_entry(nfs_page_list.next);
+
+			nfs_list_remove_request(req);
 			if (!nfs_pageio_add_request(&desc, req)) {
 				result = desc.pg_error;
 				nfs_release_request(req);
+				nfs_release_request_list(&nfs_page_list);
 				break;
 			}
-			pgbase = 0;
-			bytes -= req_len;
-			requested_bytes += req_len;
-			pos += req_len;
 		}
-		if (i < npages)
-			nfs_direct_release_pages(pagevec + i, npages - i, pinned);
-		kvfree(pagevec);
 		if (result < 0)
 			break;
 	}
@@ -873,6 +897,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	ssize_t result = 0;
 	size_t requested_bytes = 0;
 	size_t wsize = max_t(size_t, NFS_SERVER(inode)->wsize, PAGE_SIZE);
+	LIST_HEAD(nfs_page_list);
 	bool defer = false;
 
 	trace_nfs_direct_write_schedule_iovec(dreq);
@@ -885,42 +910,15 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 
 	NFS_I(inode)->write_io += iov_iter_count(iter);
 	while (iov_iter_count(iter)) {
-		struct page **pagevec = NULL;
-		size_t bytes;
-		size_t pgbase;
-		unsigned npages, i;
-		bool pinned = iov_iter_extract_will_pin(iter);
-
-		result = iov_iter_extract_pages(iter, &pagevec,
-						wsize, ~0U, 0, &pgbase);
+		result = nfs_direct_extract_pages(dreq, iter, wsize, &pos, &nfs_page_list);
 		if (result < 0)
 			break;
 
-		bytes = result;
-		npages = (result + pgbase + PAGE_SIZE - 1) / PAGE_SIZE;
-		for (i = 0; i < npages; i++) {
-			struct nfs_page *req;
-			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
-
-			req = nfs_page_create_from_page(dreq->ctx, pagevec[i],
-							pinned, pgbase, pos,
-							req_len);
-			if (IS_ERR(req)) {
-				result = PTR_ERR(req);
-				break;
-			}
-
-			if (desc.pg_error < 0) {
-				nfs_free_request(req);
-				result = desc.pg_error;
-				break;
-			}
-
-			pgbase = 0;
-			bytes -= req_len;
-			requested_bytes += req_len;
-			pos += req_len;
+		requested_bytes += result;
+		while (!list_empty(&nfs_page_list)) {
+			struct nfs_page *req = nfs_list_entry(nfs_page_list.next);
 
+			nfs_list_remove_request(req);
 			if (defer) {
 				nfs_mark_request_commit(req, NULL, &cinfo, 0);
 				continue;
@@ -934,6 +932,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			if (desc.pg_error < 0 && desc.pg_error != -EAGAIN) {
 				result = desc.pg_error;
 				nfs_unlock_and_release_request(req);
+				nfs_release_request_list(&nfs_page_list);
 				break;
 			}
 
@@ -947,9 +946,6 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			desc.pg_error = 0;
 			defer = true;
 		}
-		if (i < npages)
-			nfs_direct_release_pages(pagevec + i, npages - i, pinned);
-		kvfree(pagevec);
 		if (result < 0)
 			break;
 	}
-- 
2.54.0.1013.g208068f2d8-goog

