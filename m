Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8CB874AC167
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 17:10:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790269839; cv=none; b=tZCB76CTV2cammlV4AFMK6GPvM1+HfaAr5QIIH8DyxLybKpLAHalvtYBQJlfs8Mn8XO1BRWZBl5t9ceiYbVKOwfO9r/HYue0KmZFkLXqP4Xa3NkiihF4CuRWhp4F/+y0QDZocc0vibipgrBq+sRCrl2cjRfkwhkKrNjMKZvD8eA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790269839; c=relaxed/simple;
	bh=f6Bj0YIXRzgweaY0EyEFHmktZWOH4cUTeM8bZ936VJo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=AOZvJGvnPql+p7xJ54XQacEWu7g/oZ3aHutegg/KcR9apeDl9MzLQ2NhjsdYPxjd8XROpy4ORHUBoM6mKlYZW773fB7sDPAsM/doMSduYLF0fc2uCzN5cyxcYDjajvrhRL3WD59c/Z3Oyu5nPRJ3iH5mbqAp4A+WQ1DUXno66NE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nPNaH0YS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nPNaH0YS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E94811F00893;
	Thu, 24 Sep 2026 17:10:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790269838;
	bh=l5+LSl+AQwo7ECt0wAvJAerj1HrIXmTUVtqiNjCuuwE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=nPNaH0YS2mKeutx2fLW9yrDM/vmYuB9wdRt8n51UvoV7Fd2ZVNFKWtv+BvqhkR1Cf
	 5yKnYrNIx7/xvX2QP8+D61+rUdMcAOQDP3zsvnypx3dOOi/VhqMkq9rz9YEOKMR2ae
	 EyXCf/XVnOase5vIROs+2PKzy4V5rFEg8LZTeKoHWoldPYJQcKAptm5c2VTbSTJ5Xd
	 xLuqUGEwLryNo+M7nxRwYDS9MihvpBp8kAwketvKzAgJzsrML2n0r2nf/9dWub5Dz4
	 i78bRlAB6m2PqmXtwLwlfexNouXWBrB9duaZENSl034Pp5UCr8pQUwBrlhhUsT4n2A
	 NV+RUAFpO4nNw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 30/33] NFSD: Refactor NFSv3 directory entry encoding
Date: Thu, 24 Sep 2026 13:10:09 -0400
Message-ID: <20260924171012.3978-31-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260924171012.3978-1-cel@kernel.org>
References: <20260924171012.3978-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The current synopsis of svcxdr_encode_entry3_common() takes a
"struct nfsd3_readdirres" argument, which is common to the NFSv3
READDIR and READDIRPLUS procedures.

However, xdrgen defines two distinct argument structures for these
procedures, since they are actually two distinct RPC procedures and
have different arguments.

With both a "struct READDIR3args" and a "struct READDIRPLUS3args,"
the directory entry encoders will need to incorporate the common
entry encoding.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs3xdr.c | 70 +++++++++++++++++++++++------------------------
 1 file changed, 34 insertions(+), 36 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 279b19d5e3ac..a28c3e636284 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -306,7 +306,7 @@ compose_entry_fh(struct nfsd3_readdirres *cd, struct svc_fh *fhp,
  * @cookie: cookie to be encoded
  *
  * The buffer space for the offset cookie has already been reserved
- * by svcxdr_encode_entry3_common().
+ * by nfs3svc_encode_entry3() or nfs3svc_encode_entryplus3().
  */
 void nfs3svc_encode_cookie3(struct xdr_stream *xdr, unsigned int pos,
 			    u64 cookie)
@@ -318,29 +318,6 @@ void nfs3svc_encode_cookie3(struct xdr_stream *xdr, unsigned int pos,
 	write_bytes_to_xdr_buf(xdr->buf, pos, &wire_cookie, XDR_UNIT * 2);
 }
 
-static bool
-svcxdr_encode_entry3_common(struct nfsd3_readdirres *resp, const char *name,
-			    int namlen, loff_t offset, u64 ino)
-{
-	struct xdr_buf *dirlist = &resp->dirlist;
-	struct xdr_stream *xdr = &resp->xdr;
-
-	if (xdr_stream_encode_item_present(xdr) < 0)
-		return false;
-	/* fileid */
-	if (xdr_stream_encode_u64(xdr, ino) < 0)
-		return false;
-	/* name */
-	if (xdr_stream_encode_opaque(xdr, name, min(namlen, NFS3_MAXNAMLEN)) < 0)
-		return false;
-	/* cookie */
-	resp->cookie_offset = dirlist->len;
-	if (xdr_stream_encode_u64(xdr, OFFSET_MAX) < 0)
-		return false;
-
-	return true;
-}
-
 /**
  * nfs3svc_encode_entry3 - encode one NFSv3 READDIR entry
  * @data: directory context
@@ -363,18 +340,28 @@ int nfs3svc_encode_entry3(void *data, const char *name, int namlen,
 			  loff_t offset, u64 ino, unsigned int d_type)
 {
 	struct readdir_cd *ccd = data;
-	struct nfsd3_readdirres *resp = container_of(ccd,
-						     struct nfsd3_readdirres,
-						     common);
+	struct nfsd3_readdirres *resp =
+		container_of(ccd, struct nfsd3_readdirres, common);
 	unsigned int starting_length = resp->dirlist.len;
+	struct xdr_stream *xdr = &resp->xdr;
 
 	/* The offset cookie for the previous entry */
-	nfs3svc_encode_cookie3(&resp->xdr, resp->cookie_offset, offset);
+	nfs3svc_encode_cookie3(xdr, resp->cookie_offset, offset);
 
-	if (!svcxdr_encode_entry3_common(resp, name, namlen, offset, ino))
+	if (xdr_stream_encode_item_present(xdr) < 0)
+		goto out_toosmall;
+	/* fileid */
+	if (xdr_stream_encode_u64(xdr, ino) < 0)
+		goto out_toosmall;
+	/* name */
+	if (xdr_stream_encode_opaque(xdr, name, min(namlen, NFS3_MAXNAMLEN)) < 0)
+		goto out_toosmall;
+	/* cookie */
+	resp->cookie_offset = resp->dirlist.len;
+	if (xdr_stream_encode_u64(xdr, OFFSET_MAX) < 0)
 		goto out_toosmall;
 
-	xdr_commit_encode(&resp->xdr);
+	xdr_commit_encode(xdr);
 	resp->common.err = nfs_ok;
 	return 0;
 
@@ -438,20 +425,31 @@ int nfs3svc_encode_entryplus3(void *data, const char *name, int namlen,
 			      loff_t offset, u64 ino, unsigned int d_type)
 {
 	struct readdir_cd *ccd = data;
-	struct nfsd3_readdirres *resp = container_of(ccd,
-						     struct nfsd3_readdirres,
-						     common);
+	struct nfsd3_readdirres *resp =
+		container_of(ccd, struct nfsd3_readdirres, common);
 	unsigned int starting_length = resp->dirlist.len;
+	struct xdr_stream *xdr = &resp->xdr;
 
 	/* The offset cookie for the previous entry */
-	nfs3svc_encode_cookie3(&resp->xdr, resp->cookie_offset, offset);
+	nfs3svc_encode_cookie3(xdr, resp->cookie_offset, offset);
 
-	if (!svcxdr_encode_entry3_common(resp, name, namlen, offset, ino))
+	if (xdr_stream_encode_item_present(xdr) < 0)
 		goto out_toosmall;
+	/* fileid */
+	if (xdr_stream_encode_u64(xdr, ino) < 0)
+		goto out_toosmall;
+	/* name */
+	if (xdr_stream_encode_opaque(xdr, name, min(namlen, NFS3_MAXNAMLEN)) < 0)
+		goto out_toosmall;
+	/* cookie */
+	resp->cookie_offset = resp->dirlist.len;
+	if (xdr_stream_encode_u64(xdr, OFFSET_MAX) < 0)
+		goto out_toosmall;
+
 	if (!svcxdr_encode_entry3_plus(resp, name, namlen, ino))
 		goto out_toosmall;
 
-	xdr_commit_encode(&resp->xdr);
+	xdr_commit_encode(xdr);
 	resp->common.err = nfs_ok;
 	return 0;
 
-- 
2.55.0

