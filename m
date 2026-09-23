Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0745F5304B2
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 13:28:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790170123; cv=none; b=NseyAqcBGhie2AfyvctkBUah/7bhz6+VLHZg2MvD51eD75smGL97vhJYTgEARtoYiS6DZPZ6pee1UqSUe/9nBa/bTY6cdD1u5sPpXjdMASZIkaWD0s4Sk0kPIWR1KGVgueB5Scg0KyNpcBjceEKe9qpd55S7ko/xp7vgCH6rP50=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790170123; c=relaxed/simple;
	bh=mL679G+DpI3DGeLibLtOjDellRlzMtokG5IfIVCJNqE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OmHNy0P+iPn3fKlEix0fS76YEokJM69QIz5lYDKhloviDtRxGL5vdVrx086YImn1lZtfh+y5XtKIUIhxikiEcibWPPHr6ICKdoLKH3ojWSJ2qM9g5WuCWarbmm5PU32VgTAgqF+Dsu62YLSi8YWAvY5og7l0pjiqp+mP4a4vjRw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LZh+Vq9X; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LZh+Vq9X"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5FAF61F000FF;
	Wed, 23 Sep 2026 13:28:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790170120;
	bh=KzsXfjZWl8XLPLAWYNwMxfoMH09v2Ks4W6XBxMGzuHc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=LZh+Vq9XnTlUkAAiKzcGAbYbl/j7ImEQEULUb/JzXI557peZ64FJI0W1H2p/HYpjO
	 OVtsYQaF/RDzWLMg91EiU9/24lmSIo8MkzoqyOx6SHqJz6eTZb5VSUH/ZpramfraIV
	 GISD0CsYZQSSzacMoBYTjt1W1ckgX5epC+6k94mzuoQm1BXvgopp4cV2NavDDZPIUT
	 C77ZRwpgma0zLeR36CL4hB1aFCb/sZi/DGnRlvYmVz4qRE4hdj5AzcD6LL4ddGBePC
	 kGwLdrN++P5sYoPSNmv6RGp5N4I8ZlUM0dP9bVjPCrZw4IV0wIUjXVZvQxTe45Smx/
	 bEnFMjwdpApaQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 32/33] NFSD: Use xdrgen XDR functions for NFSv3 READDIR results
Date: Wed, 23 Sep 2026 09:28:10 -0400
Message-ID: <20260923132811.244160-33-cel@kernel.org>
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

NFSv3 READDIR's reply is still produced by a hand-written encoder.
Its entry list is the value-follows form of RFC 1813's "entry3
*entries" -- each entry prefixed by TRUE, the sequence closed by
FALSE -- streamed straight from the directory as it is read rather
than from a materialized array. The generated encoder could not
drive that: the union encoder writes the reply status word before the
entry list, yet a streamed read does not learn the status until the
directory has been opened, and the aggregate loop was bounded by a
count the begin hook had to supply up front.

The preceding NFSv2 work removed both obstacles in shared code. The
optional-data aggregate encoder pulls entries until the hook signals
end, so no count is needed, and the streaming directory reader yields
one entry at a time during encode. Mark dirlist3's entry list as an
aggregate and regenerate; the struct definitions stay the verbatim
RFC 1813 types, and the lone "pragma aggregate dirlist3 entries"
selects the hook-driven codec.

Split the read across the two phases so the generated encoder owns
the framing. nfsd3_proc_readdir() opens the directory, where an open
error becomes the reply status the union encoder then writes, and
fills the directory attributes and cookie verifier that precede the
entry list. The encode hooks stream the entries: each pull reserves a
placeholder cookie and back-patches the preceding entry's cookie once
the following entry's resume offset is known; the end hook back-patches
the final cookie and reports eof. The end hook also advances
rq_next_page past the pages the entry list filled, because svcrdma
and svc_rqst_release_pages() handle only the reply pages below
it. nfs3svc_release_readdirres() closes the reader and releases the
file handle. Set pc_argzero to clear the argument wrapper, because
svc_release_rqst() calls that hook even when argument decoding fails
and nfsd3_proc_readdir() never initializes the file handle. The decode
hooks are stubs -- a server never decodes a READDIR result -- present
only to satisfy the generated decoder's linkage.

struct nfsd3_readdirres now embeds struct READDIR3res so the RPC
dispatch layer can cast the response to its xdrgen type, and holds the
streaming reader in place of the old page-buffer state.
READDIR3args_wrapper moves to xdr3.h so the encode and release paths
can reach the directory file handle.

A host error during the streamed read cannot retract entries already
on the wire, so it ends the list as a truncated, non-eof reply rather
than an error status; an error opening the directory is still reported
as the reply status. The bytes on the wire are otherwise unchanged.

nfs3svc_encode_readdirres() and nfs3svc_encode_entry3() no longer have
any callers, so they are removed.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs3.x    |  10 ++
 fs/nfsd/nfs3proc.c                 |  68 +++-----
 fs/nfsd/nfs3xdr.c                  | 246 ++++++++++++++++++++---------
 fs/nfsd/nfs3xdr_gen.c              |  56 ++++++-
 fs/nfsd/nfs3xdr_gen.h              |  13 +-
 fs/nfsd/xdr3.h                     |  39 +++--
 include/linux/sunrpc/xdrgen/nfs3.h |   2 +-
 7 files changed, 289 insertions(+), 145 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs3.x b/Documentation/sunrpc/xdr/nfs3.x
index c987788bf34c..cf743a8a5f3d 100644
--- a/Documentation/sunrpc/xdr/nfs3.x
+++ b/Documentation/sunrpc/xdr/nfs3.x
@@ -627,6 +627,16 @@ struct dirlist3 {
 	bool		eof;
 };
 
+/*
+ * The entry list encodes as the value-follows form of "entry3
+ * *entries" -- each entry prefixed by TRUE, the sequence closed by
+ * FALSE -- and the encode hooks stream it straight from the directory
+ * during reply encoding rather than from a materialized array.  The
+ * struct definitions above are the verbatim RFC 1813 types; only this
+ * pragma selects the hook-driven codec.
+ */
+pragma aggregate dirlist3 entries;
+
 struct READDIR3resok {
 	post_op_attr	dir_attributes;
 	cookieverf3	cookieverf;
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 797c91fb7ad2..bcf7107ec280 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -218,13 +218,6 @@ struct COMMIT3args_wrapper {
 
 static_assert(offsetof(struct COMMIT3args_wrapper, xdrgen) == 0);
 
-struct READDIR3args_wrapper {
-	struct READDIR3args	xdrgen;
-	struct svc_fh		fh;
-};
-
-static_assert(offsetof(struct READDIR3args_wrapper, xdrgen) == 0);
-
 struct READDIRPLUS3args_wrapper {
 	struct READDIRPLUS3args	xdrgen;
 	struct svc_fh		fh;
@@ -1525,30 +1518,16 @@ static __be32 nfsd3_proc_link(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-static void nfsd3_init_dirlist_pages(struct svc_rqst *rqstp,
-				     struct nfsd3_readdirres *resp,
-				     u32 count)
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
  * nfsd3_proc_readdir - READDIR: Read from directory
  * @rqstp: RPC transaction context
  *
+ * The directory is opened here so the reply status reflects any open
+ * error before the generated encoder writes the status word.  The
+ * entry list is streamed from the reply's directory reader during
+ * encode; nfs3svc_release_readdirres() closes the reader and releases
+ * the file handle.
+ *
  * Return:
  *   %rpc_success:		RPC executed successfully
  *
@@ -1558,28 +1537,31 @@ static void nfsd3_init_dirlist_pages(struct svc_rqst *rqstp,
 static __be32 nfsd3_proc_readdir(struct svc_rqst *rqstp)
 {
 	struct READDIR3args_wrapper *argp = rqstp->rq_argp;
-	struct nfsd3_readdirres  *resp = rqstp->rq_resp;
+	struct nfsd3_readdirres *resp = rqstp->rq_resp;
 	loff_t offset = argp->xdrgen.cookie;
 	struct svc_fh *fhp = &argp->fh;
+	__be32 status;
 
 	nfsd3_fh3_to_svc_fh(fhp, &argp->xdrgen.dir);
 	trace_nfsd_vfs_readdir(rqstp, fhp, argp->xdrgen.count,
 			       argp->xdrgen.cookie);
 
-	nfsd3_init_dirlist_pages(rqstp, resp, argp->xdrgen.count);
-	fh_copy(&resp->fh, fhp);
-	resp->common.err = nfs_ok;
-	resp->cookie_offset = 0;
-	resp->rqstp = rqstp;
-	resp->status = nfsd_readdir(rqstp, &resp->fh, &offset,
-				    &resp->common, nfs3svc_encode_entry3);
-	memcpy(resp->verf, argp->xdrgen.cookieverf, NFS3_COOKIEVERFSIZE);
-	nfs3svc_encode_cookie3(&resp->xdr, resp->cookie_offset, offset);
+	resp->count = argp->xdrgen.count;
+	status = nfsd_readdir_open(rqstp, fhp, &offset, &resp->iter);
 
-	/* Recycle only pages that were part of the reply */
-	rqstp->rq_next_page = resp->xdr.page_ptr + 1;
+	if (status == nfs_ok) {
+		struct READDIR3resok *resok = &resp->xdrgen.u.resok;
 
-	resp->status = nfsd3_map_status(resp->status);
+		memcpy(resok->cookieverf, argp->xdrgen.cookieverf,
+		       NFS3_COOKIEVERFSIZE);
+		nfsd3_fill_post_op_attr(rqstp, &resok->dir_attributes, fhp);
+	} else {
+		struct READDIR3resfail *resfail = &resp->xdrgen.u.resfail;
+
+		nfsd3_fill_post_op_attr(rqstp, &resfail->dir_attributes, fhp);
+	}
+
+	resp->xdrgen.status = nfsd3_map_status(status);
 	return rpc_success;
 }
 
@@ -2044,10 +2026,10 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 	[NFSPROC3_READDIR] = {
 		.pc_func	= nfsd3_proc_readdir,
 		.pc_decode	= nfs_svc_decode_READDIR3args,
-		.pc_encode	= nfs3svc_encode_readdirres,
-		.pc_release	= nfs3svc_release_fhandle,
+		.pc_encode	= nfs_svc_encode_READDIR3res,
+		.pc_release	= nfs3svc_release_readdirres,
 		.pc_argsize	= sizeof(struct READDIR3args_wrapper),
-		.pc_argzero	= 0,
+		.pc_argzero	= sizeof(struct READDIR3args_wrapper),
 		.pc_ressize	= sizeof(struct nfsd3_readdirres),
 		.pc_cachetype	= RC_NOCACHE,
 		.pc_name	= "READDIR",
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 2d00343ed202..7831d15e4451 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -16,6 +16,9 @@
 #include "netns.h"
 #include "vfs.h"
 #include "nfserr.h"
+#include "trace.h"
+
+#include "nfs3xdr_gen.h"
 
 /*
  * Mapping of S_IF* types to NFS file types
@@ -228,36 +231,164 @@ svcxdr_encode_post_op_attr(struct svc_rqst *rqstp, struct xdr_stream *xdr,
  * XDR encode functions
  */
 
-bool
-nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
-{
-	struct nfsd3_readdirres *resp = rqstp->rq_resp;
-	struct xdr_buf *dirlist = &resp->dirlist;
+/*
+ * READDIR reply entry list (RFC 1813).  The entry list is the
+ * value-follows form of "entry3 *entries": each entry prefixed by
+ * TRUE, the sequence closed by FALSE.  xdrgen's aggregate codec owns
+ * that framing; the hooks below stream one entry at a time straight
+ * from the directory into the live reply, mirroring
+ * nfsd4_encode_dirlist4.  The directory was opened in
+ * nfsd3_proc_readdir(), so reading and encoding happen together here
+ * during reply encoding.
+ */
 
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
+/**
+ * nfs3_dirlist3_encode_begin - size the streaming entry budget
+ * @c: aggregate cursor for the entry list
+ *
+ * Derive the entry byte budget from the space left in the live reply
+ * and the client's count hint, reserving room for the list terminator
+ * and the eof flag that follow the entries.
+ *
+ * Return: true.
+ */
+bool nfs3_dirlist3_encode_begin(struct xdrgen_aggregate_cursor *c)
+{
+	struct svc_rqst *rqstp = c->ctx;
+	struct nfsd3_readdirres *resp = rqstp->rq_resp;
+	struct xdr_stream *xdr = c->xdr;
+	int bytes_left;
+
+	/* Reserve the terminator FALSE and the eof bool (two words). */
+	bytes_left = xdr->buf->buflen - xdr->buf->len - XDR_UNIT * 2;
+	if (bytes_left < 0)
+		bytes_left = 0;
+	resp->space_left = min_t(u32, bytes_left,
+				 clamp(resp->count, (u32)(XDR_UNIT * 2),
+				       (u32)svc_max_payload(rqstp)) -
+				 XDR_UNIT * 2);
+	resp->cookie_offset = 0;
+	return true;
+}
+
+/**
+ * nfs3_dirlist3_encode - stream the next READDIR entry
+ * @c: aggregate cursor for the entry list
+ * @out: OUT: entry the framing encodes when one is produced
+ *
+ * Back-patch the previous entry's placeholder cookie with this entry's
+ * resume offset, then, if the reply budget allows, project the next
+ * directory entry into @out for the generated per-entry encoder.
+ *
+ * Return: true when @out holds an entry to encode; false to end the
+ * list -- because the directory is exhausted, a host error struck, or
+ * the reply budget filled.  On budget exhaustion the previous entry's
+ * cookie already points at the rejected entry, the client's resume
+ * point.
+ */
+bool nfs3_dirlist3_encode(struct xdrgen_aggregate_cursor *c,
+			  struct entry3 *out)
+{
+	struct svc_rqst *rqstp = c->ctx;
+	struct nfsd3_readdirres *resp = rqstp->rq_resp;
+	struct xdr_stream *xdr = c->xdr;
+	struct buffered_dirent *de;
+	int namlen;
+	u32 need;
+
+	/*
+	 * The previous entry was just encoded; commit the stream and note
+	 * its cookie slot -- the entry's last two XDR words -- so it can be
+	 * back-patched once this entry's resume offset is known.
+	 */
+	if (c->index) {
+		xdr_commit_encode(xdr);
+		resp->cookie_offset = xdr->buf->len - XDR_UNIT * 2;
 	}
 
+	de = nfsd_readdir_next(&resp->iter);
+	if (!de)
+		return false;
+
+	/* The previous entry's cookie is this entry's resume offset. */
+	nfs3svc_encode_cookie3(xdr, resp->cookie_offset, de->offset);
+
+	namlen = min_t(int, de->namlen, NFS3_MAXNAMLEN);
+
+	/* value-follows + fileid + name (length + data) + cookie */
+	need = XDR_UNIT * (6 + XDR_QUADLEN(namlen));
+	if (need > resp->space_left)
+		return false;
+	resp->space_left -= need;
+
+	out->fileid = de->ino;
+	out->name.len = namlen;
+	out->name.data = (unsigned char *)de->name;
+	out->cookie = 0;	/* back-patched later */
+
+	trace_nfsd_dirent(resp->iter.fhp, de->ino, de->name, namlen);
 	return true;
 }
 
+/*
+ * The xdr_stream primitives do not advance rq_next_page, and svcrdma
+ * retains only the pages below it for Send completion. The eof word that
+ * follows the entry list starts a new page when this one is full.
+ */
+static void nfs3svc_update_next_page(struct svc_rqst *rqstp,
+				     struct xdr_stream *xdr)
+{
+	rqstp->rq_next_page = xdr->page_ptr + 1;
+	if (xdr->p == xdr->end)
+		rqstp->rq_next_page++;
+}
+
+/**
+ * nfs3_dirlist3_encode_end - finish the streamed entry list
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
+bool nfs3_dirlist3_encode_end(struct xdrgen_aggregate_cursor *c, bool ok)
+{
+	struct svc_rqst *rqstp = c->ctx;
+	struct nfsd3_readdirres *resp = rqstp->rq_resp;
+	struct xdr_stream *xdr = c->xdr;
+
+	if (ok)
+		nfs3svc_encode_cookie3(xdr, resp->cookie_offset,
+				       resp->iter.offset);
+	resp->xdrgen.u.resok.reply.eof = resp->iter.eof;
+	nfs3svc_update_next_page(rqstp, xdr);
+	return true;
+}
+
+/*
+ * A server never decodes a READDIR result; these satisfy the linkage
+ * of the generated (unused) decoder.
+ */
+bool nfs3_dirlist3_decode_begin(struct xdrgen_aggregate_cursor *c)
+{
+	return false;
+}
+
+bool nfs3_dirlist3_decode(struct xdrgen_aggregate_cursor *c,
+			  const struct entry3 *in)
+{
+	return false;
+}
+
+bool nfs3_dirlist3_decode_end(struct xdrgen_aggregate_cursor *c, bool ok)
+{
+	return false;
+}
+
 bool
 nfs3svc_encode_readdirplusres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
@@ -335,7 +466,7 @@ compose_entry_fh(struct nfsd3_readdirplusres *cd, struct svc_fh *fhp,
  * @cookie: cookie to be encoded
  *
  * The buffer space for the offset cookie has already been reserved
- * by nfs3svc_encode_entry3() or nfs3svc_encode_entryplus3().
+ * by nfs3_dirlist3_encode() or nfs3svc_encode_entryplus3().
  */
 void nfs3svc_encode_cookie3(struct xdr_stream *xdr, unsigned int pos,
 			    u64 cookie)
@@ -347,60 +478,6 @@ void nfs3svc_encode_cookie3(struct xdr_stream *xdr, unsigned int pos,
 	write_bytes_to_xdr_buf(xdr->buf, pos, &wire_cookie, XDR_UNIT * 2);
 }
 
-/**
- * nfs3svc_encode_entry3 - encode one NFSv3 READDIR entry
- * @data: directory context
- * @name: name of the object to be encoded
- * @namlen: length of that name, in bytes
- * @offset: the offset of the previous entry
- * @ino: the fileid of this entry
- * @d_type: unused
- *
- * Return values:
- *   %0: Entry was successfully encoded.
- *   %-EINVAL: An encoding problem occurred, secondary status code in resp->common.err
- *
- * On exit, the following fields are updated:
- *   - resp->xdr
- *   - resp->common.err
- *   - resp->cookie_offset
- */
-int nfs3svc_encode_entry3(void *data, const char *name, int namlen,
-			  loff_t offset, u64 ino, unsigned int d_type)
-{
-	struct readdir_cd *ccd = data;
-	struct nfsd3_readdirres *resp =
-		container_of(ccd, struct nfsd3_readdirres, common);
-	unsigned int starting_length = resp->dirlist.len;
-	struct xdr_stream *xdr = &resp->xdr;
-
-	/* The offset cookie for the previous entry */
-	nfs3svc_encode_cookie3(xdr, resp->cookie_offset, offset);
-
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
-
-	xdr_commit_encode(xdr);
-	resp->common.err = nfs_ok;
-	return 0;
-
-out_toosmall:
-	resp->cookie_offset = 0;
-	resp->common.err = nfserr_toosmall;
-	resp->dirlist.len = starting_length;
-	return -EINVAL;
-}
-
 static bool
 svcxdr_encode_entry3_plus(struct nfsd3_readdirplusres *resp, const char *name,
 			  int namlen, u64 ino)
@@ -499,3 +576,14 @@ nfs3svc_release_fhandle(struct svc_rqst *rqstp)
 
 	fh_put(&resp->fh);
 }
+
+void
+nfs3svc_release_readdirres(struct svc_rqst *rqstp)
+{
+	struct nfsd3_readdirres *resp = rqstp->rq_resp;
+	struct READDIR3args_wrapper *argp = rqstp->rq_argp;
+
+	/* argp->fh is zeroed by pc_argzero when argument decoding fails */
+	nfsd_readdir_close(&resp->iter);
+	fh_put(&argp->fh);
+}
diff --git a/fs/nfsd/nfs3xdr_gen.c b/fs/nfsd/nfs3xdr_gen.c
index 3667c160e789..5739a6e004ab 100644
--- a/fs/nfsd/nfs3xdr_gen.c
+++ b/fs/nfsd/nfs3xdr_gen.c
@@ -1,7 +1,7 @@
 // SPDX-License-Identifier: GPL-2.0
 // Generated by xdrgen. Manual edits will be lost.
 // XDR specification file: Documentation/sunrpc/xdr/nfs3.x
-// XDR specification modification time: Tue Jul 14 12:13:57 2026
+// XDR specification modification time: Tue Jul 14 20:36:22 2026
 
 #include <linux/sunrpc/svc.h>
 
@@ -1258,8 +1258,31 @@ xdrgen_decode_entry3(struct xdr_stream *xdr, struct entry3 *ptr)
 static bool __maybe_unused
 xdrgen_decode_dirlist3(struct xdr_stream *xdr, struct dirlist3 *ptr)
 {
-	if (!xdrgen_decode_entry3(xdr, ptr->entries))
-		return false;
+	{
+		struct xdrgen_aggregate_cursor cursor = {
+			.xdr = xdr,
+			.member_id = NFS3_DIRLIST3_ENTRIES,
+			.ctx = xdr->xdrgen_ctx,
+		};
+		bool ok = true;
+
+		if (!nfs3_dirlist3_decode_begin(&cursor))
+			return false;
+		for (cursor.index = 0; cursor.index < cursor.count; cursor.index++) {
+			struct entry3 element = {};
+
+			if (!xdrgen_decode_entry3(xdr, &element)) {
+				ok = false;
+				break;
+			}
+			if (!nfs3_dirlist3_decode(&cursor, &element)) {
+				ok = false;
+				break;
+			}
+		}
+		if (!nfs3_dirlist3_decode_end(&cursor, ok) || !ok)
+			return false;
+	}
 	if (!xdrgen_decode_bool(xdr, &ptr->eof))
 		return false;
 	return true;
@@ -3089,8 +3112,31 @@ xdrgen_encode_entry3(struct xdr_stream *xdr, const struct entry3 *value)
 static bool __maybe_unused
 xdrgen_encode_dirlist3(struct xdr_stream *xdr, const struct dirlist3 *value)
 {
-	if (!xdrgen_encode_entry3(xdr, value->entries))
-		return false;
+	{
+		struct xdrgen_aggregate_cursor cursor = {
+			.xdr = xdr,
+			.member_id = NFS3_DIRLIST3_ENTRIES,
+			.ctx = xdr->xdrgen_ctx,
+		};
+		bool ok = true;
+
+		if (!nfs3_dirlist3_encode_begin(&cursor))
+			return false;
+		for (cursor.index = 0; ; cursor.index++) {
+			struct entry3 element = {};
+
+			if (!nfs3_dirlist3_encode(&cursor, &element))
+				break;
+			if (!xdrgen_encode_entry3(xdr, &element)) {
+				ok = false;
+				break;
+			}
+		}
+		if (ok && !xdrgen_encode_entry3(xdr, NULL))
+			ok = false;
+		if (!nfs3_dirlist3_encode_end(&cursor, ok) || !ok)
+			return false;
+	}
 	if (!xdrgen_encode_bool(xdr, value->eof))
 		return false;
 	return true;
diff --git a/fs/nfsd/nfs3xdr_gen.h b/fs/nfsd/nfs3xdr_gen.h
index f336ffa92a7a..5c302645bfbe 100644
--- a/fs/nfsd/nfs3xdr_gen.h
+++ b/fs/nfsd/nfs3xdr_gen.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: Documentation/sunrpc/xdr/nfs3.x */
-/* XDR specification modification time: Tue Jul 14 12:13:57 2026 */
+/* XDR specification modification time: Tue Jul 14 20:36:22 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS3_DECL_H
 #define _LINUX_XDRGEN_NFS3_DECL_H
@@ -13,6 +13,17 @@
 #include <linux/sunrpc/xdrgen/_builtins.h>
 #include <linux/sunrpc/xdrgen/nfs3.h>
 
+enum {
+	NFS3_DIRLIST3_ENTRIES,
+};
+
+bool nfs3_dirlist3_encode_begin(struct xdrgen_aggregate_cursor *c);
+bool nfs3_dirlist3_encode(struct xdrgen_aggregate_cursor *c, struct entry3 *out);
+bool nfs3_dirlist3_encode_end(struct xdrgen_aggregate_cursor *c, bool ok);
+bool nfs3_dirlist3_decode_begin(struct xdrgen_aggregate_cursor *c);
+bool nfs3_dirlist3_decode(struct xdrgen_aggregate_cursor *c, const struct entry3 *in);
+bool nfs3_dirlist3_decode_end(struct xdrgen_aggregate_cursor *c, bool ok);
+
 bool nfs_svc_decode_GETATTR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs_svc_decode_SETATTR3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs_svc_decode_LOOKUP3args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
diff --git a/fs/nfsd/xdr3.h b/fs/nfsd/xdr3.h
index a9e3ac100251..d0047ecf5723 100644
--- a/fs/nfsd/xdr3.h
+++ b/fs/nfsd/xdr3.h
@@ -63,22 +63,31 @@ struct nfsd3_writeres {
 
 static_assert(offsetof(struct nfsd3_writeres, xdrgen) == 0);
 
-struct nfsd3_readdirres {
-	/* Components of the reply */
-	__be32			status;
+/*
+ * Declared here rather than in nfs3proc.c with the other proc wrappers
+ * because READDIR's encode path in nfs3xdr.c reads the file handle from
+ * it during encode and release. The xdrgen field must be first so the
+ * struct can be cast to its XDR type for the RPC dispatch layer.
+ */
+struct READDIR3args_wrapper {
+	struct READDIR3args	xdrgen;
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
 
+static_assert(offsetof(struct READDIR3args_wrapper, xdrgen) == 0);
+
+struct nfsd3_readdirres {
+	struct READDIR3res	xdrgen;
+
+	/* Streaming state for encoding the reply's entry list */
+	struct nfsd_readdir_iter iter;		/* directory reader */
+	u32			count;		/* client's reply size hint */
+	u32			space_left;	/* remaining entry budget */
+	unsigned int		cookie_offset;	/* prev entry's cookie slot */
+};
+
+static_assert(offsetof(struct nfsd3_readdirres, xdrgen) == 0);
+
 struct nfsd3_readdirplusres {
 	/* Components of the reply */
 	__be32			status;
@@ -130,15 +139,13 @@ struct nfsd3_getaclres {
 };
 
 bool nfs3svc_encode_accessres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-bool nfs3svc_encode_readdirres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs3svc_encode_readdirplusres(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 
 void nfs3svc_release_fhandle(struct svc_rqst *);
+void nfs3svc_release_readdirres(struct svc_rqst *rqstp);
 
 void nfs3svc_encode_cookie3(struct xdr_stream *xdr, unsigned int pos,
 			    u64 cookie);
-int nfs3svc_encode_entry3(void *data, const char *name, int namlen,
-			  loff_t offset, u64 ino, unsigned int d_type);
 int nfs3svc_encode_entryplus3(void *data, const char *name, int namlen,
 			      loff_t offset, u64 ino, unsigned int d_type);
 /* Helper functions for NFSv3 ACL code */
diff --git a/include/linux/sunrpc/xdrgen/nfs3.h b/include/linux/sunrpc/xdrgen/nfs3.h
index 3e24abb1d2e5..27750bbab2ee 100644
--- a/include/linux/sunrpc/xdrgen/nfs3.h
+++ b/include/linux/sunrpc/xdrgen/nfs3.h
@@ -1,7 +1,7 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /* Generated by xdrgen. Manual edits will be lost. */
 /* XDR specification file: Documentation/sunrpc/xdr/nfs3.x */
-/* XDR specification modification time: Tue Jul 14 12:13:57 2026 */
+/* XDR specification modification time: Tue Jul 14 20:36:22 2026 */
 
 #ifndef _LINUX_XDRGEN_NFS3_DEF_H
 #define _LINUX_XDRGEN_NFS3_DEF_H
-- 
2.55.0

