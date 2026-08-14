Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E85A47799F
	for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 14:33:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.199
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786718000; cv=none; b=Y9miEfRvmJdE8w+VVsILxSQc0lfhAxjRHpnvsVD17tzmTkeYrxaoXYusE8yXYLLkzTkwv5vYhztKnpsZtNIeeLht699uv4VI+zJXU/shXRTT5PeA2zV7Gg8+2gUO2LatId8AtitKKzU8OI+rDO23mDeIy+ALJMJ0uVzTjtea+v0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786718000; c=relaxed/simple;
	bh=ex6pRePhYMA39HcNB1bKP2BgdIOPCiqjQAlJZqxWR5c=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=LwiHOSGmzB5+RxDhoASEbDttOTHhDWtG1w8qhRRwCzOQ2Qg5zVFyqqSBMSBnf9rbEq9yHgiNcvuzPQ13TV34EYkI6zSQ5gvSgh+mzkIgsIzItauDiL/yGTjwSWCUKAF9bxfmnazLUdcmK2+Rz1mLywqNbdWBYdv8hcgvAWz1pkg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=n210P0bC; arc=none smtp.client-ip=209.85.210.199
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="n210P0bC"
Received: by mail-pf1-f199.google.com with SMTP id d2e1a72fcca58-8484b9fb055so2124254b3a.0
        for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 07:33:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1786717993; x=1787322793; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=HTq2Yo3MiZtOH+LV5j9JTfmNCmFQW03NdlsC4mRN3vI=;
        b=n210P0bC1sT+9vl5QbuDFZxoQQkS5rXH6iPKyBBPPE+a8ZZ6rlYtvd9vew8JK8QZBd
         N87ngX8C+ebspYbYOLKrUYRQl8qhAXAlIE2jPMxI/h1wbsFMGiTd9QrG2T47DEQmurOy
         wjphxTK+H9D5+Ae/9P/onCp2pIuLuAMFFnR8dLHnAc4Vn2uLi6lHILn1s511m+WKciaQ
         AWYNFRD34zjOui7Paf5SSCxsy/xDa1GCmuiWsM9Oa70YZzdMhMrXff3OR54YJrd29akW
         Fe6H4eilx4caj6aIK0mmcAjgE7zqMuq0/Ma7izDv21gdAzYR0SEXIfcNIaO0/XGyKGZU
         K1eg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786717993; x=1787322793;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=HTq2Yo3MiZtOH+LV5j9JTfmNCmFQW03NdlsC4mRN3vI=;
        b=nGyGS9+ikFiOB2inzksWmAeBrur14l+ga3Bo/2JYZxk3mNC1H6qUGD8SvYYFBNZM3J
         hTFa83YUVk/tMtwJZa4+Ot19feLa7jauSNeG1WsL1orIa3yaQk9aYXBx1uxPEJhLslrK
         vBZUpkprlLaZ0/gESUB1bG4lvN5z41rKhN2stNe9p/BCCkMNfKhUTJvBs3J5XY8J24/g
         UGz1VtzMp1rK/Ld9u/uPk5ttObHdSCaA6bhCj+HQB841xhbyN+IRdM2lJibf2VeM8+yQ
         7qiLAbHtsfAxL3B5+HBVWUt+yWNpvVX2iDdBm3+/qJ8nBrZXke4/gxeA0qpoAvChLVeW
         1YMA==
X-Gm-Message-State: AOJu0YzuZFwkohfqtEq5u0Y+EesUMsMmQCYimaTMgonC6MOuRo4bGJgv
	eUoB5woTvCRf79arc3CDZQzFuSyiUk4LFX8MFhcaePWaCjTswLFSwKNoMCaWESygkSC2udAj77u
	4piU58D6b0VN4tSMWHzIDfMK06VNgRDWPQBbstHx93CTgUaByKFdBnmDAme5YqJo/KeBB8Fq3Vp
	f9zS9Zzd6VWIu+PlFwD9yNw0sl2ZezdG944Aw=
X-Received: from pffy16.prod.google.com ([2002:aa7:93d0:0:b0:847:b0e2:92a3])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6a00:7487:b0:84f:dfce:966b
 with SMTP id d2e1a72fcca58-84fdfce99a7mr4924223b3a.8.1786717992732; Fri, 14
 Aug 2026 07:33:12 -0700 (PDT)
Date: Fri, 14 Aug 2026 14:32:54 +0000
In-Reply-To: <20260814143255.861084-1-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20260814143255.861084-1-praan@google.com>
X-Mailer: git-send-email 2.55.0.691.gc56d675ccc-goog
Message-ID: <20260814143255.861084-5-praan@google.com>
Subject: [PATCH v6 4/5] nfs: migrate direct I/O to iov_iter_extract_pages
From: Pranjal Shrivastava <praan@google.com>
To: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>
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
Reviewed-by: Shivaji Kant <shivajikant@google.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/direct.c | 37 +++++++++++++++++++------------------
 1 file changed, 19 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 96995736fac2..a1479fbf4f9e 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -168,14 +168,8 @@ int nfs_swap_rw(struct kiocb *iocb, struct iov_iter *iter)
 static void nfs_direct_release_pages(struct page **pages, unsigned int npages,
 				     bool pinned)
 {
-	unsigned int i;
-
-	if (pinned) {
+	if (pinned)
 		unpin_user_pages(pages, npages);
-	} else {
-		for (i = 0; i < npages; i++)
-			put_page(pages[i]);
-	}
 }
 
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
@@ -354,16 +348,17 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
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
@@ -371,7 +366,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
 			/* XXX do we need to do the eof zeroing found in async_filler? */
 			req = nfs_page_create_from_page(dreq->ctx, pagevec[i],
-							false, pgbase, pos,
+							pinned, pgbase, pos,
 							req_len);
 			if (IS_ERR(req)) {
 				result = PTR_ERR(req);
@@ -380,6 +375,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			if (!nfs_pageio_add_request(&desc, req)) {
 				result = desc.pg_error;
 				nfs_release_request(req);
+				i++;
 				break;
 			}
 			pgbase = 0;
@@ -387,7 +383,8 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 			requested_bytes += req_len;
 			pos += req_len;
 		}
-		nfs_direct_release_pages(pagevec, npages, false);
+		if (i < npages)
+			nfs_direct_release_pages(pagevec + i, npages - i, pinned);
 		kvfree(pagevec);
 		if (result < 0)
 			break;
@@ -891,13 +888,14 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 
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
 
@@ -908,7 +906,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			unsigned int req_len = min_t(size_t, bytes, PAGE_SIZE - pgbase);
 
 			req = nfs_page_create_from_page(dreq->ctx, pagevec[i],
-							false, pgbase, pos,
+							pinned, pgbase, pos,
 							req_len);
 			if (IS_ERR(req)) {
 				result = PTR_ERR(req);
@@ -918,6 +916,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			if (desc.pg_error < 0) {
 				nfs_free_request(req);
 				result = desc.pg_error;
+				i++;
 				break;
 			}
 
@@ -939,6 +938,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 			if (desc.pg_error < 0 && desc.pg_error != -EAGAIN) {
 				result = desc.pg_error;
 				nfs_unlock_and_release_request(req);
+				i++;
 				break;
 			}
 
@@ -952,7 +952,8 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
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
2.55.0.691.gc56d675ccc-goog

