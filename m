Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA477531609
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:28:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790170120; cv=none; b=Dk9N8UTfaYPsTSQXGHMWqEkVZsSlMLGY6zxGGmKeiCEdoeFcwb2ZMLNRmvZYop5y50H+mHasnOtnKVmvBmxlD8mPF9AhOitVLKSqV5t5f2dKfHS7hLZcJfizHosPIvDOV4n9gorFxjM+W1zxnWnsDZCfKKTP0AoGIBrbJgP1HNM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790170120; c=relaxed/simple;
	bh=9rKc7t6pLDV+8bLW8GlYeycKS6u5w3twlZ4UIJgY4iI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=NCxVOZWi8MJ+KIS25RH3TmZY0txQn3HLlUSlz8s7DN+8DDGj6VY4vbA5xh5IzwUbLnA/UXe27HyceylE83gVotRRQmpBazL0zSVcW2FhjMSq/vC3qJxWSB6OClXf2gIMJhZfYFGU8VqSdCElKipKuJvhzoYll3Mtt4B60AzlXgE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lq4PgIIu; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lq4PgIIu"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0D4E11F00898;
	Wed, 23 Sep 2026 13:28:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790170118;
	bh=N0aaOTOOTL6LAnThNJfyoZvfWFjGorrmFpY8X9JwnVw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=lq4PgIIuinxyGlRQ3aSCQIVRGXIZDfM4fToDDWj8EOFB87rUR7QSSb6xjmZd+F3uP
	 Z3nVxMvVnkVaACFUGvglZkNuVZ6T3ZczBz2KuO9jJHd4aM6+anXUcJxnbA3Sh9MgXH
	 wWy9FIa3EsOjgtGnAlErE3jf9eIfn/BWJmBKYs0dOXI1ttrlKei0IfgFjYHCBfdYrk
	 IBQc1tsmQq8RSYDy43fRmuC72Aj3J9JrG2UW3ioQsDXg1Vp3uLZ5vgHdpCpZxZvx7M
	 dzomIGY6rvatXRQavh88PltAJ+GG+t0dI9eJsxrea+tVJ3lI1MWYDz7+CoFh5wkq8F
	 Hc42ZAdyRiBZA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 29/33] NFSD: Refactor NFSv3 directory cookie encoding
Date: Wed, 23 Sep 2026 09:28:07 -0400
Message-ID: <20260923132811.244160-30-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260923132811.244160-1-cel@kernel.org>
References: <20260923132811.244160-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The current synopsis of nfs3svc_encode_cookie3() takes a "struct
nfsd3_readdirres" argument, which is common to the NFSv3 READDIR and
READDIRPLUS procedures.

xdrgen defines two distinct argument structures for these procedures
since they are actually two distinct procedures and have different
arguments.

With a "struct READDIR3args" and a "struct READDIRPLUS3args," the
cookie3 encoder will need generic parameter types in order to be
callable from both.

Note that NFSD can't use the xdrgen-generated cookie3 encoder. This
is because directory cookies need to point to the previous directory
entry. Space for each cookie in the send buffer is reserved when
each directory entry is encoded; when the /next/ entry is encoded,
the encoder writes its offset into that reserved space.

As a clean-up, remove "resp->cookie_offset = 0;" :

- In nfs3svc_encode_entry3() and nfs3svc_encode_entryplus3(),
  immediately after calling nfs3svc_encode_cookie3(), the code calls
  svcxdr_encode_entry3_common() which sets a new resp->cookie_offset
  value. The cookie_offset value was immediately overwritten.
- In nfsd3_proc_readdir() and nfsd3_proc_readdirplus(),
  nfs3svc_encode_cookie3() is called as the last cookie encoding,
  and no further use of cookie_offset follows.
- The out_toosmall error paths in entry encoders continue to set
  resp->cookie_offset = 0

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c |  4 ++--
 fs/nfsd/nfs3xdr.c  | 22 +++++++++++-----------
 fs/nfsd/xdr3.h     |  3 ++-
 3 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index e09c2a839a1c..0316bb60b50b 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -1553,7 +1553,7 @@ static __be32 nfsd3_proc_readdir(struct svc_rqst *rqstp)
 	resp->status = nfsd_readdir(rqstp, &resp->fh, &offset,
 				    &resp->common, nfs3svc_encode_entry3);
 	memcpy(resp->verf, argp->xdrgen.cookieverf, NFS3_COOKIEVERFSIZE);
-	nfs3svc_encode_cookie3(resp, offset);
+	nfs3svc_encode_cookie3(&resp->xdr, resp->cookie_offset, offset);
 
 	/* Recycle only pages that were part of the reply */
 	rqstp->rq_next_page = resp->xdr.page_ptr + 1;
@@ -1600,7 +1600,7 @@ static __be32 nfsd3_proc_readdirplus(struct svc_rqst *rqstp)
 	resp->status = nfsd_readdir(rqstp, &resp->fh, &offset,
 				    &resp->common, nfs3svc_encode_entryplus3);
 	memcpy(resp->verf, argp->xdrgen.cookieverf, NFS3_COOKIEVERFSIZE);
-	nfs3svc_encode_cookie3(resp, offset);
+	nfs3svc_encode_cookie3(&resp->xdr, resp->cookie_offset, offset);
 
 	/* Recycle only pages that were part of the reply */
 	rqstp->rq_next_page = resp->xdr.page_ptr + 1;
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index b1a930b857d7..279b19d5e3ac 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -300,22 +300,22 @@ compose_entry_fh(struct nfsd3_readdirres *cd, struct svc_fh *fhp,
 }
 
 /**
- * nfs3svc_encode_cookie3 - Encode a directory offset cookie
- * @resp: readdir result context
- * @offset: offset cookie to encode
+ * nfs3svc_encode_cookie3 - Encode a directory cookie
+ * @xdr: stream into which to encode the cookie
+ * @pos: byte position in the stream
+ * @cookie: cookie to be encoded
  *
  * The buffer space for the offset cookie has already been reserved
  * by svcxdr_encode_entry3_common().
  */
-void nfs3svc_encode_cookie3(struct nfsd3_readdirres *resp, u64 offset)
+void nfs3svc_encode_cookie3(struct xdr_stream *xdr, unsigned int pos,
+			    u64 cookie)
 {
-	__be64 cookie = cpu_to_be64(offset);
+	__be64 wire_cookie = cpu_to_be64(cookie);
 
-	if (!resp->cookie_offset)
+	if (!pos)
 		return;
-	write_bytes_to_xdr_buf(&resp->dirlist, resp->cookie_offset, &cookie,
-			       sizeof(cookie));
-	resp->cookie_offset = 0;
+	write_bytes_to_xdr_buf(xdr->buf, pos, &wire_cookie, XDR_UNIT * 2);
 }
 
 static bool
@@ -369,7 +369,7 @@ int nfs3svc_encode_entry3(void *data, const char *name, int namlen,
 	unsigned int starting_length = resp->dirlist.len;
 
 	/* The offset cookie for the previous entry */
-	nfs3svc_encode_cookie3(resp, offset);
+	nfs3svc_encode_cookie3(&resp->xdr, resp->cookie_offset, offset);
 
 	if (!svcxdr_encode_entry3_common(resp, name, namlen, offset, ino))
 		goto out_toosmall;
@@ -444,7 +444,7 @@ int nfs3svc_encode_entryplus3(void *data, const char *name, int namlen,
 	unsigned int starting_length = resp->dirlist.len;
 
 	/* The offset cookie for the previous entry */
-	nfs3svc_encode_cookie3(resp, offset);
+	nfs3svc_encode_cookie3(&resp->xdr, resp->cookie_offset, offset);
 
 	if (!svcxdr_encode_entry3_common(resp, name, namlen, offset, ino))
 		goto out_toosmall;
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index eb4a4e9d5073..ad3cfd629494 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -118,7 +118,8 @@ bool nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 void nfs3svc_release_fhandle(struct svc_rqst *);
 
-void nfs3svc_encode_cookie3(struct nfsd3_readdirres *resp, u64 offset);
+void nfs3svc_encode_cookie3(struct xdr_stream *xdr, unsigned int pos,
+			    u64 cookie);
 int nfs3svc_encode_entry3(void *data, const char *name, int namlen,
 			  loff_t offset, u64 ino, unsigned int d_type);
 int nfs3svc_encode_entryplus3(void *data, const char *name, int namlen,
-- 
2.55.0

