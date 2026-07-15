Received: from mail-pg1-f202.google.com (mail-pg1-f202.google.com [209.85.215.202])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 163A93A5456
	for <linux-nfs@vger.kernel.org>; Wed, 15 Jul 2026 14:35:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.202
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784126154; cv=none; b=WFG2VU0T7ZRTAuMIKUOoQNYLeCPu5BqDjHHI4LQ2q7JX/oN+d9opBVI9nq3KU1Q5+CFiRVIeVTJ7mXDXsbjndftFRSIyzhcgnlUbnnwhinq7Vz4K1qf1vHr1n3egJZsRCM231OkKqTW2MyvWBZZ+CpQt013JBRBaHYibncUMt5U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784126154; c=relaxed/simple;
	bh=COkPzhT7ognhZry22mNipCk3Qu0eXEqVO7cIW/zUKi0=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=jLP3kiDzwCJrGaG7fQdcD98XQzspsCQKntI6IHaYT16A0Pd0840Adh1rUIeIz8O2gJFWdEUnp0Bh2b13KUg7+2h8paIE2awsUQUMdv1SoDFyFoY0Uc40NuQq2593GIFtK+RE6/S+tKW4+VsM2NHeFY+m5F1x+0aWZdgUJI53Efg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=BS288xGo; arc=none smtp.client-ip=209.85.215.202
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BS288xGo"
Received: by mail-pg1-f202.google.com with SMTP id 41be03b00d2f7-c96b4f58ddcso2149191a12.3
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jul 2026 07:35:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1784126151; x=1784730951; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=BcDK7Hr5wj1i7phI0FRZS+QdZSWw//OEKovKt+QGpf8=;
        b=BS288xGo6hqizCsOGR+HI4tn2QPaXwTxlJqjGkAXYkA419Ctus2pC4mrpwGwK0Izo6
         h6eHxFqKeNPz+zxU4F2NBXvy43TCwVOtnMMjuSRQuep4Ar7/tLcdG+cC0ciQmrI5zSMf
         GHsbRAw/SXrCXtCFt2OYJ5xAEDQ87Yg6x9X57lZ0O+a3eAEk4y9LJK+gpWH3ubCTFgmp
         OF+Eke+r9lkviH2SJ8N+rspGmP8CxUO1So+YbHsTugv6MSVQHmyWFZE1PnHDDvAFsUOi
         pCoBNp5viTwWkhrNdV2NCkzSoMGKPuL4iJhGSyO+xMcJdMf8xNA5MaTLhw7SC7C9x6IO
         BAPw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784126151; x=1784730951;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=BcDK7Hr5wj1i7phI0FRZS+QdZSWw//OEKovKt+QGpf8=;
        b=eXhEvA/7KaBiWeOvBRSoMoBxJYH8asYMFZag7cP67xn2MITmeRMZ8dqElgx+hiH7Ax
         0sNjcrGQ/1p4RzdtX+q1RYmGo0BRpNRSzA1gVAj71NwX97oOvhwPREdOYQs6xC4hLkHT
         6nZxYG9X500LYX9+nlt315nRIi4k8ovhVRb6giUcpy7NGdhHuiIZbe4PwKN+AKO1VsgY
         TG4aTu4XXM2HU4eSWi4ujkVV57KWdaVf4QfgfIJ8XDvG1D1FlvWw2dmT+YWMAk+hD2eB
         2wXvkcgODiMh4RxE3V91mPCcFFGUQvcxgR3itm0Dj+YiFlkXmIohuK5uRnBCUUPZ9qOG
         XcKw==
X-Forwarded-Encrypted: i=1; AHgh+RrOTbqCvv359ujEigjTDEertNWS39OuqAdTxf3Yzpj4Pmbb79tyDbuBxRtvXSqq9IHl60mF4AAjgig=@vger.kernel.org
X-Gm-Message-State: AOJu0YzHjAw/Wf8zh7fRbsgUaMP1mlzpAx5UX+37NCZgcQvwNVHxEa3E
	IVNwPsXx6lTZfuZhWkpXgbNaxk5O/2spiur2hHgrlConjcIP/JuQGwDprhs/BHWpzDsGNL3lAd8
	Klw==
X-Received: from pgmj33.prod.google.com ([2002:a63:5961:0:b0:c98:2639:852e])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6a20:3d0c:b0:3c0:c9ee:3746
 with SMTP id adf61e73a8af0-3c11078513dmr20467727637.34.1784126151354; Wed, 15
 Jul 2026 07:35:51 -0700 (PDT)
Date: Wed, 15 Jul 2026 14:35:39 +0000
In-Reply-To: <20260715143540.3597616-1-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20260715143540.3597616-1-praan@google.com>
X-Mailer: git-send-email 2.55.0.229.g6434b31f56-goog
Message-ID: <20260715143540.3597616-5-praan@google.com>
Subject: [PATCH v3 4/5] nfs: migrate direct I/O to iov_iter_extract_pages
From: Pranjal Shrivastava <praan@google.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org, 
	Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	linux-pci@vger.kernel.org, linux-rdma@vger.kernel.org, 
	Shivaji Kant <shivajikant@google.com>, Pranjal Shrivastava <praan@google.com>
Content-Type: text/plain; charset="UTF-8"

Migrate the NFS Direct I/O path away from the legacy
iov_iter_get_pages_alloc2() API to the modern iov_iter_extract_pages API.
The transition aligns NFS with the modern VFS extraction model and serves
as a preparatory step for supporting requirements such as page pinning
via GUP for DMA.

The migration fixes a bug in the Direct I/O loop where pages were being
unpinned immediately after request creation. With the new extraction
model, pins are held until the I/O is complete. Manual release in the
loop is correspondingly updated to only clean up failed pages.

Signed-off-by: Pranjal Shrivastava <praan@google.com>
---
 fs/nfs/direct.c | 26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 96995736fac2..b9ac0a67693c 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -354,16 +354,17 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	inode_dio_begin(inode);
 
 	while (iov_iter_count(iter)) {
-		struct page **pagevec;
+		struct page **pagevec = NULL;
 		size_t bytes;
 		size_t pgbase;
 		unsigned npages, i;
+		bool pinned = iov_iter_extract_will_pin(iter);
 
-		result = iov_iter_get_pages_alloc2(iter, &pagevec,
-						  rsize, &pgbase);
+		result = iov_iter_extract_pages(iter, &pagevec,
+						rsize, ~0U, 0, &pgbase);
 		if (result < 0)
 			break;
-	
+
 		bytes = result;
 		npages = (result + pgbase + PAGE_SIZE - 1) / PAGE_SIZE;
 		for (i = 0; i < npages; i++) {
@@ -371,7 +372,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
 			/* XXX do we need to do the eof zeroing found in async_filler? */
 			req = nfs_page_create_from_page(dreq->ctx, pagevec[i],
-							false, pgbase, pos,
+							pinned, pgbase, pos,
 							req_len);
 			if (IS_ERR(req)) {
 				result = PTR_ERR(req);
@@ -387,7 +388,8 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			requested_bytes += req_len;
 			pos += req_len;
 		}
-		nfs_direct_release_pages(pagevec, npages, false);
+		if (i < npages)
+			nfs_direct_release_pages(pagevec + i, npages - i, pinned);
 		kvfree(pagevec);
 		if (result < 0)
 			break;
@@ -891,13 +893,14 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 
 	NFS_I(inode)->write_io += iov_iter_count(iter);
 	while (iov_iter_count(iter)) {
-		struct page **pagevec;
+		struct page **pagevec = NULL;
 		size_t bytes;
 		size_t pgbase;
 		unsigned npages, i;
+		bool pinned = iov_iter_extract_will_pin(iter);
 
-		result = iov_iter_get_pages_alloc2(iter, &pagevec,
-						  wsize, &pgbase);
+		result = iov_iter_extract_pages(iter, &pagevec,
+						wsize, ~0U, 0, &pgbase);
 		if (result < 0)
 			break;
 
@@ -908,7 +911,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
 
 			req = nfs_page_create_from_page(dreq->ctx, pagevec[i],
-							false, pgbase, pos,
+							pinned, pgbase, pos,
 							req_len);
 			if (IS_ERR(req)) {
 				result = PTR_ERR(req);
@@ -952,7 +955,8 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			desc.pg_error = 0;
 			defer = true;
 		}
-		nfs_direct_release_pages(pagevec, npages, false);
+		if (i < npages)
+			nfs_direct_release_pages(pagevec + i, npages - i, pinned);
 		kvfree(pagevec);
 		if (result < 0)
 			break;
-- 
2.55.0.229.g6434b31f56-goog

