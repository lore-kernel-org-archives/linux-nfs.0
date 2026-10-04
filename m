Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3969747D471
	for <linux-nfs@vger.kernel.org>; Sun,  4 Oct 2026 19:40:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791142834; cv=none; b=E2tYhmGaofgbviiWKqO3HloIphfEkADDtTBNXT/iNfNHZmIyYY1ML+2cfv6V3RfYDKvQ3rV+Jp1Yi5liFe/dB3XQKCEpmTRqDH9jjkl1V0BxNYxE1Sk8HXPHiSQpQT1V8f5qeNwmbEWJFBkYHef472Q6orCU2can1Ib+Llv8qSw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791142834; c=relaxed/simple;
	bh=SDR2Yj+Q9sFye73iMe+A6Cy0C84fxK77Kgx0ZLA/r9g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=F16s+dngQtB2Qk+KnEr1RJ6HpviUy20p5YPRJn846sxj+AYRaCTYNBSJd2xEwBQj7WGJpLKsqv2/pQBjQ0X0BOXjWrDl0MpEAkphHMGYzzuxvyp9OpIhPsDCFc8Rx1aL9Xl414bhb/iqz2m/oUJoqbs9iL5op/Lk5VjWs1mIHU0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TieJk30V; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TieJk30V"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4F51E1F00899;
	Sun,  4 Oct 2026 19:40:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791142832;
	bh=kZif9cfpUVHc/B7+7COyQc5y8Zfjpxgi4I/d6EnDYnc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=TieJk30VSh5JXGsk6WPowurVmdgkehuru5XQvzuwa0MTHZ6AX6EJzP0BcsRoJ6H3H
	 uSK+qsIwrxfq4Rk8143eceeyQXhEXKH8U3kkGPLyKyAQUbJCRt8t4bQ2Bvis1tO3/D
	 HN5Slt0OXr7VtBRNB2PFui7kUcBXL2s02Vrj6IB8Ckpx+2qvXQttIHYS8JwYJJxyCV
	 qilOuiYxaD+F3YPRwEbDZLjvrJOeJo+LdNSt+Rz1h0arjtfzdXdQQeTNFlgQ8p5QPc
	 OtfFbkNXqVRMf/gQzlqVuUSUvXs3H6zS+MHIq8pfEkydQi4suGTQy1i9mHiCqoGSMX
	 WIC3l4dctxqNg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 2/7] nfsd: account for page_base when advancing rq_next_page
Date: Sun,  4 Oct 2026 15:40:24 -0400
Message-ID: <20261004194029.10714-3-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261004194029.10714-1-cel@kernel.org>
References: <20261004194029.10714-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd4_encode_operation() sets rq_next_page from xdr->page_ptr, which
the xdr_stream advances from page_len alone. A direct read leaves the
payload at a nonzero page_base, so its last page can lie beyond the
page xdr->page_ptr names. svc_rqst_release_pages() then skips that
page, and svc_alloc_arg() hands it to the next request as a receive
buffer while the transport still references it. svc_tcp_sendmsg()
splices the page into the socket without copying it, and svcrdma
keeps only the pages below rq_next_page until Send completion. The
tail of the READ payload reaches the client overwritten with bytes
of the next request.

Derive rq_next_page from page_base and page_len, the accounting that
xdr_truncate_encode() and the transports use to locate the payload.

Currently nfsd_direct_read() stores its alignment pad in page_base
even when the read returns no payload, and the pad can exceed the
size of the rq_respages array. Set page_base only when the read
returns payload, so that the new calculation stays within the pages
offered to the read.

Fixes: d686e64e931c ("NFSD: Implement NFSD_IO_DIRECT for NFS READ")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4xdr.c | 12 +++++++++---
 fs/nfsd/vfs.c     |  7 ++++---
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 7062c84f96dd..89230b3206ac 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -6714,6 +6714,7 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 	struct svc_rqst *rqstp = resp->rqstp;
 	const struct nfsd4_operation *opdesc = op->opdesc;
 	unsigned int op_status_offset;
+	struct page **next_page;
 	nfsd4_enc encoder;
 
 	/*
@@ -6800,10 +6801,15 @@ nfsd4_encode_operation(struct nfsd4_compoundres *resp, struct nfsd4_op *op)
 			       &op->status, XDR_UNIT);
 release:
 	/*
-	 * Account for pages consumed while encoding this operation.
-	 * The xdr_stream primitives don't manage rq_next_page.
+	 * Account for pages consumed while encoding this operation. The
+	 * xdr_stream primitives don't manage rq_next_page, and
+	 * xdr->page_ptr does not account for page_base. XDR padding can
+	 * carry page_base + page_len past rq_page_end.
 	 */
-	rqstp->rq_next_page = xdr->page_ptr + 1;
+	next_page = xdr->buf->pages +
+		DIV_ROUND_UP(xdr->buf->page_base + xdr->buf->page_len,
+			     PAGE_SIZE);
+	rqstp->rq_next_page = min(next_page, rqstp->rq_page_end);
 }
 
 /**
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index e052b9163692..3f328378c805 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1143,9 +1143,6 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (host_err >= 0) {
 		unsigned int pad = offset - dio_start;
 
-		/* The returned payload starts after the pad */
-		rqstp->rq_res.page_base = pad;
-
 		/* Compute the count of bytes to be returned */
 		if (host_err > pad + *count)
 			host_err = *count;
@@ -1153,6 +1150,10 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			host_err -= pad;
 		else
 			host_err = 0;
+
+		/* The returned payload starts after the pad */
+		if (host_err)
+			rqstp->rq_res.page_base = pad;
 	} else if (unlikely(host_err == -EINVAL)) {
 		struct inode *inode = d_inode(fhp->fh_dentry);
 
-- 
2.55.0

