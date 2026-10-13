Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4B6A7442B06
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 12:49:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791895798; cv=none; b=PSYHcVQSfHEHEEkpgmNjuph4K6qjPwLCtge3j/kBsd247Vmh2QXbo647njMvlpuHk6vwT1cggZQgsNYHU7P5kU65e2uTCfH25fdBRIUonzQyk2enbZWk3ONke2xqLgWqN6dI1McDsULd+xa0/8ciD2fuG+27E7u6EyGQDAAKobo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791895798; c=relaxed/simple;
	bh=f6Bj0YIXRzgweaY0EyEFHmktZWOH4cUTeM8bZ936VJo=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=uAAeOm8gXIByRSBuyE8YmxoyYjhCp2eQS5v7WCFlBJoxaTqw44SL2LV9zVTRtYN1K2oNeOAV+Zihihd2RDFg6fByB8HoVBadLn67cIw3UxlceC5OvxBIxrXA6LcE0oa+oRNdoH9bgmsm/X+NBRFz/hSA6RPjUpLw2x2tJrx04pw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nqs4E1ya; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nqs4E1ya"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A4C541F000FF;
	Tue, 13 Oct 2026 12:49:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791895797;
	bh=l5+LSl+AQwo7ECt0wAvJAerj1HrIXmTUVtqiNjCuuwE=;
	h=From:To:Cc:Subject:Date;
	b=nqs4E1ya5LDBOBUKjHbHH1URauOPNG9nELigtN7NN7FZ0f9lkz0OiyDLYSqdmuu1z
	 daJ1oLdNJZ4pVCnE/rbIkcKvjgZ1FpGB7XS1xUa7dAG8vVfhVB9aYkXIO4+eaLwxpv
	 ThnLeha6Trg9mUBF8yqMmKQEWAWjfW7DdPl/KQCab9DEN9aP788N7ElMieDCVx/1hr
	 fEnb81zSfmh1QmT6OWxPIaq9eUSzcUpTQblOkVdIvNkgb4PhFnNzrkA7SjL9hvIOSB
	 YW8DF1Zk61ak/hvUxIiTuN4vigjBqRVBIc+6yO/8qhHshxBDvwMOWDbr65hxHCEX5Y
	 HRIu9QvL5p8dw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 30/34] NFSD: Refactor NFSv3 directory entry encoding
Date: Tue, 13 Oct 2026 08:49:51 -0400
Message-ID: <20261013124955.316849-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
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

