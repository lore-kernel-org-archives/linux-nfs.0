Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF01C501F5E
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 12:49:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791895794; cv=none; b=SqhEKtcsf/1u5TVeCL8cpdQNctim+qnZWoGs/foKFHdktuIDMhR2y/vjSXfhbpAHvBqmBquNHmntX5sKzCH/Ez0+AJvJ0RciMdCrXkJkyfYmb9eDADn0DksusDtQbNbDTv3Yp42+3Cgg8z6/JoNPC7DdkHNcuTBWuCo0I/mPgwk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791895794; c=relaxed/simple;
	bh=PwnbpCOIne0qattGIlZk4fzTER+QJorp/0tGTju6QVY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=l4GuT0yyoQEFIFn3+S1Wf0PxW2XW64gVs9GfZ7I+vcuaRQbIKttDp9FHmOfFg8pN5LjQ6vdQ19Ax2LdmASYtNdHWbKAUSmzRllBtxb/Uo0FIYMC8KOC2r5GamK2CMrJGUrMr2rZZS8TfO+ScvDCZdRbIlAzaeB5AWx1VXlryK3k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BV3j54yo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BV3j54yo"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 58A621F00899;
	Tue, 13 Oct 2026 12:49:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791895792;
	bh=2JxPHcTa91zBpui7kTRzWfYOaR+HPEWsCoWHwt7Pws4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=BV3j54yo8oaRD3ZrBmZCvjrXhiUTwWcuJmIYVjzI9trMtB+KfjTdRC7NGPqgJ6kJq
	 2b0NvjSkw2+mAyFfbGPGdYUwz/P5e/1dslPh/Iw7e1rb2/p9yMRnFN30h5S0/fuVw6
	 mBYJwbVgnIM68Vs4FAnmvq7yJXiKuZbM9sRyk4BGjiq2IIksPHtwcTSbyRnYFWOc/n
	 ToKR83+EvoX4UwN3Hf6AvAfxnvU729tmU2R6HclTtjXj7bu2gim5sDB1BdyblOCcl5
	 k9VzhL6smWmFFEfLHih8xLADa6mv+HzPbm211r1ixlSMFgQw2qSGwRA6EJZTZmqAhx
	 YHKZhzuaksXQQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 29/34] NFSD: Refactor NFSv3 directory cookie encoding
Date: Tue, 13 Oct 2026 08:49:44 -0400
Message-ID: <20261013124944.316808-10-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261013124944.316808-1-cel@kernel.org>
References: <20261013124944.316808-1-cel@kernel.org>
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
index 307a3b195364..9d2fcb697e72 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -1549,7 +1549,7 @@ static __be32 nfsd3_proc_readdir(struct svc_rqst *rqstp)
 	resp->status = nfsd_readdir(rqstp, &resp->fh, &offset,
 				    &resp->common, nfs3svc_encode_entry3);
 	memcpy(resp->verf, argp->xdrgen.cookieverf, NFS3_COOKIEVERFSIZE);
-	nfs3svc_encode_cookie3(resp, offset);
+	nfs3svc_encode_cookie3(&resp->xdr, resp->cookie_offset, offset);
 
 	/* Recycle only pages that were part of the reply */
 	rqstp->rq_next_page = resp->xdr.page_ptr + 1;
@@ -1596,7 +1596,7 @@ static __be32 nfsd3_proc_readdirplus(struct svc_rqst *rqstp)
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
index 4c4642077342..fdb2e68e16d5 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -111,7 +111,8 @@ bool nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 void nfs3svc_release_fhandle(struct svc_rqst *);
 
-void nfs3svc_encode_cookie3(struct nfsd3_readdirres *resp, u64 offset);
+void nfs3svc_encode_cookie3(struct xdr_stream *xdr, unsigned int pos,
+			    u64 cookie);
 int nfs3svc_encode_entry3(void *data, const char *name, int namlen,
 			  loff_t offset, u64 ino, unsigned int d_type);
 int nfs3svc_encode_entryplus3(void *data, const char *name, int namlen,
-- 
2.55.0

