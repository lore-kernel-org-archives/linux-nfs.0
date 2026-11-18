Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795006303;
	b=366KesfTeiBNmJ8f/fi4zMKozmPe9iCbVrMouE8hFnVmKpx0Ehc3CnOGD619NSymFK+3
	 +uJJR4j6LISxscZLjbgIXBq0Xwod5M6zg043Xb7cBwFP+x+yBKPzvxDOeQECNGz3BaDVp
	 psLpBINzX+vY1K0wKv8sAk8EL1RvzvEgooIoHXfK4m7uFnbiUw9flC5TFJJJkA3ToSG3B
	 ZDieURpB1dymFeofoc0WYblsO3v+Lez5S7uFgSoS8z0+fSnPFN2le2Gx21w6jEeoLXSkh
	 fhi4xcXNlpJXwXnI8KKLPHu2QLHU1fTKfGHpbiiV74CQb7+i4bmd1vf5POeZNRE1C4w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795006303;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=xyG+3cs2k8qaJ1Bb3azeGYzhM3IZKQHmT6XGWbN0+a4=;
	b=L54VTWAjq2Qj6wvkLD67EEXzrexJ7wqfEgcGHLUGNKakkn6jYiW4jSqRvafcyvjHBYE7
	 +POsBhWOIO2Ja4k5ZupLScVFiyJYPewTJc9jaOxN+koKTXTFMtdRKr4OKVCl9HwoaDoiw
	 K0Rrg9b/hkBWv02XeUG5dfAc7jPAOKQNy2uf02ndszfXh1o7uY2B/djdUJJlViHJMsb2v
	 EP/3znZ4h/qIinlQTMoG/7yV1I2NvLs0dx3kNg7sM+ng1QKAgnLs/ZSDUnblpNAKk7iYC
	 o1ZHQFUrPl8HhuPAVNafWMDO+Y/qSc9AgprWfruolULgCrQhV+r09bkdlbFs48vuRbQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=HGV79hWG;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A7ACE606A330
	for <linux-nfs@vger.kernel.org>; Wed, 18 Nov 2026 12:51:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A7ACE606A330
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=HGV79hWG
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795006301;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=xyG+3cs2k8qaJ1Bb3azeGYzhM3IZKQHmT6XGWbN0+a4=;
	b=HGV79hWGOh3QgSgFmhi94L+jJ4pQelsEvkrGagMjYk/ulB9Q7PBeEXmrqCPHTx/usBKIpZ
	95+/vsuLiHavDg5+yR0myN0ggdBlTvZFEGiR573tGxPe0ZHUAVf1DwF0SOsjxOSrs2OSq2
	OrNPr833Z9/uDKogFsdUm2OfvZQ5fto=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-60-w55f3H0SOC6OtuNXeNydbA-1; Wed,
 18 Nov 2026 12:51:39 +0000
X-MC-Unique: w55f3H0SOC6OtuNXeNydbA-1
X-Mimecast-MFC-AGG-ID: w55f3H0SOC6OtuNXeNydbA_1795006298
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 0C545195606E;
	Wed, 18 Nov 2026 12:51:38 +0000 (UTC)
Received: from fs-i40c-01.fast.eng.rdu2.dc.redhat.com (fs-i40c-01.fast.eng.rdu2.dc.redhat.com [10.6.54.119])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 5C9F91801978;
	Wed, 18 Nov 2026 12:51:37 +0000 (UTC)
From: Abhinandan Ekande <aekande@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: dhowells@redhat.com,
	linux-nfs@vger.kernel.org,
	aekande@redhat.com
Subject: [PATCH v3 2/3] NFS: honour the netfs subrequest range when issuing reads
Date: Wed, 18 Nov 2026 07:51:34 -0500
Message-ID: <20261118125135.1991518-3-aekande@redhat.com>
In-Reply-To: <20261118125135.1991518-1-aekande@redhat.com>
References: <20261118125135.1991518-1-aekande@redhat.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

netfs splits the folio into folio_size/rsize subrequests. Each subrequest
calls nfs_netfs_issue_read() separately. nfs_netfs_issue_read() discards
subreq->start and subreq->len, converts them into a page index range, and
hands each folio in that range to nfs_read_add_folio(), which submits the
whole folio.

A folio larger than rsize is therefore read once per subrequest. On a
mount with rsize=4096, a 128K (order-5) folio is covered by 32
subrequests; each submits the whole folio, which nfs_pageio_add_request()
splits into 32 RPCs at pg_bsize. That is 1024 concurrent READs for one
folio, with every 4K page targeted by 32 of them, all pointing their
receive buffer at the same page.

Under sec=sys every reply carries the same plaintext in the page, so
the duplicate writes are byte-identical and only the wasted bandwidth
remains.
With sec=krb5p the payload is separately encrypted per reply, so the
bytes on the wire differ even though the data is the same, and
gss_unwrap_resp_priv() decrypts in place in rq_rcv_buf. One reply's
ciphertext lands on top of another's before it is unwrapped, and the
integrity check fails with GSS_S_FAILURE. The subrequest completes with
-EIO and netfs leaves the folio non-uptodate.

The defect dates to the netfs conversion but stayed latent at the
common case of rsize of 4096 or greater and with order-0 folios,
folio_size/rsize is 1 and each subrequest's whole folio read happens
to cover exactly the range asked for. The 'commit 49b29a573da8 ("nfs:
add support for large folios")' made folios up to order-5, which exposes
the same loop at any rsize smaller than folio.

Fix nfs_netfs_issue_read() to intersect each folio with the subrequest's
byte range and submit only that. nfs_read_add_folio() is split into a
range taking helper, nfs_read_add_folio_range(). nfs_read_add_folio()
keeps its existing behaviour, so the two legacy callers,
nfs_do_read_folio() and nfs_readahead(), are unaffected.

Once a request can cover only part of a folio,
nfs_page_group_set_uptodate() must stop marking the whole folio uptodate.
nfs_page_group_sync_on_bit() synchronises across one nfs_page group, not
across the folio's other subrequests, so a group that completes cleanly
would mark a folio that is only partly filled. Skip the marking when
netfs owns the folio.

With the patch, 30 MiB read over sec=krb5p,fsc,rsize=4096 issues exactly
7680 READs, one per page, compared to earlier every page was fetched up
to 32 times. Folio sizes and the netfs subrequest shape are unchanged.

Fixes: 000dbe0bec05 ("NFS: Convert buffered read paths to use netfs when fscache is enabled")
Cc: stable@vger.kernel.org
Assisted-by: LLM
Signed-off-by: Abhinandan Ekande <aekande@redhat.com>
---
 fs/nfs/fscache.c  | 21 ++++++++++++++----
 fs/nfs/internal.h |  4 ++++
 fs/nfs/read.c     | 56 ++++++++++++++++++++++++++++++-----------------
 3 files changed, 57 insertions(+), 24 deletions(-)

diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index 9b7fdad4a920..eb5e54406e58 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -303,12 +303,14 @@ static void nfs_netfs_issue_read(struct netfs_io_subrequest *sreq)
 	struct inode *inode = sreq->rreq->inode;
 	struct nfs_open_context *ctx = sreq->rreq->netfs_priv;
 	struct page *page;
+	unsigned long long pos = sreq->start + sreq->transferred;
+	unsigned long long end = sreq->start + sreq->len;
 	unsigned long idx;
 	pgoff_t start, last;
 	int err;
 
-	start = (sreq->start + sreq->transferred) >> PAGE_SHIFT;
-	last = ((sreq->start + sreq->len - sreq->transferred - 1) >> PAGE_SHIFT);
+	start = pos >> PAGE_SHIFT;
+	last = ((end - 1) >> PAGE_SHIFT);
 
 	nfs_pageio_init_read(&pgio, inode, false,
 			     &nfs_async_read_completion_ops);
@@ -322,8 +324,19 @@ static void nfs_netfs_issue_read(struct netfs_io_subrequest *sreq)
 	pgio.pg_netfs = netfs; /* used in completion */
 
 	xa_for_each_range(&sreq->rreq->mapping->i_pages, idx, page, start, last) {
-		/* nfs_read_add_folio() may schedule() due to pNFS layout and other RPCs  */
-		err = nfs_read_add_folio(&pgio, ctx, page_folio(page));
+		struct folio *folio = page_folio(page);
+		unsigned long long fpos = folio_pos(folio);
+		size_t fsize = folio_size(folio);
+		size_t offset, len;
+
+		/* Read only the part of the folio the subrequest asked for. */
+		offset = pos > fpos ? pos - fpos : 0;
+		len = min(end, fpos + fsize) - (fpos + offset);
+		if (!len)
+			continue;
+
+		/* nfs_read_add_folio_range() may schedule() due to pNFS layout and other RPCs  */
+		err = nfs_read_add_folio_range(&pgio, ctx, folio, offset, len);
 		if (err < 0) {
 			netfs->error = err;
 			goto out;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5af6a032f145..a4fed789e113 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -611,6 +611,10 @@ extern bool nfs_read_alloc_scratch(struct nfs_pgio_header *hdr, size_t size);
 extern int nfs_read_add_folio(struct nfs_pageio_descriptor *pgio,
 			       struct nfs_open_context *ctx,
 			       struct folio *folio);
+extern int nfs_read_add_folio_range(struct nfs_pageio_descriptor *pgio,
+				    struct nfs_open_context *ctx,
+				    struct folio *folio,
+				    size_t offset, size_t len);
 extern void nfs_pageio_complete_read(struct nfs_pageio_descriptor *pgio);
 extern void nfs_pageio_reset_read_mds(struct nfs_pageio_descriptor *pgio);
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index e7497b029d6c..8d73fbd59d7f 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -132,8 +132,16 @@ static void nfs_readpage_release(struct nfs_page *req, int error)
 
 static void nfs_page_group_set_uptodate(struct nfs_page *req)
 {
+	struct folio *folio = nfs_page_to_folio(req);
 	bool uptodate = false;
 
+	/*
+	 * When netfs owns the folio it decides when the folio becomes
+	 * uptodate; a request may cover only part of the folio.
+	 */
+	if (!nfs_netfs_folio_unlock(folio))
+		return;
+
 	nfs_page_group_lock(req);
 	if (!test_bit(PG_READ_FAILED, &req->wb_head->wb_flags) &&
 	    nfs_page_group_sync_on_bit_locked(req, PG_UPTODATE))
@@ -141,7 +149,7 @@ static void nfs_page_group_set_uptodate(struct nfs_page *req)
 	nfs_page_group_unlock(req);
 
 	if (uptodate)
-		folio_mark_uptodate(nfs_page_to_folio(req));
+		folio_mark_uptodate(folio);
 }
 
 static void nfs_page_group_mark_read_failed(struct nfs_page *req)
@@ -306,6 +314,31 @@ static void nfs_readpage_result(struct rpc_task *task,
 		nfs_readpage_retry(task, hdr);
 }
 
+int nfs_read_add_folio_range(struct nfs_pageio_descriptor *pgio,
+			     struct nfs_open_context *ctx,
+			     struct folio *folio,
+			     size_t offset, size_t len)
+{
+	struct nfs_page *new;
+	int error;
+
+	new = nfs_page_create_from_folio(ctx, folio, false, offset, len);
+	if (IS_ERR(new)) {
+		error = PTR_ERR(new);
+		if (nfs_netfs_folio_unlock(folio))
+			folio_unlock(folio);
+		return error;
+	}
+
+	if (!nfs_pageio_add_request(pgio, new)) {
+		nfs_list_remove_request(new);
+		error = pgio->pg_error;
+		nfs_readpage_release(new, error);
+		return error;
+	}
+	return 0;
+}
+
 int nfs_read_add_folio(struct nfs_pageio_descriptor *pgio,
 		       struct nfs_open_context *ctx,
 		       struct folio *folio)
@@ -314,9 +347,7 @@ int nfs_read_add_folio(struct nfs_pageio_descriptor *pgio,
 	struct nfs_server *server = NFS_SERVER(inode);
 	size_t fsize = folio_size(folio);
 	unsigned int rsize = server->rsize;
-	struct nfs_page *new;
 	unsigned int len, aligned_len;
-	int error;
 
 	len = nfs_folio_length(folio);
 	if (len == 0)
@@ -324,25 +355,10 @@ int nfs_read_add_folio(struct nfs_pageio_descriptor *pgio,
 
 	aligned_len = min_t(unsigned int, ALIGN(len, rsize), fsize);
 
-	new = nfs_page_create_from_folio(ctx, folio, false, 0, aligned_len);
-	if (IS_ERR(new)) {
-		error = PTR_ERR(new);
-		if (nfs_netfs_folio_unlock(folio))
-			folio_unlock(folio);
-		goto out;
-	}
-
 	if (len < fsize)
 		folio_zero_segment(folio, len, fsize);
-	if (!nfs_pageio_add_request(pgio, new)) {
-		nfs_list_remove_request(new);
-		error = pgio->pg_error;
-		nfs_readpage_release(new, error);
-		goto out;
-	}
-	return 0;
-out:
-	return error;
+
+	return nfs_read_add_folio_range(pgio, ctx, folio, 0, aligned_len);
 }
 
 /*
-- 
2.55.0

