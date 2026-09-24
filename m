Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D47144ADD8A
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 17:10:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790269843; cv=none; b=KTQTNtR5ocg4Jw6ICG5qSh7dpJJpiGlLS7SnWIbb64rdaQD4eFOkaRnpbc/TSgjk1FXJr7Dh7LBFeK0zfS/VEAUeDq78Bq96wH7J1BDi9fxUaHZS3SjIdw9LRvYls3RlIJXdbddNF5xyc9sZENcCZr3eacl8Dm3Pm+PIAUkfWZc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790269843; c=relaxed/simple;
	bh=quSjFbiVII5ENWkA1mojNDaG8Su/I39h5EOBc0jz9ug=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=IdQ6ZYTd4rH4CawVqQzgXMN39ts15ubJHFkqwk2rq99GFLLexseG5lTk0bpxP/int+a/EUuTfVYTrY3Z6Ftfso27Wt5GOW3KnmmRcH+84rBit932Ka1+trcdhJJWWihav+7yeVEH8dOpEeGZW/Q6IwTDY6PIRzJPQniyjsJApkA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=etwPvL6s; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="etwPvL6s"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3DA831F00893;
	Thu, 24 Sep 2026 17:10:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790269840;
	bh=t1FwWXm6LOKMNxnCTUreHPkLk9dJUlRTulBQOA6wWRM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=etwPvL6sDFDX3IXGjzdqZahY4YP8IsbnTSg0isEX7c2L3rAlPzU8/nB1s6BuYVMJO
	 278wclDwHdOQF1Yt+p71e3IViGCpOKNbCFL7eSRiiZ6239k2PwS2eMBQuEZ8y7uq6p
	 n2KnpYSa6VxFYXiODZoOxgJS0ui1DrJ25IjaW59ISk8et6z8OJ+2lBQXmFtrERTw/A
	 hfe26YpX51GN0fVHiXph7ZRXsRCxwFlZ9bkyTyZFnNO4aHlyZQROZ618KbWiNADsCE
	 Be6bGg6u3JafhZAsAzbJ9bcdkgdXNwuzMpL11CV3gb9n7Jc5Dq/crRJalGnrlPxS5e
	 Fuz15/2mYAcFQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 33/33] NFSD: Use xdrgen XDR functions for NFSv3 READDIRPLUS results
Date: Thu, 24 Sep 2026 13:10:12 -0400
Message-ID: <20260924171012.3978-34-cel@kernel.org>
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

NFSv3 READDIRPLUS's reply is still produced by a hand-written
encoder. Like READDIR, its entry list is the value-follows form of
RFC 1813's "entryplus3 *entries" -- each entry prefixed by TRUE, the
sequence closed by FALSE -- streamed from the directory as it is
read. Each entry additionally carries the object's post-op
attributes and file handle. The hand-written encoder materialized
the whole list into page memory during nfsd_readdir(), then copied
it into the reply as an opaque blob.

The preceding READDIR conversion built the streaming machinery in
shared code: the optional-data aggregate encoder pulls entries until
the hook signals end, and the streaming directory reader yields one
entry at a time during encode. Mark dirlistplus3's entry list as an
aggregate and regenerate; the struct definitions stay the verbatim
RFC 1813 types, and the lone "pragma aggregate dirlistplus3 entries"
selects the hook-driven codec.

Split the read across the two phases so the generated encoder owns
the framing. nfsd3_proc_readdirplus() opens the directory, where an
open error becomes the reply status the union encoder then writes,
and fills the directory attributes and cookie verifier that precede
the entry list. The encode hooks stream the entries: each pull
composes the entry's post-op attributes and file handle with the
same fill helpers the per-procedure encoders use, reserves a
placeholder cookie, and back-patches the preceding entry's cookie
once the following entry's resume offset is known. Because an
entryplus3's cookie is not its final field, the hook records the
cookie's slot from the entry's start position rather than from the
tail of the stream. The end hook advances rq_next_page
past the pages the entry list filled, as the READDIR end hook
does. nfs3svc_release_readdirplusres() closes the reader and releases
the file handle. Set pc_argzero to clear the argument wrapper, because
svc_release_rqst() calls that hook even when argument decoding fails
and nfsd3_proc_readdirplus() never initializes the file handle.

struct nfsd3_readdirplusres now embeds struct READDIRPLUS3res so the
RPC dispatch layer can cast the response to its xdrgen type, and
holds the streaming reader in place of the old page-buffer state.
READDIRPLUS3args_wrapper moves to xdr3.h so the encode and release
paths can reach the directory file handle.

A host error during the streamed read cannot retract entries already
on the wire, so it ends the list as a truncated, non-eof reply
rather than an error status; an error opening the directory is still
reported as the reply status. The bytes on the wire are otherwise
unchanged.

The hand-written READDIRPLUS result encoder, its per-entry encoder,
and the post-op file-handle encoders they relied on no longer have
any callers, so they are removed. The declaration of
nfs3svc_encode_accessres(), whose definition went away with the ACCESS
conversion, is removed along with them.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs3.x    |  10 +
 fs/nfsd/nfs3proc.c                 |  88 +++------
 fs/nfsd/nfs3xdr.c                  | 308 ++++++++++++++---------------
 fs/nfsd/nfs3xdr_gen.c              |  35 +++-
 fs/nfsd/nfs3xdr_gen.h              |  13 +-
 fs/nfsd/xdr3.h                     |  48 +++--
 include/linux/sunrpc/xdrgen/nfs3.h |   2 +-
 7 files changed, 263 insertions(+), 241 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs3.x b/Documentation/sunrpc/xdr/nfs3.x
index cf743a8a5f3d..2a126b8f7092 100644
--- a/Documentation/sunrpc/xdr/nfs3.x
+++ b/Documentation/sunrpc/xdr/nfs3.x
@@ -676,6 +676,16 @@ struct dirlistplus3 {
 	bool		eof;
 };
 
+/*
+ * The entry list encodes as the value-follows form of "entryplus3
+ * *entries" -- each entry prefixed by TRUE, the sequence closed by
+ * FALSE -- and the encode hooks stream it straight from the directory
+ * during reply encoding rather than from a materialized array.  The
+ * struct definitions above are the verbatim RFC 1813 types; only this
+ * pragma selects the hook-driven codec.
+ */
+pragma aggregate dirlistplus3 entries;
+
 struct READDIRPLUS3resok {
 	post_op_attr	dir_attributes;
 	cookieverf3	cookieverf;
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index bcf7107ec280..68b10b275f48 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -218,13 +218,6 @@ struct COMMIT3args_wrapper {
 
 static_assert(offsetof(struct COMMIT3args_wrapper, xdrgen) == 0);
 
-struct READDIRPLUS3args_wrapper {
-	struct READDIRPLUS3args	xdrgen;
-	struct svc_fh		fh;
-};
-
-static_assert(offsetof(struct READDIRPLUS3args_wrapper, xdrgen) == 0);
-
 static int nfsd3_ftype3_to_mode(ftype3 ftype)
 {
 	switch (ftype) {
@@ -437,10 +430,6 @@ nfsd3_stat_to_fattr3(struct svc_rqst *rqstp, struct fattr3 *fattr,
 	nfsd3_timespec64_to_nfstime3(&fattr->ctime, &stat->ctime);
 }
 
-static void
-nfsd3_fill_post_op_attr(struct svc_rqst *rqstp, struct post_op_attr *attr,
-			struct svc_fh *fhp);
-
 static void
 nfsd3_fill_wcc_data(struct svc_rqst *rqstp, struct wcc_data *wcc,
 		    struct svc_fh *fhp)
@@ -527,7 +516,7 @@ nfsd3_sattr3_to_iattr(struct svc_rqst *rqstp, struct iattr *iap,
  * post_op_attrs invoke nfsd3_fill_wcc_data() before invoking
  * nfsd3_fill_post_op_attr() on the same fhp argument.
  */
-static void
+void
 nfsd3_fill_post_op_attr(struct svc_rqst *rqstp, struct post_op_attr *attr,
 			struct svc_fh *fhp)
 {
@@ -552,7 +541,7 @@ nfsd3_fill_post_op_attr(struct svc_rqst *rqstp, struct post_op_attr *attr,
 	attr->attributes_follow = false;
 }
 
-static void
+void
 nfsd3_fill_post_op_fh3(struct post_op_fh3 *post_op_fh,
 		       const struct svc_fh *fhp, u8 *data)
 {
@@ -1235,27 +1224,6 @@ static __be32 nfsd3_proc_symlink(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-static void
-nfsd3_init_dirlistplus_pages(struct svc_rqst *rqstp,
-			     struct nfsd3_readdirplusres *resp,
-			     u32 count)
-{
-	struct xdr_buf *buf = &resp->dirlist;
-	struct xdr_stream *xdr = &resp->xdr;
-	unsigned int sendbuf = min_t(unsigned int, rqstp->rq_res.buflen,
-				     svc_max_payload(rqstp));
-
-	memset(buf, 0, sizeof(*buf));
-
-	/* Reserve room for the NULL ptr & eof flag (-2 words) */
-	buf->buflen = clamp(count, (u32)(XDR_UNIT * 2), sendbuf);
-	buf->buflen -= XDR_UNIT * 2;
-	buf->pages = rqstp->rq_next_page;
-	rqstp->rq_next_page += (buf->buflen + PAGE_SIZE - 1) >> PAGE_SHIFT;
-
-	xdr_init_encode_pages(xdr, buf);
-}
-
 /**
  * nfsd3_proc_mknod - MKNOD: Create a special file
  * @rqstp: RPC transaction context
@@ -1569,6 +1537,12 @@ static __be32 nfsd3_proc_readdir(struct svc_rqst *rqstp)
  * nfsd3_proc_readdirplus - READDIRPLUS: Extended read from directory
  * @rqstp: RPC transaction context
  *
+ * The directory is opened here so the reply status reflects any open
+ * error before the generated encoder writes the status word.  The
+ * entry list is streamed from the reply's directory reader during
+ * encode; nfs3svc_release_readdirplusres() closes the reader and
+ * releases the file handle.
+ *
  * Return:
  *   %rpc_success:		RPC executed successfully
  *
@@ -1581,35 +1555,33 @@ static __be32 nfsd3_proc_readdirplus(struct svc_rqst *rqstp)
 	struct nfsd3_readdirplusres *resp = rqstp->rq_resp;
 	loff_t offset = argp->xdrgen.cookie;
 	struct svc_fh *fhp = &argp->fh;
+	__be32 status;
 
 	nfsd3_fh3_to_svc_fh(fhp, &argp->xdrgen.dir);
 	trace_nfsd_vfs_readdir(rqstp, fhp, argp->xdrgen.maxcount,
 			       argp->xdrgen.cookie);
 
-	nfsd3_init_dirlistplus_pages(rqstp, resp, argp->xdrgen.maxcount);
-	fh_copy(&resp->fh, fhp);
-	resp->common.err = nfs_ok;
-	resp->cookie_offset = 0;
-	resp->rqstp = rqstp;
-	resp->status = fh_verify(rqstp, &resp->fh, S_IFDIR, NFSD_MAY_NOP);
-	if (resp->status != nfs_ok)
-		goto out;
+	resp->count = argp->xdrgen.maxcount;
+	status = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_NOP);
+	if (status == nfs_ok &&
+	    fhp->fh_export->ex_flags & NFSEXP_NOREADDIRPLUS)
+		status = nfserr_notsupp;
+	if (status == nfs_ok)
+		status = nfsd_readdir_open(rqstp, fhp, &offset, &resp->iter);
 
-	if (resp->fh.fh_export->ex_flags & NFSEXP_NOREADDIRPLUS) {
-		resp->status = nfserr_notsupp;
-		goto out;
+	if (status == nfs_ok) {
+		struct READDIRPLUS3resok *resok = &resp->xdrgen.u.resok;
+
+		memcpy(resok->cookieverf, argp->xdrgen.cookieverf,
+		       NFS3_COOKIEVERFSIZE);
+		nfsd3_fill_post_op_attr(rqstp, &resok->dir_attributes, fhp);
+	} else {
+		struct READDIRPLUS3resfail *resfail = &resp->xdrgen.u.resfail;
+
+		nfsd3_fill_post_op_attr(rqstp, &resfail->dir_attributes, fhp);
 	}
 
-	resp->status = nfsd_readdir(rqstp, &resp->fh, &offset,
-				    &resp->common, nfs3svc_encode_entryplus3);
-	memcpy(resp->verf, argp->xdrgen.cookieverf, NFS3_COOKIEVERFSIZE);
-	nfs3svc_encode_cookie3(&resp->xdr, resp->cookie_offset, offset);
-
-	/* Recycle only pages that were part of the reply */
-	rqstp->rq_next_page = resp->xdr.page_ptr + 1;
-
-out:
-	resp->status = nfsd3_map_status(resp->status);
+	resp->xdrgen.status = nfsd3_map_status(status);
 	return rpc_success;
 }
 
@@ -2037,10 +2009,10 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 	[NFSPROC3_READDIRPLUS] = {
 		.pc_func	= nfsd3_proc_readdirplus,
 		.pc_decode	= nfs_svc_decode_READDIRPLUS3args,
-		.pc_encode	= nfs3svc_encode_readdirplusres,
-		.pc_release	= nfs3svc_release_fhandle,
+		.pc_encode	= nfs_svc_encode_READDIRPLUS3res,
+		.pc_release	= nfs3svc_release_readdirplusres,
 		.pc_argsize	= sizeof(struct READDIRPLUS3args_wrapper),
-		.pc_argzero	= 0,
+		.pc_argzero	= sizeof(struct READDIRPLUS3args_wrapper),
 		.pc_ressize	= sizeof(struct nfsd3_readdirplusres),
 		.pc_cachetype	= RC_NOCACHE,
 		.pc_name	= "READDIRPLUS",
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 52a178fe69bb..3c80669a89ed 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -95,47 +95,6 @@ svcxdr_encode_nfsstat3(struct xdr_stream *xdr, __be32 status)
 	return true;
 }
 
-static bool
-svcxdr_encode_nfs_fh3(struct xdr_stream *xdr, const struct svc_fh *fhp)
-{
-	u32 size = fhp->fh_handle.fh_size;
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, XDR_UNIT + size);
-	if (!p)
-		return false;
-	*p++ = cpu_to_be32(size);
-	if (size)
-		p[XDR_QUADLEN(size) - 1] = 0;
-	memcpy(p, &fhp->fh_handle.fh_raw, size);
-
-	return true;
-}
-
-static bool
-svcxdr_encode_post_op_fh3(struct xdr_stream *xdr, const struct svc_fh *fhp)
-{
-	if (xdr_stream_encode_item_present(xdr) < 0)
-		return false;
-	if (!svcxdr_encode_nfs_fh3(xdr, fhp))
-		return false;
-
-	return true;
-}
-
-static bool
-svcxdr_encode_cookieverf3(struct xdr_stream *xdr, const __be32 *verf)
-{
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, NFS3_COOKIEVERFSIZE);
-	if (!p)
-		return false;
-	memcpy(p, verf, NFS3_COOKIEVERFSIZE);
-
-	return true;
-}
-
 static bool
 svcxdr_encode_fattr3(struct svc_rqst *rqstp, struct xdr_stream *xdr,
 		     const struct svc_fh *fhp, const struct kstat *stat)
@@ -369,36 +328,6 @@ bool nfs3_dirlist3_encode_end(struct xdrgen_aggregate_cursor *c, bool ok)
 	return true;
 }
 
-bool
-nfs3svc_encode_readdirplusres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_readdirplusres *resp = rqstp->rq_resp;
-	struct xdr_buf *dirlist = &resp->dirlist;
-
-	if (!svcxdr_encode_nfsstat3(xdr, resp->status))
-		return false;
-	switch (resp->status) {
-	case nfs_ok:
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh))
-			return false;
-		if (!svcxdr_encode_cookieverf3(xdr, resp->verf))
-			return false;
-		svcxdr_encode_opaque_pages(rqstp, xdr, dirlist->pages, 0,
-					   dirlist->len);
-		/* no more entries */
-		if (xdr_stream_encode_item_absent(xdr) < 0)
-			return false;
-		if (xdr_stream_encode_bool(xdr, resp->common.err == nfserr_eof) < 0)
-			return false;
-		break;
-	default:
-		if (!svcxdr_encode_post_op_attr(rqstp, xdr, &resp->fh))
-			return false;
-	}
-
-	return true;
-}
-
 static __be32
 compose_entry_fh(struct nfsd3_readdirplusres *cd, struct svc_fh *fhp,
 		 const char *name, int namlen, u64 ino)
@@ -407,8 +336,8 @@ compose_entry_fh(struct nfsd3_readdirplusres *cd, struct svc_fh *fhp,
 	struct dentry		*dparent, *dchild;
 	__be32 rv = nfserr_noent;
 
-	dparent = cd->fh.fh_dentry;
-	exp  = cd->fh.fh_export;
+	dparent = cd->iter.fhp->fh_dentry;
+	exp  = cd->iter.fhp->fh_export;
 
 	if (name_is_dot_dotdot(name, namlen)) {
 		if (namlen == 2) {
@@ -433,7 +362,7 @@ compose_entry_fh(struct nfsd3_readdirplusres *cd, struct svc_fh *fhp,
 		goto out;
 	if (dchild->d_inode->i_ino != ino)
 		goto out;
-	rv = fh_compose(fhp, exp, dchild, &cd->fh);
+	rv = fh_compose(fhp, exp, dchild, cd->iter.fhp);
 out:
 	dput(dchild);
 	return rv;
@@ -446,7 +375,7 @@ compose_entry_fh(struct nfsd3_readdirplusres *cd, struct svc_fh *fhp,
  * @cookie: cookie to be encoded
  *
  * The buffer space for the offset cookie has already been reserved
- * by nfs3_dirlist3_encode() or nfs3svc_encode_entryplus3().
+ * by nfs3_dirlist3_encode() or nfs3_dirlistplus3_encode().
  */
 void nfs3svc_encode_cookie3(struct xdr_stream *xdr, unsigned int pos,
 			    u64 cookie)
@@ -458,105 +387,166 @@ void nfs3svc_encode_cookie3(struct xdr_stream *xdr, unsigned int pos,
 	write_bytes_to_xdr_buf(xdr->buf, pos, &wire_cookie, XDR_UNIT * 2);
 }
 
-static bool
-svcxdr_encode_entry3_plus(struct nfsd3_readdirplusres *resp, const char *name,
-			  int namlen, u64 ino)
+/*
+ * READDIRPLUS reply entry list (RFC 1813).  Like READDIR's entry list,
+ * the entries are the value-follows form of "entryplus3 *entries" and
+ * xdrgen's aggregate codec owns the framing.  Each entry additionally
+ * carries the object's post-op attributes and file handle, composed
+ * and stat'ed here as the entry is streamed.  The directory was opened
+ * in nfsd3_proc_readdirplus(), so reading and encoding happen together
+ * during reply encoding.
+ */
+
+/**
+ * nfs3_dirlistplus3_encode_begin - size the streaming entry budget
+ * @c: aggregate cursor for the entry list
+ *
+ * Derive the entry byte budget from the space left in the live reply
+ * and the client's maxcount hint, reserving room for the list
+ * terminator and the eof flag that follow the entries.
+ *
+ * Return: true.
+ */
+bool nfs3_dirlistplus3_encode_begin(struct xdrgen_aggregate_cursor *c)
 {
-	struct xdr_stream *xdr = &resp->xdr;
-	struct svc_fh *fhp = &resp->scratch;
-	bool result;
+	struct svc_rqst *rqstp = c->ctx;
+	struct nfsd3_readdirplusres *resp = rqstp->rq_resp;
+	struct xdr_stream *xdr = c->xdr;
+	int bytes_left;
 
-	result = false;
-	fh_init(fhp, NFS3_FHSIZE);
-	if (compose_entry_fh(resp, fhp, name, namlen, ino) != nfs_ok)
-		goto out_noattrs;
-
-	if (!svcxdr_encode_post_op_attr(resp->rqstp, xdr, fhp))
-		goto out;
-	if (!svcxdr_encode_post_op_fh3(xdr, fhp))
-		goto out;
-	result = true;
-
-out:
-	fh_put(fhp);
-	return result;
-
-out_noattrs:
-	if (xdr_stream_encode_item_absent(xdr) < 0)
-		return false;
-	if (xdr_stream_encode_item_absent(xdr) < 0)
-		return false;
+	/* Reserve the terminator FALSE and the eof bool (two words). */
+	bytes_left = xdr->buf->buflen - xdr->buf->len - XDR_UNIT * 2;
+	if (bytes_left < 0)
+		bytes_left = 0;
+	resp->space_left = min_t(u32, bytes_left,
+				 clamp(resp->count, (u32)(XDR_UNIT * 2),
+				       (u32)svc_max_payload(rqstp)) -
+				 XDR_UNIT * 2);
+	resp->cookie_offset = 0;
 	return true;
 }
 
 /**
- * nfs3svc_encode_entryplus3 - encode one NFSv3 READDIRPLUS entry
- * @data: directory context
- * @name: name of the object to be encoded
- * @namlen: length of that name, in bytes
- * @offset: the offset of the previous entry
- * @ino: the fileid of this entry
- * @d_type: unused
+ * nfs3_dirlistplus3_encode - stream the next READDIRPLUS entry
+ * @c: aggregate cursor for the entry list
+ * @out: OUT: entry the framing encodes when one is produced
  *
- * Return values:
- *   %0: Entry was successfully encoded.
- *   %-EINVAL: An encoding problem occurred, secondary status code in resp->common.err
+ * Back-patch the previous entry's placeholder cookie with this entry's
+ * resume offset, compose the entry's post-op attributes and file
+ * handle, then, if the reply budget allows, project the next directory
+ * entry into @out for the generated per-entry encoder.  @out's file
+ * handle bytes live in a reply-owned scratch buffer, valid until the
+ * generated encoder writes them and the following pull overwrites them.
  *
- * On exit, the following fields are updated:
- *   - resp->xdr
- *   - resp->common.err
- *   - resp->cookie_offset
+ * Return: true when @out holds an entry to encode; false to end the
+ * list -- because the directory is exhausted, a host error struck, or
+ * the reply budget filled.  On budget exhaustion the previous entry's
+ * cookie already points at the rejected entry, the client's resume
+ * point.
  */
-int nfs3svc_encode_entryplus3(void *data, const char *name, int namlen,
-			      loff_t offset, u64 ino, unsigned int d_type)
+bool nfs3_dirlistplus3_encode(struct xdrgen_aggregate_cursor *c,
+			      struct entryplus3 *out)
 {
-	struct readdir_cd *ccd = data;
-	struct nfsd3_readdirplusres *resp =
-		container_of(ccd, struct nfsd3_readdirplusres, common);
-	unsigned int starting_length = resp->dirlist.len;
-	struct xdr_stream *xdr = &resp->xdr;
+	struct svc_rqst *rqstp = c->ctx;
+	struct nfsd3_readdirplusres *resp = rqstp->rq_resp;
+	struct svc_fh *scratch = &resp->scratch;
+	struct xdr_stream *xdr = c->xdr;
+	struct buffered_dirent *de;
+	int namlen;
+	u32 need;
 
-	/* The offset cookie for the previous entry */
-	nfs3svc_encode_cookie3(xdr, resp->cookie_offset, offset);
+	/*
+	 * Commit the previous entry so its cookie slot (recorded in
+	 * resp->cookie_offset) is safe to back-patch below.  Unlike
+	 * entry3, an entryplus3's cookie is not its final field, so the
+	 * slot cannot be derived from buf->len after the fact; it is
+	 * computed from the entry's start position instead (see the end
+	 * of this function).
+	 */
+	if (c->index)
+		xdr_commit_encode(xdr);
 
-	if (xdr_stream_encode_item_present(xdr) < 0)
-		goto out_toosmall;
-	/* fileid */
-	if (xdr_stream_encode_u64(xdr, ino) < 0)
-		goto out_toosmall;
-	/* name */
-	if (xdr_stream_encode_opaque(xdr, name, min(namlen, NFS3_MAXNAMLEN)) < 0)
-		goto out_toosmall;
-	/* cookie */
-	resp->cookie_offset = resp->dirlist.len;
-	if (xdr_stream_encode_u64(xdr, OFFSET_MAX) < 0)
-		goto out_toosmall;
+	de = nfsd_readdir_next(&resp->iter);
+	if (!de)
+		return false;
 
-	if (!svcxdr_encode_entry3_plus(resp, name, namlen, ino))
-		goto out_toosmall;
+	/* The previous entry's cookie is this entry's resume offset. */
+	nfs3svc_encode_cookie3(xdr, resp->cookie_offset, de->offset);
 
-	xdr_commit_encode(xdr);
-	resp->common.err = nfs_ok;
-	return 0;
+	namlen = min_t(int, de->namlen, NFS3_MAXNAMLEN);
 
-out_toosmall:
-	resp->cookie_offset = 0;
-	resp->common.err = nfserr_toosmall;
-	resp->dirlist.len = starting_length;
-	return -EINVAL;
+	out->fileid = de->ino;
+	out->name.len = namlen;
+	out->name.data = (unsigned char *)de->name;
+	out->cookie = 0;	/* back-patched later */
+
+	/* Compose the entry's post-op attributes and file handle. */
+	fh_init(scratch, NFS3_FHSIZE);
+	if (compose_entry_fh(resp, scratch, de->name, namlen, de->ino) == nfs_ok) {
+		nfsd3_fill_post_op_attr(rqstp, &out->name_attributes, scratch);
+		nfsd3_fill_post_op_fh3(&out->name_handle, scratch, resp->fh_data);
+	} else {
+		out->name_attributes.attributes_follow = false;
+		out->name_handle.handle_follows = false;
+	}
+	fh_put(scratch);
+
+	/* value-follows + fileid + name (length + data) + cookie */
+	need = XDR_UNIT * (6 + XDR_QUADLEN(namlen));
+	/* name_attributes: attributes_follow + optional fattr3 */
+	need += XDR_UNIT;
+	if (out->name_attributes.attributes_follow)
+		need += XDR_UNIT * 21;
+	/* name_handle: handle_follows + optional nfs_fh3 */
+	need += XDR_UNIT;
+	if (out->name_handle.handle_follows)
+		need += XDR_UNIT * (1 + XDR_QUADLEN(out->name_handle.u.handle.data.len));
+	if (need > resp->space_left)
+		return false;
+	resp->space_left -= need;
+
+	/*
+	 * buf->len marks where the generated encoder begins this entry.
+	 * Its cookie follows the value-follows flag, the fileid, and the
+	 * name; record that slot for the next entry (or the end hook) to
+	 * back-patch once the resume offset is known.
+	 */
+	resp->cookie_offset = xdr->buf->len +
+			      XDR_UNIT * (4 + XDR_QUADLEN(namlen));
+
+	trace_nfsd_dirent(resp->iter.fhp, de->ino, de->name, namlen);
+	return true;
+}
+
+/**
+ * nfs3_dirlistplus3_encode_end - finish the streamed entry list
+ * @c: aggregate cursor for the entry list
+ * @ok: false if the framing hit a wire error while encoding the list
+ *
+ * Back-patch the final entry's cookie with the directory's resume
+ * offset and report eof.  A list cut short by the reply budget or a
+ * host error reports eof false, so the client reads the rest with a
+ * follow-up request.
+ *
+ * Return: true.
+ */
+bool nfs3_dirlistplus3_encode_end(struct xdrgen_aggregate_cursor *c, bool ok)
+{
+	struct svc_rqst *rqstp = c->ctx;
+	struct nfsd3_readdirplusres *resp = rqstp->rq_resp;
+	struct xdr_stream *xdr = c->xdr;
+
+	if (ok)
+		nfs3svc_encode_cookie3(xdr, resp->cookie_offset,
+				       resp->iter.offset);
+	resp->xdrgen.u.resok.reply.eof = resp->iter.eof;
+	nfs3svc_update_next_page(rqstp, xdr);
+	return true;
 }
 
 /*
  * XDR release functions
  */
-void
-nfs3svc_release_fhandle(struct svc_rqst *rqstp)
-{
-	struct nfsd3_attrstat *resp = rqstp->rq_resp;
-
-	fh_put(&resp->fh);
-}
-
 void
 nfs3svc_release_readdirres(struct svc_rqst *rqstp)
 {
@@ -567,3 +557,13 @@ nfs3svc_release_readdirres(struct svc_rqst *rqstp)
 	nfsd_readdir_close(&resp->iter);
 	fh_put(&argp->fh);
 }
+
+void
+nfs3svc_release_readdirplusres(struct svc_rqst *rqstp)
+{
+	struct nfsd3_readdirplusres *resp = rqstp->rq_resp;
+	struct READDIRPLUS3args_wrapper *argp = rqstp->rq_argp;
+
+	nfsd_readdir_close(&resp->iter);
+	fh_put(&argp->fh);
+}
diff --git a/fs/nfsd/nfs3xdr_gen.c b/fs/nfsd/nfs3xdr_gen.c
index 452e456dc8da..6ab69e869839 100644
--- a/fs/nfsd/nfs3xdr_gen.c
+++ b/fs/nfsd/nfs3xdr_gen.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 // Generated by xdrgen. Manual edits will be lost.
 // XDR specification file: Documentation/sunrpc/xdr/nfs3.x
-// XDR specification modification time: Tue Jul 14 20:36:22 2026
+// XDR specification modification time: Tue Jul 14 21:15:59 2026
 
 #include <linux/sunrpc/svc.h>
 
@@ -1340,11 +1340,7 @@ xdrgen_decode_entryplus3(struct xdr_stream *xdr, struct entryplus3 *ptr)
 static bool __maybe_unused
 xdrgen_decode_dirlistplus3(struct xdr_stream *xdr, struct dirlistplus3 *ptr)
 {
-	if (!xdrgen_decode_entryplus3(xdr, ptr->entries))
-		return false;
-	if (!xdrgen_decode_bool(xdr, &ptr->eof))
-		return false;
-	return true;
+	return false;
 }
 
 static bool __maybe_unused
@@ -3192,8 +3188,31 @@ xdrgen_encode_entryplus3(struct xdr_stream *xdr, const struct entryplus3 *value)
 static bool __maybe_unused
 xdrgen_encode_dirlistplus3(struct xdr_stream *xdr, const struct dirlistplus3 *value)
 {
-	if (!xdrgen_encode_entryplus3(xdr, value->entries))
-		return false;
+	{
+		struct xdrgen_aggregate_cursor cursor = {
+			.xdr = xdr,
+			.member_id = NFS3_DIRLISTPLUS3_ENTRIES,
+			.ctx = xdr->xdrgen_ctx,
+		};
+		bool ok = true;
+
+		if (!nfs3_dirlistplus3_encode_begin(&cursor))
+			return false;
+		for (cursor.index = 0; ; cursor.index++) {
+			struct entryplus3 element = {};
+
+			if (!nfs3_dirlistplus3_encode(&cursor, &element))
+				break;
+			if (!xdrgen_encode_entryplus3(xdr, &element)) {
+				ok = false;
+				break;
+			}
+		}
+		if (ok && !xdrgen_encode_entryplus3(xdr, NULL))
+			ok = false;
+		if (!nfs3_dirlistplus3_encode_end(&cursor, ok) || !ok)
+			return false;
+	}
 	if (!xdrgen_encode_bool(xdr, value->eof))
 		return false;
 	return true;
diff --git a/fs/nfsd/nfs3xdr_gen.h b/fs/nfsd/nfs3xdr_gen.h
index 5c302645bfbe..92f3bf85d1db 100644
--- a/fs/nfsd/nfs3xdr_gen.h
+++ b/fs/nfsd/nfs3xdr_gen.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: Documentation/sunrpc/xdr/nfs3.x */
-/* XDR specification modification time: Tue Jul 14 20:36:22 2026 */
+/* XDR specification modification time: Tue Jul 14 21:15:59 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS3_DECL_H
 #define _LINUX_XDRGEN_NFS3_DECL_H
@@ -24,6 +24,17 @@ bool nfs3_dirlist3_decode_begin(struct xdrgen_aggregate_cursor *c);
 bool nfs3_dirlist3_decode(struct xdrgen_aggregate_cursor *c, const struct entry3 *in);
 bool nfs3_dirlist3_decode_end(struct xdrgen_aggregate_cursor *c, bool ok);
 
+enum {
+	NFS3_DIRLISTPLUS3_ENTRIES,
+};
+
+bool nfs3_dirlistplus3_encode_begin(struct xdrgen_aggregate_cursor *c);
+bool nfs3_dirlistplus3_encode(struct xdrgen_aggregate_cursor *c, struct entryplus3 *out);
+bool nfs3_dirlistplus3_encode_end(struct xdrgen_aggregate_cursor *c, bool ok);
+bool nfs3_dirlistplus3_decode_begin(struct xdrgen_aggregate_cursor *c);
+bool nfs3_dirlistplus3_decode(struct xdrgen_aggregate_cursor *c, const struct entryplus3 *in);
+bool nfs3_dirlistplus3_decode_end(struct xdrgen_aggregate_cursor *c, bool ok);
+
 bool nfs_svc_decode_GETATTR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs_svc_decode_SETATTR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs_svc_decode_LOOKUP3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index 75de77aa8e13..a6f0e0b7bfe4 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -81,22 +81,33 @@ struct nfsd3_readdirres {
 
 static_assert(offsetof(struct nfsd3_readdirres, xdrgen) == 0);
 
-struct nfsd3_readdirplusres {
-	/* Components of the reply */
-	__be32			status;
+/*
+ * Declared here rather than in nfs3proc.c with the other proc wrappers
+ * because READDIRPLUS's encode path in nfs3xdr.c reads the file handle
+ * from it during encode and release. The xdrgen field must be first so
+ * the struct can be cast to its XDR type for the RPC dispatch layer.
+ */
+struct READDIRPLUS3args_wrapper {
+	struct READDIRPLUS3args	xdrgen;
 	struct svc_fh		fh;
-	__be32			verf[2];
-
-	/* Used to encode the reply's entry list */
-	struct xdr_stream	xdr;
-	struct xdr_buf		dirlist;
-	struct svc_fh		scratch;
-	struct readdir_cd	common;
-	unsigned int		cookie_offset;
-	struct svc_rqst *	rqstp;
-
 };
 
+static_assert(offsetof(struct READDIRPLUS3args_wrapper, xdrgen) == 0);
+
+struct nfsd3_readdirplusres {
+	struct READDIRPLUS3res	xdrgen;
+
+	/* Streaming state for encoding the reply's entry list */
+	struct nfsd_readdir_iter iter;		/* directory reader */
+	u32			count;		/* client's reply size hint */
+	u32			space_left;	/* remaining entry budget */
+	unsigned int		cookie_offset;	/* prev entry's cookie slot */
+	struct svc_fh		scratch;	/* per-entry file handle */
+	u8			fh_data[NFS3_FHSIZE];	/* per-entry handle bytes */
+};
+
+static_assert(offsetof(struct nfsd3_readdirplusres, xdrgen) == 0);
+
 struct nfsd3_fsstatres {
 	struct FSSTAT3res	xdrgen;
 	struct kstatfs		stats;
@@ -131,16 +142,15 @@ struct nfsd3_getaclres {
 	struct kstat		stat;
 };
 
-bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_encode_readdirplusres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-
-void nfs3svc_release_fhandle(struct svc_rqst *);
 void nfs3svc_release_readdirres(struct svc_rqst *rqstp);
+void nfs3svc_release_readdirplusres(struct svc_rqst *rqstp);
 
 void nfs3svc_encode_cookie3(struct xdr_stream *xdr, unsigned int pos,
 			    u64 cookie);
-int nfs3svc_encode_entryplus3(void *data, const char *name, int namlen,
-			      loff_t offset, u64 ino, unsigned int d_type);
+void nfsd3_fill_post_op_attr(struct svc_rqst *rqstp, struct post_op_attr *attr,
+			     struct svc_fh *fhp);
+void nfsd3_fill_post_op_fh3(struct post_op_fh3 *post_op_fh,
+			    const struct svc_fh *fhp, u8 *data);
 /* Helper functions for NFSv3 ACL code */
 bool svcxdr_decode_nfs_fh3(struct xdr_stream *xdr, struct svc_fh *fhp);
 bool svcxdr_encode_nfsstat3(struct xdr_stream *xdr, __be32 status);
diff --git a/include/linux/sunrpc/xdrgen/nfs3.h b/include/linux/sunrpc/xdrgen/nfs3.h
index 27750bbab2ee..734f60f502c6 100644
--- a/include/linux/sunrpc/xdrgen/nfs3.h
+++ b/include/linux/sunrpc/xdrgen/nfs3.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: Documentation/sunrpc/xdr/nfs3.x */
-/* XDR specification modification time: Tue Jul 14 20:36:22 2026 */
+/* XDR specification modification time: Tue Jul 14 21:15:59 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS3_DEF_H
 #define _LINUX_XDRGEN_NFS3_DEF_H
-- 
2.55.0

