Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D4EA5599A4D
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576174; cv=none; b=psejlkyDJWspegDArK5Gnm2qkLb7dSiazkhEaM57LUNvlQY8Tto4p70yd1YaUmtpuVjOYpVnfOGoGXR4TvYR2sZjK0GqcnjxKRHqBJAx+ooUlFZZMiLrxcIYX0/tVyu4lRBTdjzxHKsdmVVTr73x7V+gJRFK+QD8L8UNZMIMT0I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576174; c=relaxed/simple;
	bh=a8BT4oDLp6u9eAJl79jlTDDLUtqH80jERDlGQY+0OxE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=F4mAo47sIaSTgUKIGLoFVh+Tl91UFHZZFfR1IrLWztiCwuJd0yWR9E1HiKYtUhr9x/qVL0u4lS67KAu/nVgaIGnsHsJ25IHhWmArAIdPfkDsTsDU6elNNZ0X5LQrS/e1/Yceg9PPdFHikCsn5VKGCo4zNvMbPdSrEqogz/y+mkw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=YnSnF8q9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="YnSnF8q9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7E28C1F0089F;
	Wed, 16 Sep 2026 16:29:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576169;
	bh=IxaVyG47vH0yT6F0miXzWeLzlD4foJ1fQgnIViIs5eU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=YnSnF8q9e8W64pcph+NJ6R/W2bB+21d0WM8x6op8JzU/zRU7UZAk3M9ci5EJpzywm
	 bVLTuDnhoTO5MbP4r7in7I2BDhgcf2Nn55LaVQlS9oWInfWZOnwpTxWUJhmbShJaCs
	 fU3G7pNPWWAB4spPbrPdDwUCeAPc2b4AByYvdm7mXBWhQSraea9l704pn1zLB8Xl1S
	 wx+zQgu3JabCW8CLPmp9L0I7qt/m44RW2arJKAHDDD3OCvLUpUjxMt0B6jtpvc9N88
	 CPnMjEOsPsoFpOhvmeYfcZmaxcL82gxiY7R4AnBvg8t8R9DISH1GEFTziroBJFjHM9
	 ZGIlUMMwsQqrA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 26/27] NFSD: Refactor NFSv2 directory cookie encoding
Date: Wed, 16 Sep 2026 12:28:57 -0400
Message-ID: <20260916162859.2051-29-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260916162859.2051-1-cel@kernel.org>
References: <20260916162859.2051-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The current synopsis of nfssvc_encode_nfscookie() takes a
"struct nfsd_readdirres" argument, which is used by the NFSv2
READDIR procedure.

xdrgen defines a distinct argument structure for this procedure.
With a "struct READDIRargs," the nfscookie encoder will need
generic parameter types in order to be usable.

Note that NFSD can't use the xdrgen-generated nfscookie encoder.
This is because directory cookies need to point to the previous
directory entry. Space for each cookie in the send buffer is
reserved when each directory entry is encoded; when the /next/
entry is encoded, the encoder writes its offset into that
reserved space.

As a clean-up, remove "resp->cookie_offset = 0;" :

- In nfssvc_encode_entry(), immediately after calling
  nfssvc_encode_nfscookie(), the code calls
  svcxdr_encode_entry_common() which sets a new value for
  resp->cookie_offset. The cookie_offset value was immediately
  overwritten.
- In nfsd_proc_readdir(), nfssvc_encode_nfscookie() is called as
  the last cookie encoding, and no further use of cookie_offset
  follows.
- The out_toosmall error path in nfssvc_encode_entry() continues
  to set resp->cookie_offset = 0

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c |  2 +-
 fs/nfsd/nfsxdr.c  | 21 ++++++++++-----------
 fs/nfsd/xdr.h     |  3 ++-
 3 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 759bd3fc1254..df610fe3977d 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -1168,7 +1168,7 @@ static __be32 nfsd_proc_readdir(struct svc_rqst *rqstp)
 	resp->cookie_offset = 0;
 	resp->status = nfsd_readdir(rqstp, fhp, &offset,
 				    &resp->common, nfssvc_encode_entry);
-	nfssvc_encode_nfscookie(resp, offset);
+	nfssvc_encode_nfscookie(&resp->xdr, resp->cookie_offset, offset);
 
 	fh_put(fhp);
 	resp->status = nfsd_map_status(resp->status);
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index bc35c2fced79..3476ebe14c45 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -218,23 +218,22 @@ nfssvc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 }
 
 /**
- * nfssvc_encode_nfscookie - Encode a directory offset cookie
- * @resp: readdir result context
- * @offset: offset cookie to encode
+ * nfssvc_encode_nfscookie - Encode a directory cookie
+ * @xdr: stream into which to encode the cookie
+ * @pos: byte position in the stream
+ * @cookie: cookie to be encoded
  *
  * The buffer space for the offset cookie has already been reserved
  * by svcxdr_encode_entry_common().
  */
-void nfssvc_encode_nfscookie(struct nfsd_readdirres *resp, u32 offset)
+void nfssvc_encode_nfscookie(struct xdr_stream *xdr, unsigned int pos,
+			     u32 cookie)
 {
-	__be32 cookie = cpu_to_be32(offset);
+	__be32 wire_cookie = cpu_to_be32(cookie);
 
-	if (!resp->cookie_offset)
+	if (!pos)
 		return;
-
-	write_bytes_to_xdr_buf(&resp->dirlist, resp->cookie_offset, &cookie,
-			       sizeof(cookie));
-	resp->cookie_offset = 0;
+	write_bytes_to_xdr_buf(xdr->buf, pos, &wire_cookie, XDR_UNIT);
 }
 
 static bool
@@ -288,7 +287,7 @@ int nfssvc_encode_entry(void *data, const char *name, int namlen,
 	unsigned int starting_length = resp->dirlist.len;
 
 	/* The offset cookie for the previous entry */
-	nfssvc_encode_nfscookie(resp, offset);
+	nfssvc_encode_nfscookie(&resp->xdr, resp->cookie_offset, offset);
 
 	if (!svcxdr_encode_entry_common(resp, name, namlen, offset, ino))
 		goto out_toosmall;
diff --git a/fs/nfsd/xdr.h b/fs/nfsd/xdr.h
index 27976b372cf1..57dbf5166599 100644
--- a/fs/nfsd/xdr.h
+++ b/fs/nfsd/xdr.h
@@ -32,7 +32,8 @@ bool nfssvc_decode_fhandleargs(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_attrstatres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfssvc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
-void nfssvc_encode_nfscookie(struct nfsd_readdirres *resp, u32 offset);
+void nfssvc_encode_nfscookie(struct xdr_stream *xdr, unsigned int pos,
+			     u32 cookie);
 int nfssvc_encode_entry(void *data, const char *name, int namlen,
 			loff_t offset, u64 ino, unsigned int d_type);
 
-- 
2.55.0

