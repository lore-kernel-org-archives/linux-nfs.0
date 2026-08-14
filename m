Received: from mail-pj1-f69.google.com (mail-pj1-f69.google.com [209.85.216.69])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1AC89476CF1
	for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 14:33:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.69
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786718003; cv=none; b=a0l5E/FiC1FA/yWJW3YhJBcWVg2JAF7IQKI4AjJh/BpuhABrzxGH2aWh8NTnXv412adeZO+4RHKMotiPRtfiJV1MxC19IIj2uv4y9IF/uOTZQEntRU1Dl+7G0eJjEDPFk8eatwisUO6fA76wC6zskyP16GPKUR6EAQIwrxSN0h8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786718003; c=relaxed/simple;
	bh=TmXCqyPZhqD8tZHxAFnz34BnUbGwD3NFtE9dcxrrwvs=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=nZRQUGzP8C6PAvxYD2irDtSW+4WTawcNN4589I5BlNYZEqjLEyL3Qzr5rTQe2i5728sAIIwMaJJd6OHC18LscxufcOZZOtW6+jqoDU4sT4llFys8L+QqW90KXCp5YWyuZ0Abc1pjt22yqNNowAAYh6ViZQmD3NX50/HJgSaCdnU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=oKq5Flzn; arc=none smtp.client-ip=209.85.216.69
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oKq5Flzn"
Received: by mail-pj1-f69.google.com with SMTP id 98e67ed59e1d1-38ec0f510a9so2386049a91.2
        for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 07:33:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1786717996; x=1787322796; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=0SgqAzIQu/0Bu39tyhAL9Ik5goBfz/9VI07g1fTVYzY=;
        b=oKq5FlzntHvK0Symg2Q7ZFAtfC/q3L57oSLdkLQgJc74r/meGKp/vDvu+wCuD1nwot
         FeAOWKlRmQoO/9c/RjWxQPvK/M9EfVDHHS7o+59U3V5t+ALLdm9ty/M/nrAACVFIXGWU
         x8slsx8YGGJhr6ZrwWYNSEcpoUinK2kPytxZ9+fkiUHcBvxZhQ+8s559H4GlSP7q2jOT
         iSk9XY5ulmLGfvfomNX5c7DihcZxY1P/T13YnhHjBeKRjrUKNlEu/1RS/Y/pPSkAhsLL
         h5jOLEEjmWENr/L6BW5JF/vcbmRZfFagpRsWpsSn1NPExXXfJb3xP5jyplvenwBKCKYE
         v19A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786717996; x=1787322796;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=0SgqAzIQu/0Bu39tyhAL9Ik5goBfz/9VI07g1fTVYzY=;
        b=m3fdsho1e1OJy84IzXXRdM1gjvFnn+rsah4xxYbHMYs/NGGGwjFeEtOeuWehoKynZp
         30S4IARsrP72y/aFzkSYdFDMO2dnaAzBLzJabc8Pq8vu0g7qn95BQQ/GeAKFYechpFo0
         h0eDcT5E3W2Y2pHP6q934DRBfuZWtIp1CKSYcO5jfpj3dtaQes2wJYeq/REgxHtNojMN
         EkZYSWlGtapZK71TWqEXUF8Cpw2lMCUWPtdgIz7nojEZnT6oJwkWu03ZBf3JHKP2P5rm
         1IUQrbcONkmQNt4Jv9oGyddxQzI8BqIkYYHfNxHExCVaNs6CI3LwR7oXvifeftUBhz/Q
         FicA==
X-Gm-Message-State: AOJu0Yza0yhIN5BN42SrEtfs2LwHSrDCb1SOTFOzFeHfyrG4IzEJ9YcA
	j9/79wuskv/8mKuYPWOeKClJMYrfjQgb81k9nkDqfPolzPG/AJ7lRN1My88sR53IUijwjSOY7uc
	poCtQSDWySOAKHF3yGuHx42HjmWN+Rhv/OFAkdtqkOdUOjR888KDgGzCEnDpxl5G6ncB8xdvQMX
	Ybbl0/tV347N+1UB2rtvwd0e3G0iwMntlbNbk=
X-Received: from pjab15.prod.google.com ([2002:a17:90a:100f:b0:381:171e:961c])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a17:90b:2747:b0:38e:2f21:3bb5
 with SMTP id 98e67ed59e1d1-3933baa0da9mr7909118a91.21.1786717995686; Fri, 14
 Aug 2026 07:33:15 -0700 (PDT)
Date: Fri, 14 Aug 2026 14:32:55 +0000
In-Reply-To: <20260814143255.861084-1-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20260814143255.861084-1-praan@google.com>
X-Mailer: git-send-email 2.55.0.691.gc56d675ccc-goog
Message-ID: <20260814143255.861084-6-praan@google.com>
Subject: [PATCH v6 5/5] nfs: introduce nfs_direct_extract_pages helper
From: Pranjal Shrivastava <praan@google.com>
To: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org, 
	Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	linux-pci@vger.kernel.org, linux-rdma@vger.kernel.org, 
	Shivaji Kant <shivajikant@google.com>, Pranjal Shrivastava <praan@google.com>
Content-Type: text/plain; charset="UTF-8"

Introduce nfs_direct_extract_pages() in direct.c to centralize page
extraction and request creation for the Direct I/O path. The helper
manages extraction from the iters and builds a list of nfs_page requests

Refactor nfs_direct_read_schedule_iovec() and
nfs_direct_write_schedule_iovec() to utilize the new helper, unifying
the extraction logic on both paths.

Signed-off-by: Pranjal Shrivastava <praan@google.com>
Reviewed-by: Shivaji Kant <shivajikant@google.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/direct.c | 130 ++++++++++++++++++++++++------------------------
 1 file changed, 64 insertions(+), 66 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index a1479fbf4f9e..76c954bbc9af 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -172,6 +172,50 @@ static void nfs_direct_release_pages(struct page **pages, unsigned int npages,
 		unpin_user_pages(pages, npages);
 }
 
+static ssize_t nfs_direct_extract_pages(struct nfs_direct_req *dreq,
+					struct iov_iter *iter,
+					size_t size, loff_t *pos,
+					struct list_head *list)
+{
+	bool pinned = iov_iter_extract_will_pin(iter);
+	struct page **pagevec = NULL;
+	ssize_t result, bytes = 0;
+	int err = 0;
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
+			err = PTR_ERR(req);
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
+	return bytes ? bytes : err;
+}
+
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
 			      struct nfs_direct_req *dreq)
 {
@@ -340,6 +384,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	ssize_t result = -EINVAL;
 	size_t requested_bytes = 0;
 	size_t rsize = max_t(size_t, NFS_SERVER(inode)->rsize, PAGE_SIZE);
+	LIST_HEAD(nfs_page_list);
 
 	nfs_pageio_init_read(&desc, dreq->inode, false,
 			     &nfs_direct_read_completion_ops);
@@ -348,44 +393,23 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
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
+		while (!list_empty(&nfs_page_list)) {
+			struct nfs_page *req = nfs_list_entry(nfs_page_list.next);
+			size_t req_len = req->wb_bytes;
+
+			nfs_list_remove_request(req);
 			if (!nfs_pageio_add_request(&desc, req)) {
 				result = desc.pg_error;
 				nfs_release_request(req);
-				i++;
+				nfs_release_request_list(&nfs_page_list);
 				break;
 			}
-			pgbase = 0;
-			bytes -= req_len;
 			requested_bytes += req_len;
-			pos += req_len;
 		}
-		if (i < npages)
-			nfs_direct_release_pages(pagevec + i, npages - i, pinned);
-		kvfree(pagevec);
 		if (result < 0)
 			break;
 	}
@@ -876,6 +900,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	ssize_t result = 0;
 	size_t requested_bytes = 0;
 	size_t wsize = max_t(size_t, NFS_SERVER(inode)->wsize, PAGE_SIZE);
+	LIST_HEAD(nfs_page_list);
 	bool defer = false;
 
 	trace_nfs_direct_write_schedule_iovec(dreq);
@@ -888,57 +913,32 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 
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
-				i++;
-				break;
-			}
-
-			pgbase = 0;
-			bytes -= req_len;
-			requested_bytes += req_len;
-			pos += req_len;
+		while (!list_empty(&nfs_page_list)) {
+			struct nfs_page *req = nfs_list_entry(nfs_page_list.next);
+			size_t req_len = req->wb_bytes;
 
+			nfs_list_remove_request(req);
 			if (defer) {
 				nfs_mark_request_commit(req, NULL, &cinfo, 0);
+				requested_bytes += req_len;
 				continue;
 			}
 
 			nfs_lock_request(req);
-			if (nfs_pageio_add_request(&desc, req))
+			if (nfs_pageio_add_request(&desc, req)) {
+				requested_bytes += req_len;
 				continue;
+			}
 
 			/* Exit on hard errors */
 			if (desc.pg_error < 0 && desc.pg_error != -EAGAIN) {
 				result = desc.pg_error;
 				nfs_unlock_and_release_request(req);
-				i++;
+				nfs_release_request_list(&nfs_page_list);
 				break;
 			}
 
@@ -949,12 +949,10 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			spin_unlock(&dreq->lock);
 			nfs_unlock_request(req);
 			nfs_mark_request_commit(req, NULL, &cinfo, 0);
+			requested_bytes += req_len;
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
2.55.0.691.gc56d675ccc-goog

