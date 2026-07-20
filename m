Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CA064434E3B
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 15:06:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.197
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784560011; cv=none; b=f9qx9cF467qBcgVFiRgoil60XNrZN5jE4DU+dEkQZ1Z/ZMQLoRTMZq1ms1iHm/Xids2+dCJm6hZTP0wnmRMeTS+DSRZGTIN0T+pwxxrxvWIj5qpotvGX1M+tiR0p/hogX6cesyGoCUvCwGSAiaw+G6xScUbUICFpUIEg69o7uNg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784560011; c=relaxed/simple;
	bh=cE1N3bryysgtK03efhJdxm+fcOXxenlTYhZMIyr54Dk=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=QFVKzbBGmeKUnRSMmNrjDMDkvr1QF8hkwbqgHV2qP2cnFy10318QBP4VlB4juvPlTyYJNsUWtPjqvd7BiWQNQ2snWxLVnHOVEUDsmjtwhPOqYyEDZGJ4tEkc1T0pSSOXPr0iqxsOTs2RCgoorWBbMYVHuNrggcjqAfEl+ZejzoY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=Uve1xiiD; arc=none smtp.client-ip=209.85.214.197
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Uve1xiiD"
Received: by mail-pl1-f197.google.com with SMTP id d9443c01a7336-2cacf17c7e0so99309185ad.0
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 08:06:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1784560009; x=1785164809; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=HitDsJbfPqYQGRXR79WqQVN0Cxm+fM5TpLS0CnFvhac=;
        b=Uve1xiiDBQ0/NtDEbd4Wi1CaexiBB+UlfIMrwI9pXUG9K+9ZBqh7Vil2miIuu+NyvZ
         KKzVCmdRSmgLiOAP2dvyTTesA8EDy7CZ0CScFuWvJfZHW4UpNH31UIQcoXh1bpBkVReL
         rPAtt92Wepw2VOfFR/GVNtAYE0igx526ZFX9vMRA1o9UX5mCax/1GZeRgQHA51TWhKPT
         OZy20TBBWndH6WTMLsKRMnkCsCa98MEzhP8HeJbuHL/QVe/G2ZkVJ9dSMJMa3RFkBYzJ
         m+4TFJkP4dvf2jgcQNiFfrXzZe0pDX22K1LGvXf/LyRX42nEjmY9lu4riCQI4fqPWpfH
         8Jmw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784560009; x=1785164809;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=HitDsJbfPqYQGRXR79WqQVN0Cxm+fM5TpLS0CnFvhac=;
        b=FZ4D+1HLYcHOsiHu21n2b3XpeCio4TJEFeb32NRYkNTFNvBv/OfYj0ge4eDqLFwaUL
         0IwWFUjr4zHcGwt772gkIOcIAnROnloIzQcvk3Pr+K9HYFkfhJcNwZ7lfqZy09XV0IgK
         xkSlGdpVNQR7S/WvJ5//cCzOGDw3RAQR0dv2ba5w+6qgqQXU2ab4TGV1cEVyhamv+qPX
         vT2DLbWCdPV6W9eTeNsb17GEXly7CRuFhVGnksCU1lLmUxPKgtN5zMVeUAP2Ubual72B
         NVGxddzXlCwV69OM8GPY3l32/2yK/11gbqUFRd6FfeU3TJNt8hJYM2CQq7kJKkdjRXZ4
         632A==
X-Gm-Message-State: AOJu0Yz5SYmX+yIwuxG0mMZMeJWmjV6NzOpFRpaovJHPzEklH/p18HdJ
	+5uJaL52ORjxK4ra+EJscBXgkZHKaym1d9k4BqNoP4u4PWwrqxVtnCXykOnPc7O5mmTd3EZMciJ
	O6Swbj4BOKmuVuatEoicyJfs8SJdqgXS6M8kXFxxDqQ8dnxPv5L9nGF9d3ihEXVIUgQ3CYdtwrG
	bSN7zE8e4OWR+1jZfCjQHfPVs8BdgXOwoSOQY=
X-Received: from plbbh1.prod.google.com ([2002:a17:902:a981:b0:2ce:fa1a:2684])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a17:903:2383:b0:2c9:97a7:f544
 with SMTP id d9443c01a7336-2cf34a18cefmr161701915ad.42.1784560008838; Mon, 20
 Jul 2026 08:06:48 -0700 (PDT)
Date: Mon, 20 Jul 2026 15:06:01 +0000
In-Reply-To: <20260720150601.2702700-1-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20260720150601.2702700-1-praan@google.com>
X-Mailer: git-send-email 2.55.0.229.g6434b31f56-goog
Message-ID: <20260720150601.2702700-6-praan@google.com>
Subject: [PATCH v4 5/5] nfs: introduce nfs_direct_extract_pages helper
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
 fs/nfs/direct.c | 127 ++++++++++++++++++++++++------------------------
 1 file changed, 64 insertions(+), 63 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index b9ac0a67693c..d31e4720ffff 100644
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
@@ -354,43 +399,23 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
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
@@ -881,6 +906,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	ssize_t result = 0;
 	size_t requested_bytes = 0;
 	size_t wsize = max_t(size_t, NFS_SERVER(inode)->wsize, PAGE_SIZE);
+	LIST_HEAD(nfs_page_list);
 	bool defer = false;
 
 	trace_nfs_direct_write_schedule_iovec(dreq);
@@ -893,55 +919,32 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 
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
+				nfs_release_request_list(&nfs_page_list);
 				break;
 			}
 
@@ -952,12 +955,10 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
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
2.55.0.229.g6434b31f56-goog

