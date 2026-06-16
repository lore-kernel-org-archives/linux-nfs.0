Received: from mail-pf1-f202.google.com (mail-pf1-f202.google.com [209.85.210.202])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BEA7A31E83A
	for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2026 13:40:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.202
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781617214; cv=none; b=IIg7ZkHuXPywBa9oVQN0azAshtci2Zkp0GoqCSe40b4Mgrjs5iRVrTMbDgG74C5SIR/WpOQ1xcC4q5ckxd/6Axqnm9QcyjMqJC9DVtmsyc7aJvMsUaPgrztuey2HYxf7e21yqoA2er1F35JwLdldavUZsae3egxStUqUF14Drqc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781617214; c=relaxed/simple;
	bh=+HQMNksOcX7c5Z4Lj1ZiFTOb9K6NNwdea51nx/nZUHY=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=i72YqvH6zx2UIhCb6W9kDQ4k1uV29rVDSiMo+g7jaKWVY+Ajphc5FdYRXW2QomPZnTJbTpXjDnrWg7xgn+MR8At21UvkWn3QxlTeIMsayMszOOtWCdEkm7EWwDMiFkLkPcumwxbObma9ShqGQEYEvNxYNZYzgwazryoFlkvlFYc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=JbVrMOnZ; arc=none smtp.client-ip=209.85.210.202
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="JbVrMOnZ"
Received: by mail-pf1-f202.google.com with SMTP id d2e1a72fcca58-8421ffff8a3so5898353b3a.2
        for <linux-nfs@vger.kernel.org>; Tue, 16 Jun 2026 06:40:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1781617212; x=1782222012; darn=vger.kernel.org;
        h=cc:to:from:subject:message-id:references:mime-version:in-reply-to
         :date:from:to:cc:subject:date:message-id:reply-to;
        bh=f9kNSBUvswlwhXTj/UXo/ji00jjc4pWqkan8sffXzzE=;
        b=JbVrMOnZV3TYnAhpAL136auPzSuY84xI90VUvmpz/Y1MzPEuWUSm5yz4CGSieYr4Ld
         4qN+PLFSvHZVsigatAQzqA69KA3APUbWI5J48qxs0ljxb1iO60hmJ4vbA41AWnLUDhPk
         ptu/mREzlHYDdrTaBwBYex6UVNTq1UMtG24GjjA5MYPMuxJcK+3318Tcchzthli36j4Z
         QP3PBUmhd9t5BBQjCAe2MrGaSoUZoHIbUimmkfRino0EsG7xzCR8iimPa49QNaYKCUTK
         hrhEQ3wWfZtGFoQFOOA+rHXw9xuFrOU/zJAP5wOXciViSFpvlZ88dlYTqP/9cK3uwKuy
         bDcQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1781617212; x=1782222012;
        h=cc:to:from:subject:message-id:references:mime-version:in-reply-to
         :date:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=f9kNSBUvswlwhXTj/UXo/ji00jjc4pWqkan8sffXzzE=;
        b=kN1O1NvS0ylV8oqwTiWjp0oUGaOGGot3YczIusCCugpRsX11pVXHatfPSkr9i4zYdw
         LSbVswQ+nUbq0n68YpabjOhzl9DLGmYhvzqKoOZgY9T5+r+he+DwNfGmVQ5vtwxfK+28
         obEllU52mJVtEEw3clkqYSiAbdQjXbEtMSqnpRCnb8JMCDGUekYHe4b6ubciex9mCrcR
         F2EwhvsDMqIWgmwQKhg0VvrzU+/vA7Tw4JEFa9zQcm2StMqPDkiyHUNVxfWLYMuO08R+
         p7SJBVeCnd92kbKyrVfyyPpkVW6gx8Iq5JLbppdY1J1Ju9zVxxT9eTATxKnpHQYaJ297
         QvlA==
X-Gm-Message-State: AOJu0YwiI2ImU2Dob4Vb++C5DYWClQ+cIXSE/71g5KDEqnp6lwE6PSDh
	RyTSOpp8I4IodG6zoxUbnK5e1HyqJyhFx08YWa2ECqoemeXbq3Bng9SX4/7pQHWdk1tTY2wD59m
	hfT7kjbTh9i+mcXQ9xAGuGwKsWdCVuTD2iYNruPdxhUoltUJ3tMNGwTNPys2vKjwI/kdEpv/7r8
	elnncLyNA+cHlAAz9fRWyfB+xUyXqYZN03Tcc=
X-Received: from pfbcd14.prod.google.com ([2002:a05:6a00:420e:b0:842:54be:af42])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6a00:3d48:b0:842:5c60:513
 with SMTP id d2e1a72fcca58-8434ce84647mr20718998b3a.30.1781617211619; Tue, 16
 Jun 2026 06:40:11 -0700 (PDT)
Date: Tue, 16 Jun 2026 13:39:57 +0000
In-Reply-To: <20260616134000.2733403-1-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20260616134000.2733403-1-praan@google.com>
X-Mailer: git-send-email 2.54.0.1136.gdb2ca164c4-goog
Message-ID: <20260616134000.2733403-5-praan@google.com>
Subject: [PATCH v2 4/7] nfs: migrate direct I/O to iov_iter_extract_pages
From: Pranjal Shrivastava <praan@google.com>
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, Christoph Hellwig <hch@lst.de>, 
	Christoph Hellwig <hch@infradead.org>, Shivaji Kant <shivajikant@google.com>, 
	Pranjal Shrivastava <praan@google.com>
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
2.54.0.1136.gdb2ca164c4-goog

